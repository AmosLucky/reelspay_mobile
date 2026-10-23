import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallet.dart';
import '../theme/app_theme.dart';
import '../utils.dart';
import '../widgets/snack.dart';

/// Earning tab — balance card, stats, daily tasks and transaction history.
class EarningScreen extends StatefulWidget {
  const EarningScreen({super.key});

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  final Set<String> _claimed = {};

  void _claim(String id, String label, int reward) {
    if (_claimed.contains(id)) return;
    setState(() => _claimed.add(id));
    context.read<Wallet>().earn(reward, 'Task complete · $label', kind: TxKind.task);
    showSnack(context, '+${naira(reward)} claimed!');
  }

  void _showWithdrawSheet() {
    final wallet = context.read<Wallet>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Withdraw',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Balance: ${naira(wallet.balance)} · minimum ${naira(Wallet.withdrawTarget)}',
                  style: const TextStyle(color: AppColors.textDim, fontSize: 13),
                ),
                const SizedBox(height: 14),
                for (final tier in const [10000, 25000, 50000])
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: wallet.balance >= tier,
                    leading: Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_balance_rounded,
                          color: AppColors.gold, size: 20),
                    ),
                    title: Text(
                      naira(tier),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: const Text(
                      'to bank ••42',
                      style: TextStyle(color: AppColors.textDim, fontSize: 12),
                    ),
                    trailing: wallet.balance >= tier
                        ? const Icon(Icons.arrow_forward_ios_rounded,
                            size: 16, color: AppColors.textDim)
                        : const Text(
                            'Locked',
                            style: TextStyle(
                              color: AppColors.textDim,
                              fontSize: 11,
                            ),
                          ),
                    onTap: wallet.balance >= tier
                        ? () {
                            final ok = wallet.withdraw(tier);
                            Navigator.of(sheetContext).pop();
                            showSnack(
                              context,
                              ok
                                  ? '${naira(tier)} withdrawal requested · arrives in 24h'
                                  : 'Insufficient balance',
                            );
                          }
                        : null,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<Wallet>();
    final watchProgress =
        (wallet.watchSeconds / 600).clamp(0.0, 1.0).toDouble();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          Row(
            children: [
              const Text(
                'Earning',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => showSnack(
                    context, 'Earn \$5–\$9 per 20s of watching · 60s boost doubles it'),
                icon: const Icon(Icons.help_outline_rounded,
                    color: AppColors.textDim),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _BalanceCard(
            balance: wallet.balance,
            canWithdraw: wallet.canWithdraw,
            onWithdraw: _showWithdrawSheet,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Today',
                  value: '+${naira(wallet.todayEarned)}',
                  highlight: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(label: 'Total Earned', value: naira(wallet.totalEarned)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                    label: 'Watch Time', value: watchDuration(wallet.watchSeconds)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Daily Tasks',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _TaskCard(
            icon: Icons.play_circle_fill_rounded,
            color: AppColors.violet,
            title: 'Watch 10 minutes today',
            reward: 200,
            progress: watchProgress,
            progressLabel: '${wallet.watchSeconds.clamp(0, 600)}/600s',
            claimed: _claimed.contains('watch10'),
            onClaim: () => _claim('watch10', 'Watch 10 minutes', 200),
          ),
          _TaskCard(
            icon: Icons.movie_filter_rounded,
            color: AppColors.pink,
            title: 'Finish 3 episodes',
            reward: 120,
            progress: 0,
            progressLabel: '0/3',
            claimed: _claimed.contains('ep3'),
            onClaim: () => _claim('ep3', 'Finish 3 episodes', 120),
          ),
          _TaskCard(
            icon: Icons.group_add_rounded,
            color: AppColors.green,
            title: 'Invite a friend',
            reward: 500,
            progress: 0,
            progressLabel: '0/1',
            claimed: _claimed.contains('invite'),
            onClaim: () => _claim('invite', 'Invite a friend', 500),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                'Target ${naira(Wallet.withdrawTarget)}',
                style: const TextStyle(color: AppColors.textDim, fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (wallet.tx.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No activity yet — start watching!',
                  style: TextStyle(color: AppColors.textDim, fontSize: 13),
                ),
              ),
            )
          else
            ...wallet.tx.take(12).map((t) => _TxTile(tx: t)),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.canWithdraw,
    required this.onWithdraw,
  });

  final num balance;
  final bool canWithdraw;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB020).withOpacity(0.3),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(
                  color: Color(0xFF5C4400),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF231A00).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Cash Wallet',
                  style: TextStyle(
                    color: Color(0xFF5C4400),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            naira(balance),
            style: const TextStyle(
              color: AppColors.onGold,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Earn \$5–\$9 per 20s of watching · 60s boost doubles it',
            style: TextStyle(
              color: Color(0xFF5C4400),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF231A00),
                foregroundColor: AppColors.gold,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              child: Text(
                canWithdraw
                    ? 'Withdraw ${naira(Wallet.withdrawTarget)}'
                    : 'Withdraw at ${naira(Wallet.withdrawTarget)}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? AppColors.gold.withOpacity(0.4) : AppColors.stroke,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: highlight ? AppColors.gold : AppColors.textPrimary,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.reward,
    required this.progress,
    required this.progressLabel,
    required this.claimed,
    required this.onClaim,
  });

  final IconData icon;
  final Color color;
  final String title;
  final int reward;
  final double progress;
  final String progressLabel;
  final bool claimed;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${naira(reward)}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    color: claimed ? AppColors.textDim : AppColors.gold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  claimed ? 'Completed' : progressLabel,
                  style: const TextStyle(color: AppColors.textDim, fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 32,
            child: claimed
                ? const Icon(Icons.check_circle_rounded,
                    color: AppColors.green, size: 24)
                : (progress >= 1.0
                    ? ElevatedButton(
                        onPressed: onClaim,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.onGold,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          elevation: 0,
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        child: const Text('Claim'),
                      )
                    : OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.stroke),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        child: const Text(
                          'Go',
                          style: TextStyle(color: AppColors.textDim),
                        ),
                      )),
          ),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx});

  final Tx tx;

  IconData get _icon {
    switch (tx.kind) {
      case TxKind.watch:
        return Icons.play_circle_outline_rounded;
      case TxKind.doubleReward:
        return Icons.bolt_rounded;
      case TxKind.bonus:
        return Icons.card_giftcard_rounded;
      case TxKind.task:
        return Icons.check_circle_outline_rounded;
      case TxKind.withdraw:
        return Icons.north_east_rounded;
    }
  }

  String get _when {
    final d = DateTime.now().difference(tx.at);
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final positive = tx.amount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (positive ? AppColors.gold : AppColors.red).withOpacity(0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(_icon, color: positive ? AppColors.gold : AppColors.red, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(_when, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            positive ? '+${naira(tx.amount)}' : '-${naira(tx.amount.abs())}',
            style: TextStyle(
              color: positive ? AppColors.green : AppColors.red,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

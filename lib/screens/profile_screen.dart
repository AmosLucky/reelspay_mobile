import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/wallet.dart';
import '../theme/app_theme.dart';
import '../utils.dart';
import '../widgets/snack.dart';
import 'profile_info_screen.dart';

/// Profile tab — user header, stats, menu (wallet / invite / settings).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onDeleteAccount});

  final Future<void> Function()? onDeleteAccount;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _confirmDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete local account data?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This permanently clears your locally saved balance, earnings, transactions, payment method, and preferences from this device. You will return to first-time setup.',
          style: TextStyle(color: AppColors.textDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete data',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    final deleteAccount = widget.onDeleteAccount;
    if (deleteAccount == null) {
      showSnack(context, 'Could not restart the app. Please try again.');
      return;
    }
    await deleteAccount();
  }


  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<Wallet>();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.violetGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.4),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Guest User',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'ID: RP-88213 · Lagos, NG',
                      style: TextStyle(color: AppColors.textDim, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.onGold),
                    SizedBox(width: 4),
                    Text(
                      'VIP 1',
                      style: TextStyle(
                        color: AppColors.onGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Row(
              children: [
                _Stat(value: naira(wallet.balance), label: 'Balance'),
                Container(width: 1, height: 30, color: AppColors.stroke),
                _Stat(value: naira(wallet.totalEarned), label: 'Total Earned'),
                Container(width: 1, height: 30, color: AppColors.stroke),
                _Stat(value: watchDuration(wallet.watchSeconds), label: 'Watch Time'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('MY STUFF'),
          _MenuTile(
            icon: Icons.account_balance_wallet_rounded,
            title: 'My Wallet',
            trailing: naira(wallet.balance),
            onTap: () => showSnack(context, 'Wallet: ${naira(wallet.balance)} available'),
          ),
          _MenuTile(
            icon: Icons.card_giftcard_rounded,
            title: 'Invite Friends',
            trailing: 'CODE: REELS882',
            onTap: () {
              Clipboard.setData(const ClipboardData(text: 'REELS882'));
              showSnack(context, 'Invite code copied!');
            },
          ),
          _MenuTile(
            icon: Icons.settings_rounded,
            title: 'Settings',
            onTap: () => showSnack(context, 'Prototype · coming soon'),
          ),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProfileInfoScreen(
                  page: ProfileInfoPage.help,
                ),
              ),
            ),
          ),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            title: 'About Us',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProfileInfoScreen(
                  page: ProfileInfoPage.about,
                ),
              ),
            ),
          ),
          _MenuTile(
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            onTap: _confirmDeleteAccount,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProfileInfoScreen(
                    page: ProfileInfoPage.policies,
                  ),
                ),
              ),
              child: const Text(
                'Terms, Privacy & Policies',
                style: TextStyle(
                  color: AppColors.gold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'ReelsPay v1.0.0 · Prototype',
              style: TextStyle(color: AppColors.textDim, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textDim,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.stroke),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppColors.gold, size: 19),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: trailing != null
            ? Text(
                trailing!,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              )
            : const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.textDim),
      ),
    );
  }
}

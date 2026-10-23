import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallet.dart';
import '../theme/app_theme.dart';
import '../utils.dart';

/// Gold balance pill shown in the Home header and on top of the Reels feed.
///
/// Pulses (quick scale-down) every time the balance changes, so each
/// 20-second payout is clearly visible. Pass [targetKey] (a GlobalKey) to
/// use it as the destination for the cash-fly animation.
class BalanceChip extends StatelessWidget {
  const BalanceChip({super.key, this.targetKey, this.onTap});

  final Key? targetKey;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<Wallet>().balance;
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        key: ValueKey<num>(balance),
        tween: Tween(begin: 1.16, end: 1.0),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Container(
          key: targetKey,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.gold.withOpacity(0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_rounded,
                  color: AppColors.gold, size: 16),
              const SizedBox(width: 5),
              Text(
                naira(balance),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../services/ads_service.dart';
import '../../theme/app_theme.dart';
import '../../utils.dart';

enum RewardBoostResult { doubled, keepWatching, adUnavailable }

/// Shown every 60 seconds of watching. Offers:
///  * "Watch Ad · Double It" — shows a rewarded ad and reports whether it
///    was completed or unavailable;
///  * "Keep watching" — dismisses the dialog and continues the feed.
class DoubleRewardDialog extends StatefulWidget {
  const DoubleRewardDialog({super.key, required this.coins});

  /// Amount earned during the current 60s cycle.
  final num coins;

  @override
  State<DoubleRewardDialog> createState() => _DoubleRewardDialogState();
}

class _DoubleRewardDialogState extends State<DoubleRewardDialog> {
  bool _loadingAd = false;

  Future<void> _startAd() async {
    setState(() {
      _loadingAd = true;
    });
    var completed = false;
    try {
      completed = await AdsService.instance.showRewardedOrInterstitial();
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'reward boost dialog',
        context: ErrorDescription('while showing a reward ad'),
      ));
    }
    if (!mounted) return;
    if (completed) {
      Navigator.of(context).pop(RewardBoostResult.doubled);
      return;
    }
    Navigator.of(context).pop(RewardBoostResult.adUnavailable);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: AppColors.gold.withOpacity(0.45), width: 1.2),
          boxShadow: [
            BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 40),
          ],
        ),
        child: _buildChoice(context),
      ),
    );
  }

  Widget _buildChoice(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
            boxShadow: [
              BoxShadow(
                  color: AppColors.gold.withOpacity(0.45), blurRadius: 24),
            ],
          ),
          child: const Icon(Icons.emoji_events_rounded,
              color: AppColors.onGold, size: 38),
        ),
        const SizedBox(height: 14),
        const Text(
          'REWARD BOOST!',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'You earned '),
              TextSpan(
                text: naira(widget.coins),
                style: const TextStyle(
                    color: AppColors.gold, fontWeight: FontWeight.w900),
              ),
              const TextSpan(
                text:
                    ' in the last 60 seconds.\nDouble it by watching a short ad?',
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _loadingAd ? null : _startAd,
            icon: _loadingAd
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onGold,
                    ),
                  )
                : const Icon(Icons.movie_rounded, size: 20),
            label: Text(
              _loadingAd ? 'Loading ad…' : 'Watch Ad · Double It',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.onGold,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: TextButton(
            onPressed: _loadingAd
                ? null
                : () =>
                    Navigator.of(context).pop(RewardBoostResult.keepWatching),
            child: const Text(
              'Keep watching',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

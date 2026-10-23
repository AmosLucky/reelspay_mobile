import 'dart:math';

import 'services/currency_service.dart';

/// Formats a monetary value in the active currency.
String naira(num amount) {
  return CurrencyService.formatAmount(amount, CurrencyService.currentCurrencyCode);
}

String rewardText({double usdAmount = 0.20}) {
  final localAmount = CurrencyService.convertUsdToCurrency(usdAmount, CurrencyService.currentCurrencyCode);
  return CurrencyService.formatAmount(localAmount, CurrencyService.currentCurrencyCode);
}

/// Formats seconds as 'Xm Ys' (or 'Ys' under a minute).
String watchDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (m <= 0) return '${s}s';
  return '${m}m ${s.toString().padLeft(2, '0')}s';
}

/// 128400 -> '128.4K', 9600 -> '9.6K', 800 -> '800'.
String compactCount(int n) {
  if (n >= 1000000) {
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }
  if (n >= 1000) {
    return '${(n / 1000).toStringAsFixed(1)}K';
  }
  return '$n';
}

/// Shared RNG for reward amounts.
final Random rng = Random();

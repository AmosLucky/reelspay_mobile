class CurrencyService {
  CurrencyService._();

  static const String snapshotDate = '2026-10-21';

  static const Map<String, double> rates = {
    'NGN': 1.0,
    'USD': 1334.99,
    'GBP': 1780.87,
    'EUR': 1498.73,
    'CAD': 949.46,
    'AUD': 934.45,
    'AED': 363.51,
    'CNY': 199.51,
    'ZAR': 81.42,
    'GHS': 114.55,
    'CHF': 1617.53,
    'JPY': 8.44,
    'SAR': 356.00,
    'INR': 14.10,
    'KES': 10.30,
    'UGX': 0.36,
    'TZS': 0.52,
    'XOF': 2.28,
    'XAF': 2.28,
    'EGP': 27.20,
  };

  static const Map<String, String> symbols = {
    'NGN': '₦',
    'USD': r'$',
    'GBP': '£',
    'EUR': '€',
    'CAD': r'CA$',
    'AUD': r'A$',
    'AED': 'د.إ',
    'CNY': '¥',
    'ZAR': 'R',
    'GHS': 'GH₵',
    'CHF': 'CHF ',
    'JPY': '¥',
    'SAR': 'ر.س',
    'INR': '₹',
    'KES': 'KSh ',
    'UGX': 'USh ',
    'TZS': 'TSh ',
    'XOF': 'CFA ',
    'XAF': 'FCFA ',
    'EGP': 'E£',
  };

  static const Map<String, String> countryDefaults = {
    'Nigeria': 'NGN',
    'United States': 'USD',
    'United Kingdom': 'GBP',
    'Germany': 'EUR',
    'Canada': 'CAD',
    'Australia': 'AUD',
    'United Arab Emirates': 'AED',
    'China': 'CNY',
    'South Africa': 'ZAR',
    'Ghana': 'GHS',
    'Switzerland': 'CHF',
    'Japan': 'JPY',
    'Saudi Arabia': 'SAR',
    'India': 'INR',
    'Kenya': 'KES',
    'Uganda': 'UGX',
    'Tanzania': 'TZS',
    'Ivory Coast': 'XOF',
    'Cameroon': 'XAF',
    'Egypt': 'EGP',
  };

  static final List<String> countries = countryDefaults.keys.toList();
  static const List<String> supportedCurrencies = [
    'NGN', 'USD', 'GBP', 'EUR', 'CAD', 'AUD', 'AED', 'CNY', 'ZAR', 'GHS',
    'CHF', 'JPY', 'SAR', 'INR', 'KES', 'UGX', 'TZS', 'XOF', 'XAF', 'EGP',
  ];

  static String currentCurrencyCode = 'USD';

  static double usdReferenceRate() => rates['USD'] ?? 1.0;

  static double selectedCurrencyUnitsPerUsd(String currencyCode) {
    final key = currencyCode.toUpperCase();
    final usdRate = usdReferenceRate();
    final selectedRate = rates[key] ?? 1.0;
    return usdRate / selectedRate;
  }

  static double convertUsdToCurrency(double usdAmount, String currencyCode) {
    final code = (currencyCode.isEmpty ? 'USD' : currencyCode).toUpperCase();
    if (code == 'USD') return usdAmount;
    return usdAmount * selectedCurrencyUnitsPerUsd(code);
  }

  static double convertCurrencyToUsd(double amount, String currencyCode) {
    final code = (currencyCode.isEmpty ? 'USD' : currencyCode).toUpperCase();
    if (code == 'USD') return amount;
    final unitsPerUsd = selectedCurrencyUnitsPerUsd(code);
    return amount / unitsPerUsd;
  }

  static double convertUsdCentsToCurrency(int usdCents, String currencyCode) {
    return convertUsdToCurrency(usdCents / 100, currencyCode);
  }

  static int convertCurrencyToUsdCents(num amount, String currencyCode) {
    return (convertCurrencyToUsd(amount.toDouble(), currencyCode) * 100).round();
  }

  static String formatAmount(num amount, String currencyCode) {
    final sign = amount < 0 ? '-' : '';
    final absValue = amount.abs();
    final symbol = symbols[currencyCode.toUpperCase()] ?? currencyCode.toUpperCase();

    if (absValue < 1) {
      return '$sign$symbol${absValue.toStringAsFixed(2)}';
    }

    final asString = absValue.toStringAsFixed(absValue % 1 == 0 ? 0 : 2);
    final parts = asString.split('.');
    final integerPart = parts.first.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );

    if (parts.length == 1) {
      return '$sign$symbol$integerPart';
    }

    final decimalPart = parts[1].replaceFirst(RegExp(r'0+$'), '');
    if (decimalPart.isEmpty) {
      return '$sign$symbol$integerPart';
    }
    return '$sign$symbol$integerPart.$decimalPart';
  }
}

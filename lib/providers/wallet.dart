import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/currency_service.dart';

enum TxKind { watch, doubleReward, bonus, withdraw, task }

class Tx {
  const Tx({
    required this.label,
    required this.amount,
    required this.at,
    required this.kind,
  });

  final String label;

  /// Positive = earned, negative = withdrawn.
  final num amount;
  final DateTime at;
  final TxKind kind;
}

/// Single source of truth for the "watch & earn" economy.
class Wallet extends ChangeNotifier {
  Wallet() {
    _currencyCode = 'USD';
    _countryCode = 'United States';
    _tx.addAll([
      Tx(
        label: 'Welcome bonus',
        amount: 1,
        at: DateTime.now().subtract(const Duration(hours: 5)),
        kind: TxKind.bonus,
      ),
      Tx(
        label: 'Watched "Crimson Night Kiss" · EP1',
        amount: 1,
        at: DateTime.now().subtract(const Duration(hours: 3)),
        kind: TxKind.watch,
      ),
      Tx(
        label: 'Doubled your earnings',
        amount: 1,
        at: DateTime.now().subtract(const Duration(hours: 2)),
        kind: TxKind.doubleReward,
      ),
    ]);
  }

  static num get withdrawTarget =>
      CurrencyService.convertUsdToCurrency(100, CurrencyService.currentCurrencyCode);

  String _currencyCode = 'USD';
  String _countryCode = 'United States';
  bool _hasSetup = false;

  int _balanceUsdCents = 0;
  int _totalEarnedUsdCents = 0;
  int _todayEarnedUsdCents = 0;
  int _watchSeconds = 0;
  final List<Tx> _tx = [];

  bool get hasSetup => _hasSetup;
  String get currencyCode => _currencyCode;
  String get countryCode => _countryCode;

  num get balance => CurrencyService.convertUsdCentsToCurrency(_balanceUsdCents, _currencyCode);
  num get totalEarned => CurrencyService.convertUsdCentsToCurrency(_totalEarnedUsdCents, _currencyCode);
  num get todayEarned => CurrencyService.convertUsdCentsToCurrency(_todayEarnedUsdCents, _currencyCode);
  int get watchSeconds => _watchSeconds;
  bool get canWithdraw => balance >= withdrawTarget;
  List<Tx> get tx => List.unmodifiable(_tx);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCountry = prefs.getString('selected_country');
    final savedCurrency = prefs.getString('selected_currency');

    if (savedCountry != null && savedCurrency != null) {
      await applySelection(countryCode: savedCountry, currencyCode: savedCurrency, autoSave: false);
    } else {
      CurrencyService.currentCurrencyCode = _currencyCode;
    }
  }

  Future<void> applySelection({
    required String countryCode,
    required String currencyCode,
    bool autoSave = true,
  }) async {
    final normalizedCountry = countryCode.trim();
    final normalizedCurrency = currencyCode.toUpperCase();
    _countryCode = normalizedCountry;
    _currencyCode = normalizedCurrency;
    CurrencyService.currentCurrencyCode = normalizedCurrency;

    if (!_hasSetup) {
      _hasSetup = true;
      _balanceUsdCents = 50 * 100;
      _totalEarnedUsdCents = 50 * 100;
      _todayEarnedUsdCents = 0;
      _watchSeconds = 0;
      _tx.clear();
      _tx.add(Tx(
        label: 'Welcome bonus',
        amount: CurrencyService.convertUsdToCurrency(50, normalizedCurrency).round(),
        at: DateTime.now(),
        kind: TxKind.bonus,
      ));
    }

    if (autoSave) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_country', normalizedCountry);
      await prefs.setString('selected_currency', normalizedCurrency);
    }

    notifyListeners();
  }

  void earn(num amount, String label, {TxKind kind = TxKind.watch}) {
    if (amount <= 0) return;
    final usdCents = CurrencyService.convertCurrencyToUsdCents(amount, _currencyCode);
    _balanceUsdCents += usdCents;
    _totalEarnedUsdCents += usdCents;
    _todayEarnedUsdCents += usdCents;
    _tx.insert(0, Tx(label: label, amount: amount, at: DateTime.now(), kind: kind));
    notifyListeners();
  }

  void earnUsd(double usdAmount, String label, {TxKind kind = TxKind.watch}) {
    final cents = (usdAmount * 100).round();
    if (cents <= 0) return;
    _balanceUsdCents += cents;
    _totalEarnedUsdCents += cents;
    _todayEarnedUsdCents += cents;
    final displayAmount = CurrencyService.convertUsdToCurrency(usdAmount, _currencyCode);
    _tx.insert(0, Tx(label: label, amount: displayAmount, at: DateTime.now(), kind: kind));
    notifyListeners();
  }

  void addWatchSeconds(int seconds) {
    _watchSeconds += seconds;
    notifyListeners();
  }

  bool withdraw([int amount = 0]) {
    final withdrawAmount = amount <= 0 ? withdrawTarget : amount;
    if (withdrawAmount <= 0 || withdrawAmount > balance) return false;

    final usdCents = CurrencyService.convertCurrencyToUsdCents(withdrawAmount, _currencyCode);
    _balanceUsdCents -= usdCents;
    _tx.insert(0, Tx(
      label: 'Withdrawal to bank ••42',
      amount: -withdrawAmount,
      at: DateTime.now(),
      kind: TxKind.withdraw,
    ));
    notifyListeners();
    return true;
  }
}

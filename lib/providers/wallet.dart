import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/currency_service.dart';

enum TxKind { watch, doubleReward, bonus, withdraw, task }

enum PaymentMethodType { paypal, crypto, bank }

class PaymentMethod {
  const PaymentMethod({
    required this.type,
    this.email,
    this.walletAddress,
    this.network,
    this.bankName,
    this.accountNumber,
    this.accountName,
  });

  final PaymentMethodType type;
  final String? email;
  final String? walletAddress;
  final String? network;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;

  String get title => switch (type) {
        PaymentMethodType.paypal => 'PayPal',
        PaymentMethodType.crypto => 'Crypto wallet',
        PaymentMethodType.bank => 'Bank account',
      };

  String get summary => switch (type) {
        PaymentMethodType.paypal => email ?? '',
        PaymentMethodType.crypto =>
          '${network ?? ''} · ${_maskedAddress(walletAddress ?? '')}',
        PaymentMethodType.bank =>
          '$bankName · ${accountNumber == null || accountNumber!.length < 4 ? accountNumber : '••${accountNumber!.substring(accountNumber!.length - 4)}'}',
      };

  String _maskedAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}…${address.substring(address.length - 4)}';
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'email': email,
        'walletAddress': walletAddress,
        'network': network,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountName': accountName,
      };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'];
    final type =
        PaymentMethodType.values.where((value) => value.name == typeName);
    if (type.isEmpty) {
      throw const FormatException('Saved payment method type is invalid.');
    }
    return PaymentMethod(
      type: type.first,
      email: json['email'] as String?,
      walletAddress: json['walletAddress'] as String?,
      network: json['network'] as String?,
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      accountName: json['accountName'] as String?,
    );
  }
}

class Tx {
  const Tx({
    required this.label,
    required this.amount,
    required this.at,
    required this.kind,
    this.paymentDueAt,
  });

  final String label;

  /// Positive = earned, negative = withdrawn.
  final num amount;
  final DateTime at;
  final TxKind kind;
  final DateTime? paymentDueAt;
}

/// Single source of truth for the "watch & earn" economy.
class Wallet extends ChangeNotifier {
  static const String _stateKey = 'wallet_state_v1';
  static const int _welcomeBonusUsdCents = 35 * 100;

  Wallet() {
    _currencyCode = 'USD';
    _countryCode = 'United States';
  }

  static num get withdrawTarget => CurrencyService.convertUsdToCurrency(
      100, CurrencyService.currentCurrencyCode);

  String _currencyCode = 'USD';
  String _countryCode = 'United States';
  bool _hasSetup = false;

  int _balanceUsdCents = 0;
  int _totalEarnedUsdCents = 0;
  int _todayEarnedUsdCents = 0;
  int _watchSeconds = 0;
  PaymentMethod? _paymentMethod;
  final List<Tx> _tx = [];
  Future<void> _pendingPersistence = Future<void>.value();

  bool get hasSetup => _hasSetup;
  String get currencyCode => _currencyCode;
  String get countryCode => _countryCode;

  num get balance => CurrencyService.convertUsdCentsToCurrency(
      _balanceUsdCents, _currencyCode);
  num get totalEarned => CurrencyService.convertUsdCentsToCurrency(
      _totalEarnedUsdCents, _currencyCode);
  num get todayEarned => CurrencyService.convertUsdCentsToCurrency(
      _todayEarnedUsdCents, _currencyCode);
  int get watchSeconds => _watchSeconds;
  PaymentMethod? get paymentMethod => _paymentMethod;
  List<Tx> get withdrawals => List.unmodifiable(
      _tx.where((transaction) => transaction.kind == TxKind.withdraw));
  bool get canWithdraw => balance >= withdrawTarget;
  List<Tx> get tx => List.unmodifiable(_tx);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getString(_stateKey);
    if (savedState != null) {
      _restoreState(savedState);
    }

    final savedCountry = prefs.getString('selected_country');
    final savedCurrency = prefs.getString('selected_currency');

    if (savedCountry != null && savedCurrency != null) {
      await applySelection(
          countryCode: savedCountry,
          currencyCode: savedCurrency,
          autoSave: false);
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
      _balanceUsdCents = _welcomeBonusUsdCents;
      _totalEarnedUsdCents = _welcomeBonusUsdCents;
      _todayEarnedUsdCents = _welcomeBonusUsdCents;
      _watchSeconds = 0;
      _tx.clear();
      _tx.add(Tx(
        label: 'Welcome bonus',
        amount: CurrencyService.convertUsdToCurrency(
          _welcomeBonusUsdCents / 100,
          normalizedCurrency,
        ).round(),
        at: DateTime.now(),
        kind: TxKind.bonus,
      ));
    }

    if (autoSave) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_country', normalizedCountry);
      await prefs.setString('selected_currency', normalizedCurrency);
    }

    _persistState();
    notifyListeners();
  }

  void earn(num amount, String label, {TxKind kind = TxKind.watch}) {
    if (amount <= 0) return;
    final usdCents =
        CurrencyService.convertCurrencyToUsdCents(amount, _currencyCode);
    _balanceUsdCents += usdCents;
    _totalEarnedUsdCents += usdCents;
    _todayEarnedUsdCents += usdCents;
    _tx.insert(
        0, Tx(label: label, amount: amount, at: DateTime.now(), kind: kind));
    _persistState();
    notifyListeners();
  }

  void earnUsd(double usdAmount, String label, {TxKind kind = TxKind.watch}) {
    final cents = (usdAmount * 100).round();
    if (cents <= 0) return;
    _balanceUsdCents += cents;
    _totalEarnedUsdCents += cents;
    _todayEarnedUsdCents += cents;
    final displayAmount =
        CurrencyService.convertUsdToCurrency(usdAmount, _currencyCode);
    _tx.insert(
        0,
        Tx(
            label: label,
            amount: displayAmount,
            at: DateTime.now(),
            kind: kind));
    _persistState();
    notifyListeners();
  }

  void addWatchSeconds(int seconds) {
    if (seconds <= 0) return;
    _watchSeconds += seconds;
    _persistState();
    notifyListeners();
  }

  void savePaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    _persistState();
    notifyListeners();
  }

  bool withdraw([num amount = 0]) {
    final withdrawAmount = amount <= 0 ? withdrawTarget : amount;
    if (_paymentMethod == null ||
        withdrawAmount < withdrawTarget ||
        withdrawAmount > balance) {
      return false;
    }

    final usdCents = CurrencyService.convertCurrencyToUsdCents(
        withdrawAmount, _currencyCode);
    _balanceUsdCents -= usdCents;
    final methodName = _paymentMethod?.title ?? 'payment method';
    final requestedAt = DateTime.now();
    _tx.insert(
        0,
        Tx(
          label: 'Withdrawal request · $methodName',
          amount: -withdrawAmount,
          at: requestedAt,
          kind: TxKind.withdraw,
          paymentDueAt: requestedAt.add(const Duration(days: 14)),
        ));
    _persistState();
    notifyListeners();
    return true;
  }

  Future<void> flushPersistence() => _pendingPersistence;

  Future<void> clearLocalData() async {
    await flushPersistence();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _currencyCode = 'USD';
    _countryCode = 'United States';
    CurrencyService.currentCurrencyCode = _currencyCode;
    _hasSetup = false;
    _balanceUsdCents = 0;
    _totalEarnedUsdCents = 0;
    _todayEarnedUsdCents = 0;
    _watchSeconds = 0;
    _paymentMethod = null;
    _tx.clear();
    notifyListeners();
  }

  void _persistState() {
    final snapshot = jsonEncode({
      'balanceUsdCents': _balanceUsdCents,
      'totalEarnedUsdCents': _totalEarnedUsdCents,
      'todayEarnedUsdCents': _todayEarnedUsdCents,
      'watchSeconds': _watchSeconds,
      if (_paymentMethod != null) 'paymentMethod': _paymentMethod!.toJson(),
      'transactions': _tx
          .map((tx) => {
                'label': tx.label,
                'amount': tx.amount,
                'at': tx.at.millisecondsSinceEpoch,
                'kind': tx.kind.name,
                if (tx.paymentDueAt != null)
                  'paymentDueAt': tx.paymentDueAt!.millisecondsSinceEpoch,
              })
          .toList(),
    });

    final write = _pendingPersistence.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(_stateKey, snapshot);
      if (!saved) {
        throw StateError('Could not save wallet state to local storage.');
      }
    });

    _pendingPersistence =
        write.catchError((Object error, StackTrace stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'wallet persistence',
        context: ErrorDescription('while saving wallet state locally'),
      ));
    });
  }

  void _restoreState(String encodedState) {
    final state = jsonDecode(encodedState);
    if (state is! Map<String, dynamic>) {
      throw const FormatException('Saved wallet state is not an object.');
    }

    _balanceUsdCents = _requiredInt(state, 'balanceUsdCents');
    _totalEarnedUsdCents = _requiredInt(state, 'totalEarnedUsdCents');
    _todayEarnedUsdCents = _requiredInt(state, 'todayEarnedUsdCents');
    _watchSeconds = _requiredInt(state, 'watchSeconds');
    final paymentMethod = state['paymentMethod'];
    if (paymentMethod != null) {
      if (paymentMethod is! Map<String, dynamic>) {
        throw const FormatException('Saved payment method is invalid.');
      }
      _paymentMethod = PaymentMethod.fromJson(paymentMethod);
    }
    final transactions = state['transactions'];
    if (transactions is! List) {
      throw const FormatException('Saved wallet transactions are invalid.');
    }

    _tx
      ..clear()
      ..addAll(transactions.map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Saved wallet transaction is invalid.');
        }
        final kindName = entry['kind'];
        if (kindName is! String) {
          throw const FormatException(
              'Saved wallet transaction kind is invalid.');
        }
        final kind = TxKind.values.where((value) => value.name == kindName);
        if (kind.isEmpty) {
          throw FormatException(
              'Unknown saved wallet transaction kind: $kindName');
        }
        final amount = entry['amount'];
        final timestamp = entry['at'];
        final label = entry['label'];
        final paymentDueAt = entry['paymentDueAt'];
        if (amount is! num || timestamp is! int || label is! String) {
          throw const FormatException(
              'Saved wallet transaction fields are invalid.');
        }
        if (paymentDueAt != null && paymentDueAt is! int) {
          throw const FormatException(
              'Saved withdrawal payment date is invalid.');
        }
        return Tx(
          label: label,
          amount: amount,
          at: DateTime.fromMillisecondsSinceEpoch(timestamp),
          kind: kind.first,
          paymentDueAt: paymentDueAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(paymentDueAt as int),
        );
      }));
    _hasSetup = true;
  }

  int _requiredInt(Map<String, dynamic> state, String key) {
    final value = state[key];
    if (value is! int) {
      throw FormatException('Saved wallet field "$key" is invalid.');
    }
    return value;
  }
}

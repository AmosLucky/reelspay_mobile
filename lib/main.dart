import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/wallet.dart';
import 'screens/main_shell.dart';
import 'services/ads_service.dart';
import 'services/currency_service.dart';
import 'theme/app_theme.dart';
import 'widgets/country_currency_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdsService.instance.initialize();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(const ReelsPayApp());
}

class ReelsPayApp extends StatelessWidget {
  const ReelsPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Wallet()..initialize(),
      child: MaterialApp(
        title: 'ReelsPay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AppGate(),
      ),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSelection();
  }

  Future<void> _checkSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedCountry = prefs.getString('selected_country');
    final selectedCurrency = prefs.getString('selected_currency');

    if (!mounted) return;
    setState(() => _loading = false);

    if (selectedCountry == null || selectedCurrency == null) {
      final wallet = context.read<Wallet>();
      final defaultCountry = CurrencyService.countries.first;
      final defaultCurrency =
          CurrencyService.countryDefaults[defaultCountry] ?? 'USD';
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => CountryCurrencyDialog(
          initialCountry: defaultCountry,
          initialCurrency: defaultCurrency,
          allowCancel: false,
          onSubmit: (country, currency) async {
            await wallet.applySelection(
                countryCode: country, currencyCode: currency);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0F),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE0A93B)),
        ),
      );
    }

    return const MainShell();
  }
}

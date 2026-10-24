import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/wallet.dart';
import 'screens/main_shell.dart';
import 'services/ads_service.dart';
import 'services/currency_service.dart';
import 'services/startup_service.dart';
import 'services/videos_service.dart';
import 'theme/app_theme.dart';
import 'widgets/country_currency_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(const ReelsPayApp());
  unawaited(_initializeAds());
}

Future<void> _initializeAds() async {
  try {
    await AdsService.instance.initialize();
  } catch (error, stackTrace) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'app startup',
      context: ErrorDescription('while initializing mobile ads'),
    ));
  }
}

class ReelsPayApp extends StatelessWidget {
  const ReelsPayApp({
    super.key,
    this.startupService = const FirebaseStartupService(),
    this.videoLoader,
  });

  final StartupService startupService;
  final VideoLoader? videoLoader;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Wallet(),
      child: MaterialApp(
        title: 'ReelsPay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: AppGate(
          startupService: startupService,
          videoLoader: videoLoader,
        ),
      ),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({
    super.key,
    required this.startupService,
    this.videoLoader,
  });

  final StartupService startupService;
  final VideoLoader? videoLoader;

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _loading = true;
  int _initialTab = 0;
  bool _celebrateWelcomeReward = false;
  Object? _startupError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _startupError = null;
      });
    }
    final minimumSplashTime = Future<void>.delayed(
      const Duration(milliseconds: 100),
    );
    final wallet = context.read<Wallet>();
    try {
      unawaited(_runBackgroundStartupTask(
        widget.startupService.ensureAnonymousSession(),
        'anonymous sign-in',
      ));
      unawaited(_runBackgroundStartupTask(
        widget.startupService.requestNotificationPermission(),
        'notification permission request',
      ));
      await wallet.initialize();
      final prefs = await SharedPreferences.getInstance();
      final selectedCountry = prefs.getString('selected_country');
      final selectedCurrency = prefs.getString('selected_currency');

      if (!mounted) return;
      if (selectedCountry == null || selectedCurrency == null) {
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
              _celebrateWelcomeReward = true;
            },
          ),
        );
      }

      await minimumSplashTime;
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_celebrateWelcomeReward) _initialTab = 1;
      });
    } catch (error) {
      await minimumSplashTime;
      if (!mounted) return;
      setState(() {
        _startupError = error;
        _loading = false;
      });
    }
  }

  Future<void> _runBackgroundStartupTask(
    Future<void> task,
    String description,
  ) async {
    try {
      await task;
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'app startup',
        context: ErrorDescription('while running $description'),
      ));
    }
  }

  Future<void> _deleteAccount() async {
    final wallet = context.read<Wallet>();
    try {
      await widget.startupService.signOut();
      await wallet.clearLocalData();
      if (!mounted) return;
      _initialTab = 0;
      _celebrateWelcomeReward = false;
      await _bootstrap();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _startupError = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _SplashScreen();
    }
    if (_startupError != null) {
      return _StartupErrorScreen(
        error: _startupError!,
        onRetry: _bootstrap,
      );
    }

    return MainShell(
      initialTab: _initialTab,
      celebrateWelcomeReward: _celebrateWelcomeReward,
      onDeleteAccount: _deleteAccount,
      videoLoader: widget.videoLoader,
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: AppColors.gold, size: 44),
              const SizedBox(height: 16),
              const Text(
                'Unable to start ReelsPay',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textDim,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.28),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.onGold,
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Reels',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Pay',
                          style: TextStyle(color: AppColors.gold),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Watch stories. Earn rewards.',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),

                  SizedBox(height: 28),

                  SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: Colors.yellow,
                    strokeWidth: 2.6,
                  ))
                ],
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 28),
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: Colors.yellow,
                    strokeWidth: 2.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

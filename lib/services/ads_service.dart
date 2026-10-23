import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  AdsService._();

  static final AdsService instance = AdsService._();

  static const _androidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const _androidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosRewardedId = 'ca-app-pub-3940256099942544/1712485313';
  static const _iosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  Future<bool>? _rewardedLoad;
  Future<bool>? _interstitialLoad;
  bool _initialized = false;

  String get _rewardedId => defaultTargetPlatform == TargetPlatform.iOS
      ? _iosRewardedId
      : _androidRewardedId;

  String get _interstitialId => defaultTargetPlatform == TargetPlatform.iOS
      ? _iosInterstitialId
      : _androidInterstitialId;

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    unawaited(_loadRewarded().then<void>((_) {}));
    unawaited(_loadInterstitial().then<void>((_) {}));
  }

  Future<bool> showRewardedOrInterstitial() async {
    try {
      if (!_initialized) await initialize();
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Failed to initialize Google Mobile Ads: $error\n$stackTrace');
      return false;
    }

    if (_rewardedAd == null) {
      await _loadRewarded().timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );
    }
    final rewarded = _rewardedAd;
    if (rewarded != null) {
      _rewardedAd = null;
      final result = Completer<bool>();
      var rewardEarned = false;
      rewarded.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          unawaited(_loadRewarded().then<void>((_) {}));
          if (!result.isCompleted) result.complete(rewardEarned);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Failed to show rewarded ad: $error');
          ad.dispose();
          unawaited(_loadRewarded().then<void>((_) {}));
          if (!result.isCompleted) result.complete(false);
        },
      );
      try {
        await rewarded.show(
          onUserEarnedReward: (ad, reward) => rewardEarned = true,
        );
      } on PlatformException catch (error, stackTrace) {
        debugPrint('Failed to show rewarded ad: $error\n$stackTrace');
        rewarded.dispose();
        unawaited(_loadRewarded().then<void>((_) {}));
        if (!result.isCompleted) result.complete(false);
      }
      return result.future;
    }

    if (_interstitialAd == null) {
      await _loadInterstitial().timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );
    }
    final interstitial = _interstitialAd;
    if (interstitial == null) return false;

    _interstitialAd = null;
    final result = Completer<bool>();
    interstitial.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(_loadInterstitial().then<void>((_) {}));
        if (!result.isCompleted) result.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Failed to show interstitial ad: $error');
        ad.dispose();
        unawaited(_loadInterstitial().then<void>((_) {}));
        if (!result.isCompleted) result.complete(false);
      },
    );
    try {
      await interstitial.show();
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Failed to show interstitial ad: $error\n$stackTrace');
      interstitial.dispose();
      unawaited(_loadInterstitial().then<void>((_) {}));
      if (!result.isCompleted) result.complete(false);
    }
    return result.future;
  }

  Future<bool> _loadRewarded() {
    if (_rewardedAd != null) return Future.value(true);
    if (_rewardedLoad != null) return _rewardedLoad!;

    final completer = Completer<bool>();
    _rewardedLoad = completer.future;
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoad = null;
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedLoad = null;
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );
    return completer.future;
  }

  Future<bool> _loadInterstitial() {
    if (_interstitialAd != null) return Future.value(true);
    if (_interstitialLoad != null) return _interstitialLoad!;

    final completer = Completer<bool>();
    _interstitialLoad = completer.future;
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoad = null;
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _interstitialLoad = null;
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );
    return completer.future;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models.dart';
import '../../providers/wallet.dart';
import '../../services/ads_service.dart';
import '../../services/currency_service.dart';
import '../../theme/app_theme.dart';
import '../../utils.dart';
import '../../widgets/balance_chip.dart';
import '../../widgets/coin_fly.dart';
import '../../widgets/snack.dart';
import 'double_reward_dialog.dart';
import 'reel_video_tile.dart';

/// Vertical fullscreen reels feed.
///
/// Reward loop (per the product spec):
///  * First video is visible immediately with its episode number;
///    tapping starts playback (and starts the earning session).
///  * Swipe up/down to move to the next episode — the video that enters the
///    viewport starts playing automatically once the session has started.
///  * Every 20 seconds of watching: USD 0.20 equivalent is credited and banknotes fly from
///    the screen edges into the balance chip.
///  * Every 60 seconds: a dialog offers "Double it (watch ad)" or
///    "Keep watching".
class ReelsScreen extends StatefulWidget {
  const ReelsScreen({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.autoStart = false,
    this.enabled = true,
    this.showBackButton = true,
    this.title,
    this.onItemTap,
  });

  final List<FeedItem> items;
  final int initialIndex;
  final bool autoStart;
  final bool enabled;
  final bool showBackButton;
  final String? title;
  final Future<void> Function(FeedItem)? onItemTap;

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  static const int _rewardEvery = 20; // seconds of watching per payout
  static const int _boostEvery = 60; // seconds per double-or-continue dialog
  static const double _usdReward = 0.20;

  late final PageController _pageController;
  final GlobalKey _balanceKey = GlobalKey();
  final CashFlyController _cashFly = CashFlyController();

  late bool _started;
  bool _blocked = false; // dialog / ad on screen
  bool _appPaused = false; // app in background

  int _index = 0;
  int _watched = 0; // seconds watched this session
  int _cycle = 0; // seconds since last boost dialog
  num _cycleCash = 0; // earned since last boost dialog
  int _consecutiveKeepChoices = 0;
  String _flash = '';
  int _flashId = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _started = widget.autoStart;
    _index = widget.initialIndex < 0
        ? 0
        : (widget.initialIndex >= widget.items.length
            ? widget.items.length - 1
            : widget.initialIndex);
    _pageController = PageController(initialPage: _index);
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _pageController.dispose();
    _cashFly.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    setState(() => _appPaused = state != AppLifecycleState.resumed);
  }

  bool get _watching => _started && widget.enabled && !_blocked && !_appPaused;

  FeedItem get _current => widget.items[_index];

  void _onTick() {
    if (!_watching) return;
    _watched += 1;
    _cycle += 1;
    context.read<Wallet>().addWatchSeconds(1);

    if (_watched % _rewardEvery == 0) {
      _payout();
    }
    if (_cycle >= _boostEvery) {
      _cycle = 0;
      _openBoostDialog();
    }
    if (mounted) setState(() {}); // refresh the countdown HUD
  }

  void _payout() {
    final localAmount = CurrencyService.convertUsdToCurrency(
      _usdReward,
      CurrencyService.currentCurrencyCode,
    );
    context.read<Wallet>().earn(
          localAmount,
          'Watched "${_current.drama.title}" · EP${_current.ep}',
          kind: TxKind.watch,
        );
    _cycleCash += localAmount;
    _flyCash();
    _flashLabel(
        '+${CurrencyService.formatAmount(localAmount, CurrencyService.currentCurrencyCode)}');
  }

  void _flyCash() {
    final size = MediaQuery.of(context).size;
    Offset end = Offset(size.width - 46, 66);
    final box = _balanceKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      end = box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
    }
    _cashFly.burst(
      end: end,
      screenWidth: size.width,
      screenHeight: size.height,
      count: 9,
    );
  }

  void _flashLabel(String text) {
    if (!mounted) return;
    setState(() {
      _flash = text;
      _flashId += 1;
    });
  }

  Future<void> _openBoostDialog() async {
    if (!mounted) return;
    setState(() => _blocked = true);

    final doubled = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => DoubleRewardDialog(coins: _cycleCash),
    );

    if (!mounted) return;
    if (doubled == true) {
      context
          .read<Wallet>()
          .earn(_cycleCash, 'Doubled your earnings', kind: TxKind.doubleReward);
      _consecutiveKeepChoices = 0;
      _flyCash();
      _flashLabel(
          '+${CurrencyService.formatAmount(_cycleCash, CurrencyService.currentCurrencyCode)} doubled!');
    } else {
      _consecutiveKeepChoices += 1;
      if (_consecutiveKeepChoices >= 3) {
        final completed =
            await AdsService.instance.showRewardedOrInterstitial();
        if (!mounted) return;
        if (completed) {
          context.read<Wallet>().earnUsd(
                _usdReward,
                'Keep-watching ad reward',
                kind: TxKind.watch,
              );
          _consecutiveKeepChoices = 0;
          _flyCash();
          final amount = CurrencyService.convertUsdToCurrency(
            _usdReward,
            CurrencyService.currentCurrencyCode,
          );
          _flashLabel(
              '+${CurrencyService.formatAmount(amount, CurrencyService.currentCurrencyCode)}');
        } else {
          _consecutiveKeepChoices = 2;
          showSnack(context, 'No ad is available right now. Please try again.');
        }
      }
    }
    _cycleCash = 0;
    setState(() => _blocked = false);
  }

  void _handleUserStart() {
    setState(() => _started = true);
  }

  Future<void> _handleItemTap(FeedItem item) async {
    final onItemTap = widget.onItemTap;
    if (onItemTap == null || _blocked) return;
    setState(() => _blocked = true);
    try {
      await onItemTap(item);
    } finally {
      if (mounted) setState(() => _blocked = false);
    }
  }

  int get _remaining {
    return _rewardEvery - (_watched % _rewardEvery);
  }

  @override
  Widget build(BuildContext context) {
    final sameDrama =
        widget.items.every((it) => it.drama.id == widget.items.first.drama.id);
    final topTitle =
        widget.title ?? (sameDrama ? _current.drama.title : 'For You');

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final item = widget.items[i];
              return ReelVideoTile(
                key: ValueKey<String>(item.key),
                item: item,
                isActive: i == _index && widget.enabled,
                sessionStarted: _started,
                blocked: _blocked || _appPaused || !widget.enabled,
                onUserStart: _handleUserStart,
                onItemTap: widget.onItemTap == null
                    ? null
                    : () => _handleItemTap(item),
              );
            },
          ),

          // Top scrim.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 130,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ),

          // Top bar: back · title · balance chip, plus reward-countdown HUD.
          SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      if (widget.showBackButton)
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 20, color: Colors.white),
                        )
                      else
                        const SizedBox(width: 48),
                      Expanded(
                        child: Text(
                          topTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      BalanceChip(targetKey: _balanceKey),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _RewardHud(
                  progress: 1.0 - _remaining / _rewardEvery,
                  secondsLabel: '$_remaining',
                  watching: _watching,
                ),
              ],
            ),
          ),

          // Floating '+$x' flash under the HUD.
          if (_flash.isNotEmpty)
            Positioned(
              top: 156,
              left: 0,
              right: 0,
              child: _FlashLabel(
                key: ValueKey<int>(_flashId),
                text: _flash,
              ),
            ),

          // Banknotes flying into the balance chip.
          Positioned.fill(child: CashFlyLayer(controller: _cashFly)),

          // Dimmed while the boost dialog / ad is open.
          if (_blocked)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(color: AppColors.gold),
                      SizedBox(height: 12),
                      Text(
                        'Earning paused…',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RewardHud extends StatelessWidget {
  const _RewardHud({
    required this.progress,
    required this.secondsLabel,
    required this.watching,
  });

  final double progress;
  final String secondsLabel;
  final bool watching;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              value: watching ? progress : 0,
              strokeWidth: 2.2,
              color: AppColors.gold,
              backgroundColor: Colors.white24,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            watching
                ? '+${rewardText()} in ${secondsLabel}s'
                : 'Tap to start earning',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashLabel extends StatefulWidget {
  const _FlashLabel({super.key, required this.text});

  final String text;

  @override
  State<_FlashLabel> createState() => _FlashLabelState();
}

class _FlashLabelState extends State<_FlashLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_controller.value);
        final fade = _controller.value < 0.7
            ? 1.0
            : 1.0 - (_controller.value - 0.7) / 0.3;
        return Opacity(
          opacity: fade,
          child: Transform.translate(
            offset: Offset(0, -26 * t),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.5),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: AppColors.onGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models.dart';
import '../../theme/app_theme.dart';
import '../../utils.dart';
import '../../widgets/snack.dart';

/// One fullscreen page of the vertical reels feed.
///
/// Behaviour:
///  * Shows the poster with a spinner while the video initializes.
///  * If the session has not started yet, shows the "EPISODE n / total" badge
///    and a big play button — the user must tap to start watching.
///  * Once the session is started, the video plays automatically whenever the
///    tile becomes the active page (and pauses when it leaves the viewport,
///    when the boost dialog opens, or when the app goes to the background).
///  * Tap toggles play/pause. Clips loop, short-drama style.
class ReelVideoTile extends StatefulWidget {
  const ReelVideoTile({
    super.key,
    required this.item,
    required this.isActive,
    required this.sessionStarted,
    required this.blocked,
    required this.onUserStart,
    this.onItemTap,
  });

  final FeedItem item;
  final bool isActive;
  final bool sessionStarted;
  final bool blocked;
  final VoidCallback onUserStart;
  final VoidCallback? onItemTap;

  @override
  State<ReelVideoTile> createState() => _ReelVideoTileState();
}

class _ReelVideoTileState extends State<ReelVideoTile> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _initVideo();
  }

  @override
  void didUpdateWidget(covariant ReelVideoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initVideo();
    } else if (!widget.isActive && oldWidget.isActive) {
      _pause();
    } else if (widget.isActive) {
      if (widget.blocked) {
        _pause();
      } else {
        _sync();
      }
    }
  }

  Future<void> _initVideo() async {
    if (_controller != null) {
      _sync();
      return;
    }
    final controller = VideoPlayerController.asset(widget.item.clip);
    _controller = controller;
    try {
      await controller.initialize();
    } catch (_) {
      if (!mounted || !identical(_controller, controller)) return;
      setState(() => _failed = true);
      return;
    }
    if (!mounted || !identical(_controller, controller)) {
      try {
        await controller.dispose();
      } catch (_) {}
      return;
    }
    await controller.setLooping(true);
    if (!mounted || !identical(_controller, controller)) return;
    setState(() => _initialized = true);
    _sync();
  }

  void _sync() {
    final c = _controller;
    if (c == null || !_initialized || !c.value.isInitialized) return;
    final shouldPlay =
        widget.isActive && widget.sessionStarted && !widget.blocked;
    if (shouldPlay && !c.value.isPlaying) {
      c.play();
    } else if (!shouldPlay && c.value.isPlaying) {
      c.pause();
    }
  }

  void _pause() {
    final c = _controller;
    if (c != null && c.value.isPlaying) c.pause();
  }

  void _handleTap() {
    if (_failed) return;
    final onItemTap = widget.onItemTap;
    if (onItemTap != null) {
      onItemTap();
      return;
    }
    final c = _controller;
    if (!widget.sessionStarted) {
      widget.onUserStart();
      return;
    }
    if (c == null ||
        !c.value.isInitialized ||
        !widget.isActive ||
        widget.blocked) {
      return;
    }
    if (c.value.isPlaying) {
      c.pause();
    } else {
      c.play();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    final c = _controller;
    _controller = null;
    c?.dispose();
    super.dispose();
  }

  double get _progress {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return 0;
    final total = c.value.duration.inMilliseconds;
    if (total <= 0) return 0;
    return (c.value.position.inMilliseconds / total).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final ready =
        _controller != null && _initialized && _controller!.value.isInitialized;
    final size = ready ? _controller!.value.size : Size.zero;
    final vw = size.width <= 0 ? 720.0 : size.width;
    final vh = size.height <= 0 ? 1280.0 : size.height;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Poster placeholder (also visible behind the video while loading).
          _PosterPlaceholder(
              item: widget.item, failed: _failed, loading: !ready),

          if (ready)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: vw,
                height: vh,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            const SizedBox.shrink(),

          // Bottom scrim for readability.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 220,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tap-to-start overlay (episode number + play button).
          if (widget.isActive && !widget.sessionStarted)
            _TapToStart(item: widget.item),

          // Paused indicator.
          if (widget.isActive &&
              widget.sessionStarted &&
              !widget.blocked &&
              ready &&
              !_controller!.value.isPlaying)
            const Center(
              child: Icon(Icons.play_arrow_rounded,
                  size: 88, color: Colors.white70),
            ),

          // Right action rail.
          Positioned(
              right: 10, bottom: 120, child: _SideRail(item: widget.item)),

          // Bottom info: EP badge, title, episode name, progress bar.
          Positioned(
            left: 16,
            right: 74,
            bottom: 26,
            child: _BottomInfo(item: widget.item, progress: _progress),
          ),
        ],
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({
    required this.item,
    required this.failed,
    required this.loading,
  });

  final FeedItem item;
  final bool failed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(item.drama.poster, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.35),
                Colors.black.withOpacity(0.55),
              ],
            ),
          ),
        ),
        if (failed)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: Colors.white70, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Could not load this episode',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else if (loading)
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                    color: AppColors.gold, strokeWidth: 2.4),
                SizedBox(height: 12),
                Text(
                  'Loading episode…',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TapToStart extends StatelessWidget {
  const _TapToStart({required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'EPISODE ${item.ep} / ${item.drama.episodes}',
                style: const TextStyle(
                  color: AppColors.onGold,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                item.drama.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 30),
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  size: 52, color: AppColors.onGold),
            ),
            const SizedBox(height: 18),
            const Text(
              'Tap to watch & earn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Earn \$5–\$9 every 20 seconds of watching',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final d = item.drama;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RailButton(
          icon: Icons.favorite_rounded,
          label: compactCount(d.likes),
          onTap: () => showSnack(context, 'Liked ❤️'),
        ),
        const SizedBox(height: 16),
        _RailButton(
          icon: Icons.chat_bubble_rounded,
          label: compactCount(d.comments),
          onTap: () => showSnack(context, 'Comments · coming soon'),
        ),
        const SizedBox(height: 16),
        _RailButton(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () => showSnack(context, 'Share · coming soon'),
        ),
        const SizedBox(height: 16),
        _RailButton(
          icon: Icons.card_giftcard_rounded,
          label: 'Gift',
          onTap: () => showSnack(context, 'Send a gift · coming soon'),
        ),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.35),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: 23),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomInfo extends StatelessWidget {
  const _BottomInfo({required this.item, required this.progress});

  final FeedItem item;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final d = item.drama;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.22),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.gold.withOpacity(0.55)),
              ),
              child: Text(
                'EP ${item.ep}/${d.episodes}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ...d.tags.take(2).map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      '#$t',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          d.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: Colors.white24,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}

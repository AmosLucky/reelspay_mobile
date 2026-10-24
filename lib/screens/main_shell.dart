import 'dart:async';

import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models.dart';
import '../services/videos_service.dart';
import '../theme/app_theme.dart';
import 'earning_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'reels/reels_screen.dart';

/// Bottom navigation shell: Home | Reels | Earning | Profile.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    this.initialTab = 0,
    this.celebrateWelcomeReward = false,
    this.onDeleteAccount,
    this.videoLoader,
  });

  final int initialTab;
  final bool celebrateWelcomeReward;
  final Future<void> Function()? onDeleteAccount;
  final VideoLoader? videoLoader;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _tab = widget.initialTab;
  late final VideosService? _ownedVideosService =
      widget.videoLoader == null ? VideosService() : null;
  List<ApiVideo> _videos = const [];
  Object? _videosError;
  bool _loadingVideos = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadVideos());
  }

  @override
  void dispose() {
    _ownedVideosService?.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _loadingVideos = true;
      _videosError = null;
    });
    try {
      final videos = await (widget.videoLoader?.call() ??
          _ownedVideosService!.fetchVideos());
      if (videos.isEmpty) {
        throw const FormatException('The videos API returned no videos.');
      }
      if (!mounted) return;
      setState(() {
        _videos = videos;
        _loadingVideos = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _videosError = error;
        _loadingVideos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loadingVideos || _videosError != null
          ? _VideosLoadState(
              loading: _loadingVideos,
              error: _videosError,
              onRetry: _loadVideos,
            )
          : IndexedStack(
              index: _tab,
              children: [
                HomeScreen(
                  videos: buildCollectionPreviews(_videos),
                  onVideoTap: _openVideo,
                ),
                ReelsScreen(
                  items: buildVideoPreviewFeed(_videos),
                  autoStart: true,
                  enabled: _tab == 1,
                  showBackButton: false,
                  title: 'Reels',
                  celebrateWelcomeReward: widget.celebrateWelcomeReward,
                  onItemTap: (item) => _openVideo(item.video),
                ),
                const EarningScreen(),
                ProfileScreen(onDeleteAccount: widget.onDeleteAccount),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.gold),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline_rounded),
            selectedIcon:
                Icon(Icons.play_circle_fill_rounded, color: AppColors.gold),
            label: 'Reels',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings_rounded, color: AppColors.gold),
            label: 'Earning',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.gold),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _openVideo(ApiVideo video) async {
    final items = buildVideoFeed(_videos, video);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => ReelsScreen(
          items: items,
          initialIndex: items.indexWhere((item) => item.video.id == video.id),
          autoStart: true,
          title: video.collectionTitle ?? video.author,
        ),
      ),
    );
  }
}

class _VideosLoadState extends StatelessWidget {
  const _VideosLoadState({
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final bool loading;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const CircularProgressIndicator(color: AppColors.gold)
            else ...[
              const Icon(Icons.cloud_off_rounded,
                  color: AppColors.textDim, size: 42),
              const SizedBox(height: 14),
              const Text(
                'Could not load videos',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textDim, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

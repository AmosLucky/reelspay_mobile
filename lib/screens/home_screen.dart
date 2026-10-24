import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../utils.dart';
import '../widgets/balance_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.videos,
    required this.onVideoTap,
  });

  final List<ApiVideo> videos;
  final Future<void> Function(ApiVideo) onVideoTap;

  @override
  Widget build(BuildContext context) {
    final trending = buildTrendingVideos(videos);
    final forYou = buildForYouVideos(videos);
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _Header()),
          SliverToBoxAdapter(
            child: _WatchEarnBanner(
              onTap: () {
                if (videos.isNotEmpty) onVideoTap(videos.first);
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: _SectionHeader(title: '🔥 Trending Now'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: trending.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _FeaturedCard(
                  video: trending[index],
                  onTap: () => onVideoTap(trending[index]),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: _SectionHeader(title: 'For You'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _VideoCard(
                  video: forYou[index],
                  onTap: () => onVideoTap(forYou[index]),
                ),
                childCount: forYou.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Reels',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const TextSpan(
                      text: 'Pay',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Watch videos · Earn rewards',
                style: TextStyle(color: AppColors.textDim, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          const BalanceChip(),
        ],
      ),
    );
  }
}

class _WatchEarnBanner extends StatelessWidget {
  const _WatchEarnBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB020).withOpacity(0.35),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.play_circle_fill_rounded,
                  size: 44, color: AppColors.onGold),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Watching & Earning',
                      style: TextStyle(
                        color: AppColors.onGold,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Watch videos and earn rewards',
                      style: TextStyle(
                        color: Color(0xFF5C4400),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.onGold),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.video, required this.onTap});

  final ApiVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.stroke),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _VideoThumbnail(
                url: video.collectionCoverUrl ?? video.thumbnailUrl,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.collectionTitle ?? video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${video.collectionEpisodeCount ?? 1} episodes · @${video.author}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.onTap});

  final ApiVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _VideoThumbnail(
                    url: video.collectionCoverUrl ?? video.thumbnailUrl,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _CountBadge(
                      count: '${video.collectionEpisodeCount ?? 1} EP',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            video.collectionTitle ?? video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Text(
                  '@${video.author}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: AppColors.textDim, fontSize: 11),
                ),
              ),
              const Icon(Icons.favorite_rounded,
                  size: 12, color: AppColors.gold),
              const SizedBox(width: 3),
              Text(
                compactCount(video.likes),
                style: const TextStyle(color: AppColors.textDim, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const ColoredBox(
        color: AppColors.card,
        child: Center(
          child: Icon(Icons.play_circle_outline_rounded,
              color: AppColors.textDim, size: 44),
        ),
      );
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: AppColors.card,
        child: Center(
          child: Icon(Icons.broken_image_outlined,
              color: AppColors.textDim, size: 36),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count views',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

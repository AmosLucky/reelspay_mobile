import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../utils.dart';
import '../widgets/balance_chip.dart';
import '../widgets/snack.dart';
import 'reels/reels_screen.dart';

/// Home tab — shows different drama videos: featured carousel, category
/// chips and a poster grid. Tapping any video opens the vertical Reels feed.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _category = 'Top';

  List<Drama> get _filtered => _category == 'Top'
      ? dramas.toList()
      : dramas.where((d) => d.categories.contains(_category)).toList();

  void _openFeed(List<FeedItem> items) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ReelsScreen(items: items, autoStart: true),
    ));
  }

  void _openDrama(Drama drama) => _openFeed(buildDramaFeed(drama));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _Header()),
          SliverToBoxAdapter(
            child: _WatchEarnBanner(onTap: () => _openFeed(buildForYouFeed())),
          ),
          const SliverToBoxAdapter(
            child: _SectionHeader(title: '🔥 Trending Now', trailing: 'See all'),
          ),
          SliverToBoxAdapter(child: _FeaturedRow(onTap: _openDrama)),
          const SliverToBoxAdapter(child: _SectionHeader(title: 'Categories')),
          SliverToBoxAdapter(
            child: _CategoryChips(
              selected: _category,
              onSelected: (c) => setState(() => _category = c),
            ),
          ),
          SliverToBoxAdapter(
            child: _SectionHeader(title: _category == 'Top' ? 'For You' : _category),
          ),
          _DramaGrid(items: _filtered, onTap: _openDrama),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
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
                'Watch short dramas · Earn real cash',
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Watching & Earning',
                      style: TextStyle(
                        color: AppColors.onGold,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Earn ${rewardText()} every 20s · Double it every minute',
                      style: const TextStyle(
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
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            GestureDetector(
              onTap: () => showSnack(context, 'Prototype · see all coming soon'),
              child: Text(
                trailing!,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedRow extends StatelessWidget {
  const _FeaturedRow({required this.onTap});

  final void Function(Drama) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 208,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _FeaturedCard(
          drama: featured[i],
          onTap: () => onTap(featured[i]),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.drama, required this.onTap});

  final Drama drama;
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
              Image.asset(drama.poster, fit: BoxFit.cover),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
              ),
              if (drama.badge != null)
                Positioned(top: 10, left: 10, child: _Badge(label: drama.badge!)),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drama.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${drama.episodes} EPs · ${compactCount(drama.likes)} likes',
                      style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                      ),
                      child: const Text(
                        'Earn while watching',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isHot = label == 'hot';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isHot ? const Color(0xE6FF3D5C) : const Color(0xE68B5CF6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHot
                ? Icons.local_fire_department_rounded
                : Icons.fiber_new_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            isHot ? 'HOT' : 'NEW',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final String selected;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = categories[i];
          final active = c == selected;
          return GestureDetector(
            onTap: () => onSelected(c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.gold : AppColors.card,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: active ? AppColors.gold : AppColors.stroke),
              ),
              child: Text(
                c,
                style: TextStyle(
                  color: active ? AppColors.onGold : AppColors.textDim,
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DramaGrid extends StatelessWidget {
  const _DramaGrid({required this.items, required this.onTap});

  final List<Drama> items;
  final void Function(Drama) onTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 12,
          childAspectRatio: 0.58,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _DramaCard(
            drama: items[i],
            onTap: () => onTap(items[i]),
          ),
          childCount: items.length,
        ),
      ),
    );
  }
}

class _DramaCard extends StatelessWidget {
  const _DramaCard({required this.drama, required this.onTap});

  final Drama drama;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.stroke),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(drama.poster, fit: BoxFit.cover),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.black.withOpacity(0.45),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (drama.badge != null)
                      Positioned(top: 8, left: 8, child: _Badge(label: drama.badge!)),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${drama.episodes} EPs',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            drama.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.visibility_rounded, size: 12, color: AppColors.textDim),
              const SizedBox(width: 4),
              Text(
                compactCount(drama.likes),
                style: const TextStyle(color: AppColors.textDim, fontSize: 11),
              ),
              const Spacer(),
              const Icon(Icons.monetization_on_rounded, size: 12, color: AppColors.gold),
              const SizedBox(width: 3),
              const Text(
                '+\$5/20s',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

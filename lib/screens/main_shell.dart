import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../theme/app_theme.dart';
import 'earning_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'reels/reels_screen.dart';

/// Bottom navigation shell: Home | Reels | Earning | Profile.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          const HomeScreen(),
          ReelsScreen(
            items: buildMoviePreviewFeed(),
            autoStart: true,
            enabled: _tab == 1,
            showBackButton: false,
            title: 'Reels',
            onItemTap: (item) async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => ReelsScreen(items: buildDramaFeed(item.drama)),
                ),
              );
            },
          ),
          const EarningScreen(),
          const ProfileScreen(),
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
            selectedIcon: Icon(Icons.play_circle_fill_rounded, color: AppColors.gold),
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
}

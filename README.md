# ReelsPay 🎬💰

A **Flutter** prototype of a short-drama "watch & earn" app. Watch vertical
drama reels and earn real-looking cash rewards — **$5–$9 every 20 seconds** of
watching, with banknotes flying into your balance, and a **"Double it or keep
watching"** boost dialog every 60 seconds.

> 100% offline: all posters and demo video clips are bundled as assets.

## Features

| Spec | Where it lives |
|------|----------------|
| Bottom nav: **Home / Earning / Profile** | `lib/screens/main_shell.dart` |
| Home shows different videos (featured + grid, category filter) | `lib/screens/home_screen.dart` |
| Reels: first video visible with **episode number**, tap to start | `lib/screens/reels/reel_video_tile.dart` |
| Swipe up/down for next episode; the video in the viewport **auto-plays** | `lib/screens/reels/reels_screen.dart` + `reel_video_tile.dart` |
| **$5–$9 every 20s** with banknotes flying from the screen edge into the balance | `_payout()` in `reels_screen.dart` + `lib/widgets/coin_fly.dart` |
| **Every 60s**: dialog → "Watch Ad · Double It" or "Keep watching" | `lib/screens/reels/double_reward_dialog.dart` |
| Earning tab: balance, stats, daily tasks, transactions, withdraw sheet | `lib/screens/earning_screen.dart` |
| Profile tab: user card, stats, invite code, settings | `lib/screens/profile_screen.dart` |

## Project structure

```
reelspay/
├── pubspec.yaml                 # provider + video_player, bundled assets
├── assets/
│   ├── posters/                 # 10 AI-generated vertical drama posters
│   └── videos/                  # 5 bundled demo clips (offline)
├── lib/
│   ├── main.dart                # app entry + Wallet provider
│   ├── models.dart              # Drama, FeedItem
│   ├── utils.dart               # $ formatting, compact counts
│   ├── theme/app_theme.dart     # dark cinema theme (gold accents)
│   ├── data/catalog.dart        # 10-drama catalog + feed builders
│   ├── providers/wallet.dart    # balance / earn / withdraw / transactions
│   ├── widgets/
│   │   ├── balance_chip.dart    # pulsing $ balance pill (fly target)
│   │   ├── coin_fly.dart        # banknote flight animation system
│   │   └── snack.dart
│   └── screens/
│       ├── main_shell.dart      # bottom navigation
│       ├── home_screen.dart     # featured + categories + poster grid
│       ├── earning_screen.dart  # wallet, tasks, history, withdraw
│       ├── profile_screen.dart
│       └── reels/
│           ├── reels_screen.dart         # feed + 20s/60s reward timers
│           ├── reel_video_tile.dart      # player + overlays
│           └── double_reward_dialog.dart # double / keep watching
└── test/widget_test.dart
```

## Run it

You need Flutter **3.10+** installed (`flutter doctor` to verify).

```bash
cd reelspay

# 1. Generate the android/ios platform folders (won't touch existing code)
flutter create . --project-name reelspay --org com.reelspay

# 2. Fetch packages
flutter pub get

# 3. Run on a device or emulator
flutter run
```

Android release builds need nothing extra — the demo videos are bundled
assets, so no INTERNET permission is required.

## How the earning loop works

`_ReelsScreenState` runs a 1-second ticker that only counts while a video is
actually playing (paused during dialogs, ads, or when the app is backgrounded):

- `_watched % 20 == 0` → credit $5–$9, spray banknotes from the screen edges
  into the balance chip (via `CashFlyController.burst`), flash "+$x".
- `_cycle >= 60` → pause playback, open `DoubleRewardDialog` with the amount
  earned this cycle. "Watch Ad · Double It" plays a 3-second fake ad, then
  credits the same amount again; "Keep watching" resumes.

Tweak the economy in one place — the constants at the top of
`lib/screens/reels/reels_screen.dart`:

```dart
static const int _rewardEvery = 20;  // seconds per payout
static const int _boostEvery  = 60;  // seconds per dialog
static const int _minReward   = 5;   // $
static const int _maxReward   = 9;   // $
```

Starting balance, withdraw target and demo transactions live in
`lib/providers/wallet.dart`.

## Notes

- The drama catalog (10 titles, episode counts, posters, clip mapping) is in
  `lib/data/catalog.dart`. Episodes cycle through the 5 bundled clips — swap
  in real drama MP4s (network URLs via `VideoPlayerController.networkUrl` or
  bigger bundled files) when you have content.
- The "Watch Ad" flow is a placeholder `3…2…1` screen ready to be replaced by
  a real rewarded-ad SDK call (AdMob/ironSource).

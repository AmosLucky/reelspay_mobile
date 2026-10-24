import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reelspay/data/catalog.dart';
import 'package:reelspay/main.dart';
import 'package:reelspay/models.dart';
import 'package:reelspay/providers/wallet.dart';
import 'package:reelspay/screens/profile_screen.dart';
import 'package:reelspay/screens/profile_info_screen.dart';
import 'package:reelspay/services/currency_service.dart';
import 'package:reelspay/services/startup_service.dart';
import 'package:reelspay/services/videos_service.dart';

class _FakeStartupService implements StartupService {
  int anonymousSessionCalls = 0;
  int notificationPermissionCalls = 0;
  int signOutCalls = 0;

  @override
  Future<void> ensureAnonymousSession() async {
    anonymousSessionCalls += 1;
  }

  @override
  Future<void> requestNotificationPermission() async {
    notificationPermissionCalls += 1;
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }
}

List<ApiVideo> _testVideos() => const [
      ApiVideo(
        id: '6',
        title: 'Book of Enoch — Part 1',
        author: 'biblenutshells',
        videoUrl: 'https://reelspay.beamaxtech.com.ng/storage/video.mp4',
        collectionId: 'enoch',
        collectionTitle: 'Book of Enoch',
        collectionCoverUrl:
            'https://reelspay.beamaxtech.com.ng/storage/cover.jpg',
        collectionEpisodeCount: 2,
        episodeNumber: 1,
        views: 3450604,
        likes: 174936,
        comments: 86087,
      ),
      ApiVideo(
        id: '7',
        title: 'Book of Enoch — Part 2',
        author: 'biblenutshells',
        videoUrl: 'https://reelspay.beamaxtech.com.ng/storage/video2.mp4',
        collectionId: 'enoch',
        collectionTitle: 'Book of Enoch',
        collectionEpisodeCount: 2,
        episodeNumber: 2,
        views: 2860378,
        likes: 441249,
        comments: 25031,
      ),
    ];

void main() {
  test('country selector includes countries and currency defaults', () {
    expect(CurrencyService.countries.length, greaterThanOrEqualTo(240));
    expect(CurrencyService.countries.take(2), ['United States', 'Nigeria']);
    expect(CurrencyService.supportedCurrencies.take(2), ['USD', 'NGN']);
    expect(CurrencyService.countryDefaults['Faroe Islands'], 'DKK');
    expect(CurrencyService.countryDefaults['Andorra'], 'EUR');
    expect(CurrencyService.countryDefaults['Antarctica'], 'USD');
    expect(CurrencyService.countryDefaults['United States'], 'USD');
    expect(CurrencyService.supportedCurrencies, contains('ZWG'));
  });

  test('wallet earnings and transactions survive reinitialization', () async {
    SharedPreferences.setMockInitialValues({
      'selected_country': 'United States',
      'selected_currency': 'USD',
    });
    final wallet = Wallet();
    await wallet.initialize();
    await wallet.flushPersistence();

    wallet.earn(2.5, 'Watched a movie', kind: TxKind.watch);
    wallet.addWatchSeconds(20);
    wallet.savePaymentMethod(
      const PaymentMethod(
        type: PaymentMethodType.paypal,
        email: 'viewer@example.com',
      ),
    );
    await wallet.flushPersistence();

    final restoredWallet = Wallet();
    await restoredWallet.initialize();

    expect(restoredWallet.balance, 37.5);
    expect(restoredWallet.totalEarned, 37.5);
    expect(restoredWallet.todayEarned, 37.5);
    expect(restoredWallet.watchSeconds, 20);
    expect(restoredWallet.tx.first.label, 'Watched a movie');
    expect(restoredWallet.tx.first.amount, 2.5);
    expect(restoredWallet.paymentMethod?.email, 'viewer@example.com');
    await restoredWallet.flushPersistence();
  });

  test('first country selection awards a one-time 35 USD equivalent bonus',
      () async {
    SharedPreferences.setMockInitialValues({});
    final wallet = Wallet();
    await wallet.initialize();
    await wallet.applySelection(countryCode: 'Nigeria', currencyCode: 'NGN');

    expect(wallet.balance, closeTo(35 * 1334.99, 0.01));
    expect(wallet.totalEarned, closeTo(35 * 1334.99, 0.01));
    await wallet.flushPersistence();

    final restoredWallet = Wallet();
    await restoredWallet.initialize();
    expect(restoredWallet.balance, closeTo(35 * 1334.99, 0.01));
    expect(restoredWallet.tx.where((tx) => tx.label == 'Welcome bonus'),
        hasLength(1));
    await restoredWallet.flushPersistence();
  });

  test('delete local data clears the wallet, payment details, and preferences',
      () async {
    SharedPreferences.setMockInitialValues({
      'selected_country': 'United States',
      'selected_currency': 'USD',
    });
    final wallet = Wallet();
    await wallet.initialize();
    wallet.savePaymentMethod(
      const PaymentMethod(
        type: PaymentMethodType.paypal,
        email: 'viewer@example.com',
      ),
    );
    wallet.earn(5, 'Test reward');
    await wallet.flushPersistence();

    await wallet.clearLocalData();
    final prefs = await SharedPreferences.getInstance();

    expect(prefs.getKeys(), isEmpty);
    expect(wallet.balance, 0);
    expect(wallet.totalEarned, 0);
    expect(wallet.paymentMethod, isNull);
    expect(wallet.tx, isEmpty);
    expect(wallet.hasSetup, isFalse);
  });

  test('withdrawals require a payment method and the minimum balance',
      () async {
    SharedPreferences.setMockInitialValues({
      'selected_country': 'United States',
      'selected_currency': 'USD',
    });
    final wallet = Wallet();
    await wallet.initialize();

    expect(wallet.withdraw(Wallet.withdrawTarget), isFalse);

    wallet.savePaymentMethod(
      const PaymentMethod(
        type: PaymentMethodType.paypal,
        email: 'viewer@example.com',
      ),
    );
    expect(wallet.withdraw(Wallet.withdrawTarget), isFalse);

    wallet.earn(65, 'Additional earnings');
    final beforeWithdrawal = wallet.balance;
    expect(wallet.withdraw(Wallet.withdrawTarget), isTrue);
    expect(wallet.balance, beforeWithdrawal - Wallet.withdrawTarget);
    expect(wallet.withdrawals, hasLength(1));
    expect(wallet.withdrawals.first.paymentDueAt,
        wallet.withdrawals.first.at.add(const Duration(days: 14)));
    await wallet.flushPersistence();

    final restoredWallet = Wallet();
    await restoredWallet.initialize();
    expect(restoredWallet.withdrawals, hasLength(1));
    expect(restoredWallet.withdrawals.first.paymentDueAt,
        restoredWallet.withdrawals.first.at.add(const Duration(days: 14)));
    expect(restoredWallet.balance, 0);
    await restoredWallet.flushPersistence();
  });

  test('videos API parsing maps API fields and replaces local media hosts', () {
    const response = '''
      {
        "data": [{
          "id": 5,
          "title": "First video",
          "author": "creator",
          "thumbnail_url": "http://localhost:8000/storage/thumbnails/one.jpg",
          "video_url": "http://localhost:8000/storage/videos/one.mp4",
          "collection_id": null,
          "collection_title": null,
          "episode_number": null,
          "views_count": 12,
          "likes_count": 3,
          "comments_count": 2
        }],
        "next_page_url": null
      }
    ''';
    final page = VideosService.parsePage(response);
    final video = page.videos.single;

    expect(video.id, '5');
    expect(video.title, 'First video');
    expect(video.author, 'creator');
    expect(video.videoUrl,
        'https://reelspay.beamaxtech.com.ng/storage/videos/one.mp4');
    expect(video.thumbnailUrl,
        'https://reelspay.beamaxtech.com.ng/storage/thumbnails/one.jpg');
    expect(video.episodeNumber, isNull);
    expect(video.views, 12);
    expect(page.nextPage, isNull);
    expect(
      VideosService.normalizeMediaUrl('https://cdn.example.com/videos/one.mp4'),
      'https://cdn.example.com/videos/one.mp4',
    );
  });

  test('videos API parses collections and nested episodes', () {
    const response = '''
      {
        "data": [{
          "id": "enoch",
          "type": "collection",
          "title": "Book of Enoch",
          "collection_id": "enoch",
          "collection_title": "Book of Enoch",
          "cover_thumbnail_url": "http://localhost:8000/storage/cover.jpg",
          "episode_count": 2,
          "episodes": [
            {
              "id": 7,
              "title": "Part 2",
              "author": "creator",
              "thumbnail_url": "https://cdn.example.com/second.jpg",
              "video_url": "https://cdn.example.com/second.mp4",
              "episode_number": null,
              "views_count": 20
            },
            {
              "id": 6,
              "title": "Part 1",
              "author": "creator",
              "thumbnail": "http://localhost:8000/storage/first.jpg",
              "video_url": "http://localhost:8000/storage/first.mp4",
              "episode_number": null,
              "views_count": 10
            }
          ]
        }],
        "current_page": 1,
        "last_page": 1
      }
    ''';
    final page = VideosService.parsePage(response);
    expect(page.videos, hasLength(2));
    expect(page.videos.map((video) => video.id), ['6', '7']);
    expect(page.videos.map((video) => video.title), ['Part 1', 'Part 2']);
    expect(page.videos.map((video) => video.episodeNumber), [1, 2]);
    expect(page.videos.map((video) => video.collectionId), ['enoch', 'enoch']);
    expect(page.videos.first.collectionTitle, 'Book of Enoch');
    expect(page.videos.first.collectionEpisodeCount, 2);
    expect(
      page.videos.first.collectionCoverUrl,
      'https://reelspay.beamaxtech.com.ng/storage/cover.jpg',
    );
    expect(
      page.videos.first.thumbnailUrl,
      'https://reelspay.beamaxtech.com.ng/storage/first.jpg',
    );
    expect(
      page.videos.last.thumbnailUrl,
      'https://cdn.example.com/second.jpg',
    );
    expect(
        buildVideoPreviewFeed(page.videos).map((item) => item.video.id), ['6']);
    expect(
        buildVideoFeed(page.videos, page.videos.first)
            .map((item) => item.video.id),
        ['6', '7']);
  });

  test('video feeds use the selected video or its API collection', () {
    final videos = _testVideos();
    final selected = videos.last;
    final feed = buildVideoFeed(videos, selected);
    expect(feed.map((item) => item.video.id), ['6', '7']);

    final collectionVideos = [
      ...videos,
      ApiVideo(
        id: '8',
        title: 'Book of Enoch — Part 3',
        author: 'biblenutshells',
        videoUrl: 'https://example.com/three.mp4',
        collectionId: 'enoch',
        collectionTitle: 'Book of Enoch',
        episodeNumber: 3,
        views: 1,
        likes: 1,
        comments: 1,
      ),
      ApiVideo(
        id: '10',
        title: 'Chinese dance',
        author: 'kickflip_jype',
        videoUrl: 'https://example.com/dance.mp4',
        collectionId: 'dance',
        collectionTitle: 'Chinese dance',
        episodeNumber: 1,
        views: 1,
        likes: 1,
        comments: 1,
      ),
    ];
    expect(
      buildVideoFeed(collectionVideos, selected).map((item) => item.video.id),
      ['6', '7', '8', '10'],
    );
    expect(
      buildVideoPreviewFeed(collectionVideos).map((item) => item.video.id),
      ['6', '10'],
    );
    expect(
      buildVideoFeed(collectionVideos, collectionVideos.last)
          .map((item) => item.video.id),
      ['10', '6', '7', '8'],
    );
  });

  test('home trending and For You split safely for short lists', () {
    final videos = _testVideos();
    expect(buildTrendingVideos(videos), hasLength(2));
    expect(buildForYouVideos(videos), isEmpty);
    expect(buildTrendingVideos(videos.take(1).toList()), hasLength(1));
    expect(buildForYouVideos(videos.take(1).toList()), isEmpty);
    expect(buildTrendingVideos(<ApiVideo>[]), isEmpty);
    expect(buildForYouVideos(<ApiVideo>[]), isEmpty);

    final expandedVideos = [
      ...videos,
      ApiVideo(
        id: '8',
        title: 'Next movie',
        author: 'creator',
        videoUrl: 'https://example.com/next.mp4',
        views: 3,
        likes: 2,
        comments: 1,
      ),
    ];
    expect(
      buildTrendingVideos(expandedVideos).map((video) => video.id),
      ['6', '7'],
    );
    expect(
      buildForYouVideos(expandedVideos).map((video) => video.id),
      ['8'],
    );
  });

  testWidgets('ReelsPay boots to the Home tab', (tester) async {
    SharedPreferences.setMockInitialValues({
      'selected_country': 'United States',
      'selected_currency': 'USD',
    });
    final startupService = _FakeStartupService();
    await tester.pumpWidget(ReelsPayApp(
      startupService: startupService,
      videoLoader: () async => _testVideos(),
    ));
    await tester.pump();
    expect(find.text('Watch stories. Earn rewards.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.text('Start Watching & Earning'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.textContaining('Book of Enoch'), findsWidgets);
    expect(find.text('Crimson Night Kiss'), findsNothing);
    expect(find.text('Reels'), findsOneWidget);
    expect(find.text('Earning'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
    expect(startupService.anonymousSessionCalls, 1);
    expect(startupService.notificationPermissionCalls, 1);

    await tester.tap(find.text('Reels'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('EP 1 / 2'), findsOneWidget);
    expect(find.text('Book of Enoch — Part 1'), findsWidgets);

    await tester.tap(find.text('Earning').last);
    await tester.pump();
    expect(find.text('Add PayPal, crypto, or bank details'), findsOneWidget);
    expect(find.text('Watch 10 minutes today'), findsNothing);
    expect(find.text('Finish 3 episodes'), findsNothing);

    await tester.tap(find.textContaining('Withdraw at'));
    await tester.pump();
    expect(find.text('Add payment method'), findsOneWidget);
    expect(find.text('PayPal email'), findsOneWidget);
  });

  testWidgets('first country setup grants the welcome bonus and opens Reels',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ReelsPayApp(
        startupService: _FakeStartupService(),
        videoLoader: () async => _testVideos(),
      ),
    );
    await tester.pump();
    expect(find.text('Watch stories. Earn rewards.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.text('Choose your country & currency'), findsOneWidget);
    expect(find.textContaining('Welcome bonus: 35 USD'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text('EP 1 / 2'), findsOneWidget);
    expect(find.textContaining('welcome reward!'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets(
      'profile omits removed items and exposes About, Help, and Policies',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => Wallet(),
        child: const MaterialApp(
          home: Scaffold(body: ProfileScreen()),
        ),
      ),
    );
    expect(find.text('Watch History'), findsNothing);
    expect(find.text('Downloads'), findsNothing);
    expect(find.text('Push Notifications'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('About Us'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('About Us'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Help & Support'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Help & Support'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Delete Account'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Delete Account'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Terms, Privacy & Policies'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Terms, Privacy & Policies'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: ProfileInfoScreen(page: ProfileInfoPage.about)),
    );
    expect(find.text('Videos worth watching'), findsOneWidget);
    await tester.pumpWidget(
      const MaterialApp(home: ProfileInfoScreen(page: ProfileInfoPage.help)),
    );
    expect(find.text('support@reelspay.app'), findsOneWidget);
    await tester.pumpWidget(
      const MaterialApp(
          home: ProfileInfoScreen(page: ProfileInfoPage.policies)),
    );
    expect(find.text('Privacy notice'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Terms of use'), 250);
    expect(find.text('Terms of use'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

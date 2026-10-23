import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reelspay/data/catalog.dart';
import 'package:reelspay/main.dart';

void main() {
  test('movie preview feed contains episode one for every drama', () {
    final feed = buildMoviePreviewFeed();

    expect(feed, hasLength(dramas.length));
    expect(feed.every((item) => item.ep == 1), isTrue);
    expect(feed.map((item) => item.drama.id).toSet(), hasLength(dramas.length));
  });

  testWidgets('ReelsPay boots to the Home tab', (tester) async {
    SharedPreferences.setMockInitialValues({
      'selected_country': 'United States',
      'selected_currency': 'USD',
    });
    await tester.pumpWidget(const ReelsPayApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Start Watching & Earning'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Reels'), findsOneWidget);
    expect(find.text('Earning'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);

    await tester.tap(find.text('Reels'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('EP 1/49'), findsOneWidget);
  });
}

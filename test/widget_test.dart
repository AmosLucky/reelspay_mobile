import 'package:flutter_test/flutter_test.dart';
import 'package:reelspay/main.dart';

void main() {
  testWidgets('ReelsPay boots to the Home tab', (tester) async {
    await tester.pumpWidget(const ReelsPayApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Start Watching & Earning'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Earning'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}

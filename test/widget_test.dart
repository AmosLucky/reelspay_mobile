import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reelspay/data/catalog.dart';
import 'package:reelspay/main.dart';
import 'package:reelspay/providers/wallet.dart';

void main() {
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

    expect(restoredWallet.balance, 52.5);
    expect(restoredWallet.totalEarned, 52.5);
    expect(restoredWallet.todayEarned, 2.5);
    expect(restoredWallet.watchSeconds, 20);
    expect(restoredWallet.tx.first.label, 'Watched a movie');
    expect(restoredWallet.tx.first.amount, 2.5);
    expect(restoredWallet.paymentMethod?.email, 'viewer@example.com');
    await restoredWallet.flushPersistence();
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

    wallet.earn(50, 'Additional earnings');
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
}

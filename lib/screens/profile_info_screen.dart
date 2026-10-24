import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/snack.dart';

enum ProfileInfoPage { about, help, policies }

class ProfileInfoScreen extends StatelessWidget {
  const ProfileInfoScreen({super.key, required this.page});

  final ProfileInfoPage page;

  String get _title => switch (page) {
        ProfileInfoPage.about => 'About Us',
        ProfileInfoPage.help => 'Help & Support',
        ProfileInfoPage.policies => 'Terms, Privacy & Policies',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: switch (page) {
            ProfileInfoPage.about => _aboutContent,
            ProfileInfoPage.help => _helpContent(context),
            ProfileInfoPage.policies => _policyContent,
          },
        ),
      ),
    );
  }

  List<Widget> get _aboutContent => const [
        _InfoCard(
          title: 'Videos worth watching',
          body:
              'ReelsPay is an entertainment app for discovering videos from our online catalog and keeping track of in-app rewards. Browse the Home or Reels feed, watch a video, and open its collection when more episodes are available.',
          icon: Icons.movie_filter_rounded,
        ),
        SizedBox(height: 12),
        _InfoCard(
          title: 'Rewards',
          body:
              'The wallet and reward features show your in-app activity and balances. Reward rates, availability, and eligibility may change. A displayed balance or pending withdrawal is not a promise that a payment has been sent.',
          icon: Icons.account_balance_wallet_rounded,
        ),
      ];

  List<Widget> _helpContent(BuildContext context) => [
        const _InfoCard(
          title: 'How can we help?',
          body:
              'For app, wallet, or account-data questions, contact our support team. Include a description of the issue and your app version. Do not send passwords or full payment credentials by email.',
          icon: Icons.support_agent_rounded,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email support',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                'support@reelspay.app',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: 'support@reelspay.app'),
                    );
                    if (context.mounted) {
                      showSnack(context, 'Support email copied');
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy email'),
                ),
              ),
            ],
          ),
        ),
      ];

  List<Widget> get _policyContent => const [
        _InfoCard(
          title: 'Privacy notice',
          body:
              'ReelsPay currently saves app data on your device using local app storage. This may include your selected country and currency, wallet balance and reward totals, watch time, transaction history, and the payout details you choose to enter. This prototype does not create an online user account or sync this information to a ReelsPay server. Local app storage is not a secure vault; anyone with access to your unlocked device or its app data may be able to access it. Do not enter sensitive payment details unless you are comfortable storing them on this device.',
          icon: Icons.privacy_tip_outlined,
        ),
        SizedBox(height: 12),
        _InfoCard(
          title: 'Payment information',
          body:
              'Payment methods are saved locally so the app can display them with your withdrawal request. The current app records withdrawal requests locally and is not connected to a payment processor; it does not transmit payment details to PayPal, a bank, or a crypto network. A pending status or expected date is informational only and does not mean a payment is being processed or guaranteed.',
          icon: Icons.payments_outlined,
        ),
        SizedBox(height: 12),
        _InfoCard(
          title: 'Your choices and data deletion',
          body:
              'You can review your stored wallet and payment-method information in the app. Use Delete Account in Profile to clear local app preferences, payment details, wallet data, and transaction history from this installation, then restart setup. Uninstalling the app also removes app-local data, subject to your device settings and backups. Deletion cannot remove information that you separately shared outside this app.',
          icon: Icons.delete_outline_rounded,
        ),
        SizedBox(height: 12),
        _InfoCard(
          title: 'Terms of use',
          body:
              'Use ReelsPay lawfully and do not attempt to manipulate video viewing, rewards, or withdrawal records. Rewards and balances are in-app records, may be adjusted to correct errors or abuse, and have no cash value unless and until an authorized payment service is made available and a payment is approved. Withdrawal thresholds, processing estimates, content, and features may change. You are responsible for keeping access to your device private and for providing accurate information if a legitimate payout process becomes available. The app and its prototype features are provided as available, without a guarantee of uninterrupted service or earnings.',
          icon: Icons.gavel_rounded,
        ),
        SizedBox(height: 12),
        _InfoCard(
          title: 'Contact',
          body:
              'Questions about these terms or privacy practices can be sent to support@reelspay.app. These notices describe the current app behavior and should be updated if online accounts, analytics, or payment processing are added.',
          icon: Icons.mail_outline_rounded,
        ),
      ];
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

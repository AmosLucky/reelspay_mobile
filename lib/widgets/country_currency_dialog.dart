import 'package:flutter/material.dart';

import '../services/currency_service.dart';

class CountryCurrencyDialog extends StatefulWidget {
  const CountryCurrencyDialog({
    super.key,
    required this.initialCountry,
    required this.initialCurrency,
    required this.onSubmit,
    this.allowCancel = true,
  });

  final String initialCountry;
  final String initialCurrency;
  final Future<void> Function(String country, String currency) onSubmit;
  final bool allowCancel;

  @override
  State<CountryCurrencyDialog> createState() => _CountryCurrencyDialogState();
}

class _CountryCurrencyDialogState extends State<CountryCurrencyDialog> {
  late String _country = widget.initialCountry;
  late String _currency = widget.initialCurrency;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Choose your country & currency',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _country,
              dropdownColor: const Color(0xFF1C1C1E),
              decoration: const InputDecoration(
                labelText: 'Country',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              items: CurrencyService.countries
                  .map((country) => DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _country = value;
                  _currency = CurrencyService.countryDefaults[value] ?? _currency;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              dropdownColor: const Color(0xFF1C1C1E),
              decoration: const InputDecoration(
                labelText: 'Currency',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              items: CurrencyService.supportedCurrencies
                  .map((currency) => DropdownMenuItem<String>(
                        value: currency,
                        child: Text('$currency (${CurrencyService.symbols[currency] ?? currency})'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _currency = value);
                }
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome bonus: 50 USD = ${CurrencyService.formatAmount(
                  CurrencyService.convertUsdToCurrency(50, _currency).round(),
                  _currency,
                )}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.allowCancel)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE0A93B),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            await widget.onSubmit(_country, _currency);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

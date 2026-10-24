import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
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
  final AudioPlayer _saveSound = AudioPlayer();
  late String _country = widget.initialCountry;
  late String _currency = widget.initialCurrency;

  @override
  void dispose() {
    unawaited(_saveSound.dispose());
    super.dispose();
  }

  Future<void> _playSaveSound() async {
    try {
      await _saveSound.play(AssetSource('audio/cashout.wav'));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'country selection sound',
        context: ErrorDescription('while playing the selection confirmation'),
      ));
    }
  }

  Future<void> _saveSelection() async {
    unawaited(_playSaveSound());
    await widget.onSubmit(_country, _currency);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF121212),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Color(0xFF121212),
            ),
          ),
          const ColoredBox(color: Color(0x99000000)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xE6121212),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Choose your country & currency',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                            initialValue: _country,
                            isExpanded: true,
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
                                _currency =
                                    CurrencyService.countryDefaults[value] ??
                                        'USD';
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _currency,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1C1C1E),
                            decoration: const InputDecoration(
                              labelText: 'Currency',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white),
                            items: CurrencyService.supportedCurrencies
                                .map((currency) => DropdownMenuItem<String>(
                                      value: currency,
                                      child: Text(
                                        '$currency (${CurrencyService.symbols[currency] ?? currency})',
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _currency = value);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Welcome bonus: 35 USD = ${CurrencyService.formatAmount(
                              CurrencyService.convertUsdToCurrency(
                                      35, _currency)
                                  .round(),
                              _currency,
                            )}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.allowCancel) ...[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Later'),
                                ),
                                const SizedBox(width: 8),
                              ],
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE0A93B),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _saveSelection,
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

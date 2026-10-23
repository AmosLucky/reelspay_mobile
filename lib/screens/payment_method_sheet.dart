import 'package:flutter/material.dart';

import '../providers/wallet.dart';
import '../theme/app_theme.dart';

class PaymentMethodSheet extends StatefulWidget {
  const PaymentMethodSheet({super.key});

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  final _formKey = GlobalKey<FormState>();
  PaymentMethodType _type = PaymentMethodType.paypal;
  String _email = '';
  String _walletAddress = '';
  String _network = '';
  String _bankName = '';
  String _accountNumber = '';
  String _accountName = '';

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final method = switch (_type) {
      PaymentMethodType.paypal => PaymentMethod(type: _type, email: _email),
      PaymentMethodType.crypto => PaymentMethod(
          type: _type,
          walletAddress: _walletAddress,
          network: _network,
        ),
      PaymentMethodType.bank => PaymentMethod(
          type: _type,
          bankName: _bankName,
          accountNumber: _accountNumber,
          accountName: _accountName,
        ),
    };
    Navigator.of(context).pop(method);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add payment method',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose where you want withdrawal requests sent.',
                  style: TextStyle(color: AppColors.textDim, fontSize: 13),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaymentMethodType>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Payment type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PaymentMethodType.paypal,
                      child: Text('PayPal'),
                    ),
                    DropdownMenuItem(
                      value: PaymentMethodType.crypto,
                      child: Text('Crypto'),
                    ),
                    DropdownMenuItem(
                      value: PaymentMethodType.bank,
                      child: Text('Bank account'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _type = value);
                  },
                ),
                const SizedBox(height: 14),
                ..._fields,
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save payment method'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> get _fields {
    switch (_type) {
      case PaymentMethodType.paypal:
        return [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'PayPal email',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (_required(value) != null) return _required(value);
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(value!.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
            onSaved: (value) => _email = value!.trim(),
          ),
        ];
      case PaymentMethodType.crypto:
        return [
          TextFormField(
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Network (e.g. Bitcoin, Ethereum)',
              border: OutlineInputBorder(),
            ),
            validator: _required,
            onSaved: (value) => _network = value!.trim(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Wallet address',
              border: OutlineInputBorder(),
            ),
            validator: _required,
            onSaved: (value) => _walletAddress = value!.trim(),
          ),
        ];
      case PaymentMethodType.bank:
        return [
          TextFormField(
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Bank name',
              border: OutlineInputBorder(),
            ),
            validator: _required,
            onSaved: (value) => _bankName = value!.trim(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Account name',
              border: OutlineInputBorder(),
            ),
            validator: _required,
            onSaved: (value) => _accountName = value!.trim(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Account number',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (_required(value) != null) return _required(value);
              if (value!.trim().length < 6) {
                return 'Enter a valid account number';
              }
              return null;
            },
            onSaved: (value) => _accountNumber = value!.trim(),
          ),
        ];
    }
  }
}

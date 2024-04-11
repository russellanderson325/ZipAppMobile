import 'package:flutter/material.dart';

class AddBankAccountScreen extends StatelessWidget {
  final Function(Map<String, String>) onAddBankAccount;

  AddBankAccountScreen({required this.onAddBankAccount});

  final _bankNameController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _lastFourDigitsController = TextEditingController();
  final _lastFourSSNController = TextEditingController();
  final _accountHolderNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bank Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _bankNameController,
              decoration: const InputDecoration(labelText: 'Bank Name'),
            ),
            
            const SizedBox(height: 8),
            TextField(
              controller: _routingNumberController,
              decoration: const InputDecoration(labelText: 'Routing Number'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lastFourDigitsController,
              decoration: const InputDecoration(
                  labelText: 'Last Four Digits of Account Number'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lastFourSSNController,
              decoration: const InputDecoration(
                  labelText: 'Last 4 Digits of Social Security Number'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _accountHolderNameController,
              decoration: const InputDecoration(
                  labelText: 'Bank Account Holder Name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Gather all the input values
                final bankName = _bankNameController.text;
                
                final routingNumber = _routingNumberController.text;
                final lastFourDigits = _lastFourDigitsController.text;
                final lastFourSSN = _lastFourSSNController.text;
                final accountHolderName = _accountHolderNameController.text;

                // Create a map to hold the bank account details
                final bankAccountData = {
                  'bankName': bankName,
                  'routingNumber': routingNumber,
                  'lastFourDigits': lastFourDigits,
                  'lastFourSSN': lastFourSSN,
                  'accountHolderName': accountHolderName,
                };

                // Call the onAddBankAccount callback function with the new bank account data
                onAddBankAccount(bankAccountData);

                // Close the screen after adding the bank account
                Navigator.of(context).pop();
              },
              child: const Text('Add Bank Account'),
            ),
          ],
        ),
      ),
    );
  }
}

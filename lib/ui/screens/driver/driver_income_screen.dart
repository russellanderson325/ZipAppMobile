import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/driver_bank_account.dart';
import 'package:zipapp/ui/screens/driver/add_bank_account_info.dart';

class DriverIncomeScreen extends StatefulWidget {
  const DriverIncomeScreen({super.key});

  @override
  State<DriverIncomeScreen> createState() => _DriverIncomeScreenState();
}

class _DriverIncomeScreenState extends State<DriverIncomeScreen> {
  List<Map<String, String>> connectedBankAccounts = [
    {
      'bankName': 'Chase',
      
      'routingNumber': '123456789',
      'lastFourDigits': '1234',
      'lastFourSSN': '5678',
      'accountHolderName': 'John Doe'
    },
    {
      'bankName': 'Regions',
      
      'routingNumber': '987654321',
      'lastFourDigits': '5678',
      'lastFourSSN': '4321',
      'accountHolderName': 'Jane Smith'
    },
  ];

  // Function to add a new bank account
  void addBankAccount(Map<String, String> bankAccountData) {
    setState(() {
      connectedBankAccounts.add(bankAccountData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        title: const Text(
          'Income',
          style: ZipDesign.pageTitleText,
        ),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ListView(
          children: [
            const Text('Connected Bank Accounts', style: ZipDesign.sectionTitleText),
            
            // Display the list of connected bank accounts
            for (var bankAccount in connectedBankAccounts)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DriverBankAccount.build(
                      context: context,
                      bankName: bankAccount['bankName']!,
                      lastFourDigits: bankAccount['lastFourDigits']!),
                  const SizedBox(height: 16),
                ],
              ),
              
            TextButton.icon(
              onPressed: () {
                // Navigate to the AddBankAccountScreen when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBankAccountScreen(
                      onAddBankAccount: addBankAccount,
                    ),
                  ),
                );
              },
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add bank account'),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                iconColor: MaterialStateProperty.all(Colors.black),
                iconSize: MaterialStateProperty.all(16),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                backgroundColor: MaterialStateProperty.all(ZipColors.zipYellow),
                textStyle: MaterialStateProperty.all(ZipDesign.labelText),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Earnings', style: ZipDesign.sectionTitleText),
            const SizedBox(height: 16),
            const Text('Total Earned This Week: \$123.45',
                style: ZipDesign.labelText),
            const SizedBox(height: 16),
            const Text('Total Earned with Zip: \$500',
                style: ZipDesign.labelText),
          ],
        ),
      ),
    );
  }
}

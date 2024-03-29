import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/driver_bank_account.dart';

class DriverIncomeScreen extends StatefulWidget {
  const DriverIncomeScreen({super.key});

  @override
  State<DriverIncomeScreen> createState() => _DriverIncomeScreenState();
}

class _DriverIncomeScreenState extends State<DriverIncomeScreen> {
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
          children: <Widget>[
            const Text('Connected Bank Accounts',
                style: ZipDesign.sectionTitleText),
            DriverBankAccount.build(
                context: context, bankName: 'Chase', lastFourDigits: '1234'),
            const SizedBox(height: 16),
            DriverBankAccount.build(
                context: context, bankName: 'Regions', lastFourDigits: '5678'),
            const SizedBox(height: 16),
            TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
                label: const Text('Add bank account'),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                  iconColor: MaterialStateProperty.all(Colors.black),
                  iconSize: MaterialStateProperty.all(16),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  backgroundColor:
                      MaterialStateProperty.all(ZipColors.zipYellow),
                  textStyle: MaterialStateProperty.all(ZipDesign.labelText),
                )),
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

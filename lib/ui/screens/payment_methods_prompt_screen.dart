/*
 * This file contains the screen for the user to select a payment method,
 * such as a debit/credit card, Apple Pay, or Google Pay.
*/
import 'package:flutter/material.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:zipapp/ui/screens/stripe_card_info_prompt_screen.dart';
import 'package:zipapp/constants/zip_colors.dart';

class PaymentMethodsPrompt extends StatelessWidget {
  const PaymentMethodsPrompt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      appBar: AppBar(
        // This will place the title in the app's top bar
        title: const Text('Payment Methods'),
        backgroundColor: ZipColors.primaryBackground,
        centerTitle: true, // Optionally center the title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Button for adding Debit/Credit Card
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StripeCardInfoPromptScreen(),
                  ),
                );
              },
              style: ZipDesign.yellowButtonStyle,
              child: const Text('Add Debit/Credit Card'),
            ),
            // Button for adding Apple Pay
            ElevatedButton(
              onPressed: () {
                // Action for adding a different payment method
              },
              style: ZipDesign.yellowButtonStyle,
              child: const Text('Use Apple Pay'),
            ),
            // Button for adding Google Pay
            ElevatedButton(
              onPressed: () {
                // Action for adding a different payment method
              },
              style: ZipDesign.yellowButtonStyle,
              child: const Text('Use Google Pay'),
            ),
            // The go back button remains here, allowing users to navigate back from this screen
            // TextButton(
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   child: const Text('Go Back'),
            // ),
          ],
        ),
      ),
    );
  }
}
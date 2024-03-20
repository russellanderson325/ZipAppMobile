import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/message_overlay.dart';
import 'package:zipapp/services/payment.dart';
import 'package:zipapp/constants/zip_colors.dart';

class StripeCardInfoPromptScreen extends StatelessWidget {
  // Variables
  final bool _isCardValid = true;
  // Constructor
  const StripeCardInfoPromptScreen({Key? key}) : super(key: key);

  // Functions
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        title: const Text("Add Card")
      ),
      body: Container( // Wrap the Column in a Padding widget
          margin: const EdgeInsets.all(40.0), // Adds margin of 10.0 units on all sides
          child: Column(
            children: [
              CardField(
                onCardChanged: (card) {
                  // print(card);
                },
              ),
              Container(
                margin: const EdgeInsets.all(20.0), // Adds margin of 10.0 units on all sides
                child: ElevatedButton(
                  onPressed: () {
                    // Attempt to create the payment method
                    Payment.createPaymentMethod().then((paymentMethod) {
                      Payment.setPaymentMethodId(paymentMethod?.id ?? "");
                      // Payment.addPaymentMethodDialog(context);
                      MessageOverlay(
                        message: "Card added successfully!",
                        duration: const Duration(seconds: 3),
                        color: "#32e632",
                      ).show(context);

                      Navigator.pop(context); // Navigate back to the previous screen
                    }).catchError((e) {
                      print('failed to add card');
                      MessageOverlay(
                        message: "Error adding card, please try again.",
                        duration: const Duration(seconds: 3),
                        color: "#f5272b",
                      ).show(context);
                    });
                  },
                  style: ZipDesign.yellowButtonStyle,
                  child: const Text('Save Card Using Stripe'),
                ),
              ),
            ],
          ),
      ),
    );
  }
}

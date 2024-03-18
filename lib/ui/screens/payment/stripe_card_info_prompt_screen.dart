import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeCardInfoPromptScreen extends StatelessWidget {
  const StripeCardInfoPromptScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Card")),
      body: Column(
        children: [
          CardField(
            onCardChanged: (card) {
              print(card);
            },
          ),
          ElevatedButton(
            child: const Text('Save Card'),
            onPressed: () async {
              // Attempt to create the payment method
              try {
                final paymentMethod = await Stripe.instance.createPaymentMethod(
                  params: const PaymentMethodParams.card(
                    paymentMethodData: PaymentMethodData(
                      // Specify additional card data if needed
                    ),
                  ),
                );
                print("Payment Method created: ${paymentMethod.id}");
                // Send paymentMethod.id to your server for further processing
              } catch (e) {
                print("Error creating payment method: $e");
              }
            },
          ),
        ],
      ),
    );
  }
}
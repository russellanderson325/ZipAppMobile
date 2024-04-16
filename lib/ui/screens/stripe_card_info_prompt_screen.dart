import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:zipapp/services/payment.dart';
import 'package:zipapp/constants/zip_colors.dart';

class StripeCardInfoPromptScreen extends StatefulWidget {
  final Function refreshKey;

  const StripeCardInfoPromptScreen({super.key, required this.refreshKey});

  @override
  StripeCardInfoPromptScreenState createState() => StripeCardInfoPromptScreenState();
}

class StripeCardInfoPromptScreenState extends State<StripeCardInfoPromptScreen> {
  String statusMessage = " ";
  static DateTime lastButtonPress = DateTime(0);
  static bool stripeButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        title: const Text("Add Card"),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 200),
            Column(
              children: [
                const CardField(
                  cursorColor: Color.fromARGB(255, 54, 54, 54),
                ),
                const SizedBox(height: 20),
                Visibility(
                  child: (statusMessage != "loading" ? Text(
                    statusMessage,
                    style: const TextStyle(color: Colors.red),
                  ) : 
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    )
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                // If button has been pressed in the last 1 second, do nothing
                if (DateTime.now().difference(lastButtonPress).inSeconds < 3) return;
                lastButtonPress = DateTime.now();

                setState(() {
                  statusMessage = "loading";
                });

                // Attempt to create the payment method using Stripe
                Payment.createPaymentMethod().then((paymentMethod) async {
                  // Get the payment method with the fingerprint
                  Map<String, dynamic>? paymentMethodWithFingerprint = await Payment.getPaymentMethodById(paymentMethod!.id);
                  print("Payment Method: $paymentMethodWithFingerprint");
                  // Get the fingerprint
                  String fingerprint = paymentMethodWithFingerprint!['fingerprint'];

                  // Save the payment method to the Firestore database
                  // Note: If the finger print already exists in the users payment methods, it will not be added
                  // and the payment method will be removed from the Stripe API
                  print("Fingerprint: $fingerprint");
                  await Payment.setPaymentMethodIdAndFingerprint(paymentMethod.id, fingerprint);
                  
                  Navigator.pop(context);
                  widget.refreshKey();
                }).catchError((e) {
                  print(e.toString());
                  switch (e.toString()) {
                    case "Exception: Payment method already exists":
                      setState(() {
                        statusMessage = "Payment method already exists.";
                      });
                      break;
                    default:
                      setState(() {
                        statusMessage = "Please enter valid card information.";
                      });
                      break;
                  }
                });
              },
              // icon: Image.asset('assets/connectstripe_blurple_4x.png'),
              child: Ink(
                height: 60, // Set the height of your image button
                width: double.infinity, // Set the width of your image button
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage("assets/connectstripe_blurple_4x.png"), // Path to your image asset
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10), // Optional: if you want rounded corners for the image
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/message_overlay.dart';
import 'package:zipapp/services/payment.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/ui/screens/payments_screen.dart';

class StripeCardInfoPromptScreen extends StatefulWidget {
  final Function refreshKey;

  const StripeCardInfoPromptScreen({Key? key, required this.refreshKey}) : super(key: key);

  @override
  StripeCardInfoPromptScreenState createState() => StripeCardInfoPromptScreenState();
}

class StripeCardInfoPromptScreenState extends State<StripeCardInfoPromptScreen> {
  String errorMessage = " ";
  static DateTime lastButtonPress = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        title: const Text("Add Card"),
      ),
      body: Container(
        margin: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const CardField(
                  cursorColor: Color.fromARGB(255, 54, 54, 54),
                ),
                const SizedBox(height: 20),
                Visibility(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.all(20.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  // If button has been pressed in the last 1 second, do nothing
                  if (DateTime.now().difference(lastButtonPress).inSeconds < 1) return;
                  lastButtonPress = DateTime.now();
                  
                  // Attempt to create the payment method using Stripe
                  Payment.createPaymentMethod().then((paymentMethod) async {
                    // Get the payment method with the fingerprint
                    Map<String, dynamic>? paymentMethodWithFingerprint = await Payment.getPaymentMethodById(paymentMethod!.id);
                    // Get the fingerprint
                    String fingerprint = await paymentMethodWithFingerprint!['fingerprint'];
                    // Save the payment method to the Firestore database
                    // Note: If the finger print already exists in the users payment methods, it will not be added
                    // and the payment method will be removed from the Stripe API
                    await Payment.setPaymentMethodIdAndFingerprint(paymentMethod.id, fingerprint);
                    // Navigate back to the previous screen
                    Navigator.pop(context);
                    // Refresh the FutureBuilder Payment Method list
                    widget.refreshKey();
                  }).catchError((e) {
                    switch (e.toString()) {
                      case "Exception: Payment method already exists":
                        setState(() {
                          errorMessage = "Payment method already exists.";
                        });
                        break;
                      default:
                        setState(() {
                          errorMessage = "Please enter valid card information.";
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
            ),
          ],
        ),
      ),
    );
  }
}
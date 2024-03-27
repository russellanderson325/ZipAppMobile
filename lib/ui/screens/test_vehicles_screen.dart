import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_stripe/flutter_stripe.dart";
import "package:zipapp/constants/zip_colors.dart";
import "package:zipapp/constants/zip_design.dart";
import "package:zipapp/models/primary_payment_method.dart";
import "package:zipapp/services/payment.dart";
import "package:zipapp/ui/screens/payments_screen.dart";
import "package:zipapp/ui/screens/stripe_card_info_prompt_screen.dart";
import "package:zipapp/ui/widgets/payment_list_item.dart";
import "package:zipapp/ui/widgets/payment_methods_list.dart";
import "package:zipapp/ui/widgets/primary_payment_list_item.dart";
import 'package:zipapp/utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/ui/widgets/payment_select_list_item.dart';

class TestVehiclesScreen extends StatefulWidget {
  final double distanceInMeters; // Distance from user to destination in meters
  const TestVehiclesScreen({super.key, required this.distanceInMeters});

  @override
  TestVehiclesScreenState createState() => TestVehiclesScreenState();
}

class TestVehiclesScreenState extends State<TestVehiclesScreen> {
  UniqueKey uniqueKey = UniqueKey();
  bool forceUpdate = false;
  String label = "X Golf Cart";
  String cartSize = "X";
  bool zipXL = false;
  double price = 0.0;
  String currencyCode = "USD";
  String merchantCountryCode = "US";
  double distanceInMiles = 0.0;
  DateTime lastAppleGooglePayButtonPress = DateTime(0);

  @override
  void initState() {
    super.initState();
    setCartValues(label, cartSize, zipXL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Cart Request"),
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: ListView(
          children: <Widget>[
            // const SizedBox(height: 8),
            Container(
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // List of cart sizes
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        clipBehavior: Clip.none,
                        onPressed: () {
                          setCartValues("X Golf Cart", "X", false);
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                          foregroundColor: MaterialStateProperty.all(Colors.black),
                          backgroundColor: MaterialStateProperty.all(cartSize == 'X' ? ZipColors.primaryBackground : Colors.white),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                          side: MaterialStateProperty.all(BorderSide(color: cartSize == 'X' ? ZipColors.boxBorder : Colors.grey)),
                          fixedSize: MaterialStateProperty.all(const Size(160, 100)),
                        ),
                        child: const Image(
                          image: ResizeImage(
                            AssetImage("assets/XCart.png"),
                            height: 100,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setCartValues("XL Golf Cart", "XL", true);
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                          foregroundColor: MaterialStateProperty.all(Colors.black),
                          backgroundColor: MaterialStateProperty.all(cartSize == 'XL' ? ZipColors.primaryBackground : Colors.white),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                          side: MaterialStateProperty.all(BorderSide(color: cartSize == 'XL' ? ZipColors.boxBorder : Colors.grey)),
                          fixedSize: MaterialStateProperty.all(const Size(160, 100)),
                        ),
                        child: const Image(
                          image: ResizeImage(
                            AssetImage("assets/XLCart.png"),
                            height: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Size: $cartSize",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "Trip Length: ${distanceInMiles.toStringAsFixed(2)} miles",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "\$${price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ),
            ),

            const SizedBox(height: 16),
            // const Text('Payment Methods', style: ZipDesign.sectionTitleText),
            // const SizedBox(height: 16),

            // TextButton.icon(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => StripeCardInfoPromptScreen(refreshKey: refreshKey),
            //       ),
            //     );
            //   },
            //   icon: const Icon(LucideIcons.plus),
            //   label: const Text('Add payment method'),
            //   style: ZipDesign.yellowButtonStyle,
            // ),

            // // Payment Method List
            // PaymentMethodListWidget.build(
            //   context: context,
            //   uniqueKey: uniqueKey,
            //   forceUpdate: forceUpdate,
            //   listItemWidgetBuilder: PaymentSelectListItem(),
            //   refreshKey: refreshKey,
            // ),
            // (Platform.isIOS || Platform.isAndroid) ? (
            //   Column(
            //     children: [
            //       const SizedBox(height: 16),
            //       const Center(child: Text("OR")),
            //       const SizedBox(height: 16),
            //       // Apple Pay Button
            //       TextButton(
            //         clipBehavior: Clip.hardEdge,
            //         onPressed: () {
            //           if (DateTime.now().difference(lastAppleGooglePayButtonPress).inSeconds < 3) return;
            //           lastAppleGooglePayButtonPress = DateTime.now();
                      
            //           // Show the Apple/Google Pay payment sheet
            //           Payment.showPaymentSheetToMakePayment(
            //             label, 
            //             (price * 100).round(), 
            //             currencyCode, 
            //             merchantCountryCode
            //           );
            //         },
            //         style: ButtonStyle(
            //           padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
            //           // foregroundColor: MaterialStateProperty.all(Colors.black),
            //           shape: MaterialStateProperty.all(RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(10),
            //           )),
            //         ),
            //         child: Image(
            //           image: AssetImage((Platform.isIOS) ? "assets/apple_pay.png" : "assets/google_pay.png"),
            //           fit: BoxFit.contain,
            //         ),
            //       )
            //     ]
            //   )
            // ) : const SizedBox(),
            FutureBuilder<Map<String, dynamic>?>(
              future: getPrimaryPaymentMethodDetails(), // Assuming this returns Future<String>
              builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                Map<String, dynamic>? primaryPaymentMethodDetails = snapshot.data!;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading state while waiting for the future to complete
                  return const CircularProgressIndicator();
                } else {
                  // Display the primary payment method if the future completes successfully
                  return PrimaryPaymentListItem().build(
                    context: context,
                    cardType: capitalizeFirstLetter(primaryPaymentMethodDetails['brand']),
                    lastFourDigits: primaryPaymentMethodDetails['last4'] ?? '0000',
                    paymentMethodId: primaryPaymentMethodDetails['id'],
                    togglePaymentInfo: true,
                    // refreshKey: refreshKey,
                  );
                }
              },
            ),
            TextButton(
              onPressed: () {
                // Proceed to request confirmation

              },
              style: ZipDesign.yellowButtonStyle,
              child: const Text('Request Pickup'),
            ),
          ],
        ),
      )
    );
  }

  // Refreshes the key to force the widget to rebuild
  void refreshKey() {
    setState(() {
      forceUpdate = true;
      uniqueKey = UniqueKey();
    });
  }

  /*
   * Show the TestVehiclesScreen as a bottom sheet
   * @param context The context
   * @param distanceInMeters The distance from the user to the destination in meters
   * @return void
   */
  static void showTestVehiclesScreen(BuildContext context, double distanceInMeters) {
    // Show the bottom sheet
    showModalBottomSheet(
      clipBehavior: Clip.hardEdge,
      barrierColor: Colors.transparent,
      context: context,
      isScrollControlled: true, // Set to true if your content might not fit
      shape: const RoundedRectangleBorder( // Optional: to style the top corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        side: BorderSide(color: ZipColors.boxBorder, width: 1.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.5, // Adjust the height factor as needed, e.g., 0.9 for 90% of screen height
          child: TestVehiclesScreen(distanceInMeters: distanceInMeters), // Pass the required parameters
        );
      },
    );
  }

  /*
   * Set the cart values
   * @param label The label of the cart
   * @param size The size of the cart
   * @param zipXL Whether the cart is a ZipXL
   * @return void
   */
  void setCartValues(String label, String size, bool zipXL) async {
    distanceInMiles = widget.distanceInMeters / 1609.34;
    double amount = await Payment.getAmmount(zipXL, distanceInMiles, 1);
    // Round to 2 decimal places
    amount = double.parse((amount).toStringAsFixed(2));
    setState(() {
      this.label = label;
      cartSize = size;
      price = amount;
    });
  }

  static Future<Map<String, dynamic>?> getPrimaryPaymentMethodDetails() async {
    PrimaryPaymentMethod primaryPaymentMethod = await Payment.getPrimaryPaymentMethod();
    Future<Map<String, dynamic>?> paymentMethod = Payment.getPaymentMethodById(primaryPaymentMethod.paymentMethodId);
    return paymentMethod;
  }
}
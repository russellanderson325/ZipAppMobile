import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter_stripe/flutter_stripe.dart";
import "package:zipapp/constants/zip_colors.dart";
import "package:zipapp/constants/zip_design.dart";
import "package:zipapp/services/payment.dart";
import "package:zipapp/ui/screens/payments_screen.dart";
import "package:zipapp/ui/screens/stripe_card_info_prompt_screen.dart";
import "package:zipapp/ui/widgets/payment_list_item.dart";
import "package:zipapp/ui/widgets/payment_methods_list.dart";
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
  DateTime lastApplePayButtonPress = DateTime(0);
  @override
  void initState() {
    super.initState();
    setCartValues(label, cartSize, zipXL);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        title: const Text("Cart Request"),
      ),
      backgroundColor: ZipColors.primaryBackground,
      body: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
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
                          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(128, 255, 255, 255)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                          side: MaterialStateProperty.all(const BorderSide(color: Colors.black)),
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
                          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(128, 255, 255, 255)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                          side: MaterialStateProperty.all(const BorderSide(color: Colors.black)),
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
                    "\$$price",
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
          
            const Text('Payment Methods', style: ZipDesign.sectionTitleText),

            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StripeCardInfoPromptScreen(refreshKey: refreshKey),
                  ),
                );
              },
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add payment method'),
              style: ZipDesign.yellowButtonStyle,
            ),

            // Payment Method List
            PaymentMethodListWidget.build(
              context: context,
              uniqueKey: uniqueKey,
              forceUpdate: forceUpdate,
              listItemWidgetBuilder: PaymentSelectListItem(),
              refreshKey: refreshKey,
            ),

            const SizedBox(height: 16),
            const Center(child: Text("OR")),
            const SizedBox(height: 16),
            TextButton(
              clipBehavior: Clip.hardEdge,
              onPressed: () {
                if (DateTime.now().difference(lastApplePayButtonPress).inSeconds < 3) return;
                lastApplePayButtonPress = DateTime.now();
                
                Payment.showPaymentSheetToMakePayment(label, (price * 100).round(), currencyCode, merchantCountryCode);
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                // foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
              ),
              child: const Image(
                image: AssetImage("assets/apple_pay.png"),
                fit: BoxFit.contain,
              ),
            )
            // const 
          ],
        ),
      )
    );
  }

  // Refreshes the key
  void refreshKey() {
    setState(() {
      forceUpdate = true;
      uniqueKey = UniqueKey();
    });
  }

  static void showTestVehiclesScreen(BuildContext context, double distanceInMeters) {
    // Show the bottom sheet
    showModalBottomSheet(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      
      ),
      clipBehavior: Clip.hardEdge,
      context: context,
      isScrollControlled: true, // Set to true if your content might not fit
      shape: const RoundedRectangleBorder( // Optional: to style the top corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9, // Adjust the height factor as needed, e.g., 0.9 for 90% of screen height
          child: TestVehiclesScreen(distanceInMeters: distanceInMeters), // Pass the required parameters
        );
      },
    );
  }
}
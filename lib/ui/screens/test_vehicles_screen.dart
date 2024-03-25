import "package:flutter/material.dart";
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
  String label = "Normal Golf Cart";
  String cartSize = "Normal";
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
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // List of cart sizes
                children: [
                  DropdownButton(
                    hint: const Text("Select Cart Size"),
                    isExpanded: true,
                    icon: const Icon(LucideIcons.goal),
                    iconSize: 20,
                    items: const [
                      DropdownMenuItem(
                        value: (
                          label: "Normal Golf Cart",
                          size: "Normal",
                          zipXL: false,
                        ),
                        child: Text("Normal Golf Cart")
                      ),
                      DropdownMenuItem(
                        value: (
                          label: "XL Golf Cart",
                          size: "XL",
                          zipXL: true,
                        ),
                        child: Text("XL Golf Cart")
                      ),
                    ],
                    onChanged: (value) async {
                      setCartValues(value!.label, value.size, value.zipXL);
                    },
                  ),
                  Text(
                    "Trip Length: ${distanceInMiles.toStringAsFixed(2)} miles",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Size: $cartSize",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Cart Price: \$$price",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ]
              ),
            ),

            const SizedBox(height: 48),

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
              onPressed: () {
                if (DateTime.now().difference(lastApplePayButtonPress).inSeconds < 3) return;
                lastApplePayButtonPress = DateTime.now();
                
                Payment.showPaymentSheetToMakePayment(label, (price * 100).round(), currencyCode, merchantCountryCode);
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                foregroundColor: MaterialStateProperty.all(Colors.black),
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
}
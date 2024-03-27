import "dart:io";

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
  DateTime lastAppleGooglePayButtonPress = DateTime(0);
  @override
  void initState() {
    super.initState();
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

  // /*
  //  * Show the TestVehiclesScreen as a bottom sheet
  //  * @param context The context
  //  * @param distanceInMeters The distance from the user to the destination in meters
  //  * @return void
  //  */
  // static void showTestVehiclesScreen(BuildContext context, double distanceInMeters) {
  //   // Show the bottom sheet
  //   showModalBottomSheet(
  //     clipBehavior: Clip.hardEdge,
  //     barrierColor: Colors.transparent,
  //     context: context,
  //     isScrollControlled: true, // Set to true if your content might not fit
  //     shape: const RoundedRectangleBorder( // Optional: to style the top corners
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
  //       side: BorderSide(color: ZipColors.boxBorder, width: 1.0),
  //     ),
  //     builder: (BuildContext context) {
  //       return FractionallySizedBox(
  //         heightFactor: 0.5, // Adjust the height factor as needed, e.g., 0.9 for 90% of screen height
  //         child: TestVehiclesScreen(distanceInMeters: distanceInMeters), // Pass the required parameters
  //       );
  //     },
  //   );
  // }
}
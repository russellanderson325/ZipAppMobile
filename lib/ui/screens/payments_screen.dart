import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/payment_list_item.dart';
import 'package:zipapp/ui/widgets/payment_methods_list.dart';
import 'package:zipapp/ui/screens/stripe_card_info_prompt_screen.dart';
import 'package:zipapp/ui/screens/default_tip_screen.dart';
import 'package:zipapp/business/user.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => PaymentsScreenState();
}

// class PaymentMethodsCache {
//   static void updateCache(List<Map<String, dynamic>?> methods) async {
//     Payment.setPaymentMethodsCache(methods);
//   }
// }

class PaymentsScreenState extends State<PaymentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserService userService = UserService();
  static UniqueKey uniqueKey = UniqueKey();
  static bool forceUpdate = false;


  Future<double> fetchDefaultTipAmount() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userService.userID).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('defaultTip')) {
          return data['defaultTip'].toDouble();
        }
      }
    } catch (e) {
      print("Error fetching default tip amount: $e");
    }
    return 20.0; // Default value if none is found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        title: const Text(
          'Payments',
          style: ZipDesign.pageTitleText,
        ),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: ListView(
          children: <Widget>[
            const Text(
              'Payment methods',
              style: ZipDesign.sectionTitleText,
            ),
            // Payment Method List
            PaymentMethodListWidget.build(
              context: context,
              uniqueKey: uniqueKey,
              listItemWidgetBuilder: PaymentListItem(),
              forceUpdate: forceUpdate,
              refreshKey: refreshKey,
            ),
            // Add Payment Method Button
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
            const SizedBox(
              height: 32,
            ),
            // Promotions
            const Text('Promotions', style: ZipDesign.sectionTitleText),
            const SizedBox(height: 16),
            TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
                label: const Text('Add promo code'),
                style: ZipDesign.yellowButtonStyle,
            ),
            const SizedBox(height: 32),
            const Text('Default tip', style: ZipDesign.sectionTitleText),
            FutureBuilder<double>(
              future: fetchDefaultTipAmount(),
              builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                String defaultTipText = "Loading...";
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    defaultTipText = "${snapshot.data!.toStringAsFixed(0)}%";
                  } else {
                    defaultTipText = "20%";
                  }
                }
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: TailwindColors.gray300)),
                  ),
                  child: Row(children: <Widget>[
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const DefaultTipScreen()),
                          );
                          setState(() {});
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(0)),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.black),
                          textStyle:
                              MaterialStateProperty.all(ZipDesign.labelText),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(defaultTipText, style: ZipDesign.labelText),
                            const Icon(LucideIcons.chevronRight,
                                size: 24, color: TailwindColors.gray500),
                          ],
                        ),
                      ),
                    ),
                  ]),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  /*
   * Refreshes the FutureBuilder by changing the key
   * This is useful when we want to refresh the FutureBuilder
   * after a new payment method is added~
   * or after a payment method is deleted
   * @return void
   */
  void refreshKey() {
    setState(() {
      forceUpdate = true;
      uniqueKey = UniqueKey();
    });
  }
}

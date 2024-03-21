import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/payment_list_item.dart';
import 'package:zipapp/services/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zipapp/utils.dart';
import 'package:zipapp/ui/screens/stripe_card_info_prompt_screen.dart';
import 'package:zipapp/ui/screens/default_tip_screen.dart';
import 'package:zipapp/business/user.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => PaymentsScreenState();
}

class PaymentMethodsCache {
  static List<Map<String, dynamic>?>? cachedPaymentMethods;

  static void updateCache(List<Map<String, dynamic>?> methods) {
    cachedPaymentMethods = methods;
  }
}

class PaymentsScreenState extends State<PaymentsScreen> {
  UniqueKey uniqueKey = UniqueKey(); // For refreshing the FutureBuilder
  bool forceUpdate = false; // Flag for forcing the FutureBuilder to update

  Future<List<Map<String, dynamic>?>> fetchPaymentMethodsIfNeeded() async {
    if (PaymentMethodsCache.cachedPaymentMethods == null || forceUpdate) {
      forceUpdate = false;
      // Fetch from Stripe API
      var fetchedMethods = await Payment.getPaymentMethodsDetails();
      PaymentMethodsCache.updateCache(fetchedMethods);
      return fetchedMethods;
    } else {  
      return PaymentMethodsCache.cachedPaymentMethods!;
    }
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserService userService = UserService();

  Future<double> fetchDefaultTipAmount() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userService.userID).get();
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
        centerTitle: false,
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
            // FutureBuilder for Payment Methods List
            FutureBuilder<List<Map<String, dynamic>?>>(
              key: uniqueKey,
              future: fetchPaymentMethodsIfNeeded(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  // Create a list of PaymentListItem widgets
                  List<Widget> listItems = snapshot.data!
                      .map((paymentMethod) {
                        return PaymentListItem.build(
                            context: context,
                            cardType: capitalizeFirstLetter(paymentMethod?['brand']),
                            lastFourDigits: paymentMethod?['last4'] ?? '0000',
                            paymentMethodId: paymentMethod?['id'],
                            refreshKey: refreshKey
                          );
                      }).toList();
                  // Add spacing after each item
                  for (var i = listItems.length - 1; i > 0; i--) {
                    listItems.insert(i, const SizedBox(height: 16));
                  }
                  return Column(
                    children: listItems,
                  );
                } else {
                  return const Text('No data available');
                }
              },
            ),
            // Add Payment Method Button
            TextButton.icon(
              onPressed: () {
                print("Add new payment method");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StripeCardInfoPromptScreen(refreshKey: refreshKey),
                  ),
                );
              },
              icon: const Icon(LucideIcons.plus),
              label: const Text('Add payment method'),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                iconColor: MaterialStateProperty.all(Colors.black),
                iconSize: MaterialStateProperty.all(16),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                backgroundColor: MaterialStateProperty.all(Colors.yellow),
                textStyle: MaterialStateProperty.all(ZipDesign.labelText),
              )
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
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                  iconColor: MaterialStateProperty.all(Colors.black),
                  iconSize: MaterialStateProperty.all(16),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  backgroundColor: MaterialStateProperty.all(ZipColors.zipYellow),
                  textStyle: MaterialStateProperty.all(ZipDesign.labelText),
                )
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
                    border: Border(bottom: BorderSide(color: TailwindColors.gray300)),
                  ),
                  child: Row(children: <Widget>[
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const DefaultTipScreen()),
                          );
                          setState(() {});
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                          foregroundColor: MaterialStateProperty.all(Colors.black),
                          textStyle: MaterialStateProperty.all(ZipDesign.labelText),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(defaultTipText, style: ZipDesign.labelText),
                            const Icon(LucideIcons.chevronRight, size: 24, color: TailwindColors.gray500),
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
}

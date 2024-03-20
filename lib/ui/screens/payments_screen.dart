import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/payment_list_item.dart';
import 'package:zipapp/services/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zipapp/utils.dart';
import 'package:zipapp/ui/screens/stripe_card_info_prompt_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
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
              future: Payment.getPaymentMethodsDetails(), // Your future function
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  // Data is fetched successfully, now build the UI
                  print('Data: ${snapshot.data}'); // Print the data (for debugging purposes
                  List<Widget> listItems = snapshot.data!
                      .map((paymentMethod) => PaymentListItem.build(
                            context: context,
                            cardType: capitalizeFirstLetter(paymentMethod?['brand']),
                            lastFourDigits: paymentMethod?['last4'] ?? '0000',
                          ))
                      .toList();
                  // Add spacing after each item
                  for (var i = listItems.length - 1; i > 0; i--) {
                    listItems.insert(i, const SizedBox(height: 16));
                  }
                  return Column(
                    children: listItems,
                  );
                } else {
                  return const Text('No data available'); // Show this text if there is no data
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
                    builder: (context) => const StripeCardInfoPromptScreen(),
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
                backgroundColor: MaterialStateProperty.all(ZipColors.zipYellow),
                textStyle: MaterialStateProperty.all(ZipDesign.labelText),
              )
            ),
            const SizedBox(
              height: 32,
            ),
            // Promotions
            const Text(
              'Promotions',
              style: ZipDesign.sectionTitleText,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
                label: const Text('Add promo code'),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                  iconColor: MaterialStateProperty.all(Colors.black),
                  iconSize: MaterialStateProperty.all(16),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  backgroundColor: MaterialStateProperty.all(ZipColors.zipYellow),
                  textStyle: MaterialStateProperty.all(ZipDesign.labelText),
                )),
            const SizedBox(
              height: 32,
            ),
            // Default Tip
            const Text(
              'Default tip',
              style: ZipDesign.sectionTitleText,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: TailwindColors.gray300)),
              ),
              child: Row(children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      /// TODO: Add the default tip page
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      textStyle: MaterialStateProperty.all(ZipDesign.labelText),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '20%',
                          style: ZipDesign.labelText,
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(width: 8),
                            Row(children: <Widget>[
                              Text(
                                'Your average: ',
                                style: ZipDesign.labelText,
                              ),
                              Text(
                                '\$3.40',
                                style: ZipDesign.disabledBodyText,
                              )
                            ]),
                            Icon(LucideIcons.chevronRight,
                                size: 24, color: TailwindColors.gray500),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            )
          ]
        ),
      ),
    );
  }
}

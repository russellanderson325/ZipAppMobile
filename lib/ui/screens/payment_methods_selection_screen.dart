import "package:flutter/material.dart";
import "package:zipapp/constants/zip_colors.dart";
import "package:zipapp/constants/zip_design.dart";
import "package:zipapp/ui/screens/stripe_card_info_prompt_screen.dart";
import "package:zipapp/ui/widgets/payment_methods_list.dart";
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/ui/widgets/payment_select_list_item.dart';

class PaymentMethodsSelectionScreen extends StatefulWidget {
  final Function refreshKey;

  const PaymentMethodsSelectionScreen({super.key, required this.refreshKey});

  @override
  State<PaymentMethodsSelectionScreen> createState() => PaymentMethodsSelectionScreenState();
}

class PaymentMethodsSelectionScreenState extends State<PaymentMethodsSelectionScreen> {
  static UniqueKey uniqueKey = UniqueKey();
  static bool forceUpdate = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: ZipColors.primaryBackground,
        title: const Text("Payment Methods"),
      ),
      backgroundColor: ZipColors.primaryBackground,
      body: Container(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: ListView(
          children: <Widget>[
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
            const SizedBox(height: 16),
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
      widget.refreshKey();
    });
  }
}

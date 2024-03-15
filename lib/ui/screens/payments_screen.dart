import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/payment_list_item.dart';
import 'package:zipapp/ui/screens/default_tip_screen.dart';

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
        child: ListView(children: <Widget>[
          const Text(
            'Payment methods',
            style: ZipDesign.sectionTitleText,
          ),
          PaymentListItem.build(
              context: context, cardType: 'Visa', lastFourDigits: '1234'),
          const SizedBox(height: 16),
          PaymentListItem.build(
              context: context, cardType: 'Mastercard', lastFourDigits: '1234'),
          const SizedBox(height: 16),
          PaymentListItem.build(
              context: context, cardType: 'Discover', lastFourDigits: '1234'),
          const SizedBox(height: 16),
          PaymentListItem.build(
              context: context, cardType: 'Amex', lastFourDigits: '1234'),
          const SizedBox(height: 16),
          TextButton.icon(
              onPressed: () {},
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
              )),
          const SizedBox(
            height: 32,
          ),
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
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const DefaultTipScreen()),
                  ),
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
                            //change later.
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
        ]),
      ),
    );
  }
}
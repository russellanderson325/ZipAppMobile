import 'package:flutter/material.dart';
import 'package:zipapp/services/payment.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';

class PaymentInfo extends StatefulWidget {
  final String paymentMethodId;
  final Function refreshKey;
  final String cardType;
  final String lastFourDigits;

  const PaymentInfo({
    Key? key, 
    required this.paymentMethodId,
    required this.cardType, 
    required this.lastFourDigits,
    required this.refreshKey
    }) : super(key: key);

  @override
  State<PaymentInfo> createState() => _PaymentInfoState();
}

class _PaymentInfoState extends State<PaymentInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        title: const Text("Payment Info")
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "Card Type: ${widget.cardType}",
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  "Card Number: •••• ${widget.lastFourDigits}",
                  style: const TextStyle(color: Colors.black),
                )
              ]
            ),
            TextButton(
              onPressed: () async {
                await Payment.removePaymentMethod(widget.paymentMethodId).then((value) {
                  widget.refreshKey();
                  Navigator.pop(context);
                });
              },
              style: ZipDesign.yellowButtonStyle,
              child: const Text('Remove Payment Method')
            )
          ],
        ),
      )
    );
  }
}

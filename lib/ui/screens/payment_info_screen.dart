import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zipapp/services/payment.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
  bool removeButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        title: const Text("")
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 200),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.cardType,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 50,
                  ),
                ),
                const SizedBox(height: 10),
                (widget.cardType != 'Apple Pay' && widget.cardType != 'Google Pay' ? 
                  Text("•••• ${widget.lastFourDigits}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                    ),
                  ) : Text("${widget.cardType} is supported.")
                ),
              ]
            ),
            const SizedBox(height: 300),
            (widget.cardType != 'Apple Pay' && widget.cardType != 'Google Pay' ? 
              TextButton.icon(
                onPressed: () async {
                  // If button has been pressed in the last 1 second, do nothing
                  if (removeButtonPressed) return;
                  removeButtonPressed = true;

                  await Payment.removePaymentMethod(widget.paymentMethodId).then((value) {
                    widget.refreshKey();
                    Navigator.pop(context);
                  });
                },
                icon: const Icon(LucideIcons.trash),
                style: ZipDesign.redButtonStyle,
                label: const Text('Remove Payment Method')
              ) : const SizedBox(height: 0)
            ),
          ],
        ),
      )
    );
  }
}

import 'package:flutter/material.dart';

class PaymentInfo extends StatefulWidget {
  const PaymentInfo({Key? key}) : super(key: key);

  @override
  State<PaymentInfo> createState() => _PaymentInfoState();
}

class _PaymentInfoState extends State<PaymentInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Payment info Screen'),
          // go back text button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go Back'),
          )
        ],
      ),
    ));
  }
}

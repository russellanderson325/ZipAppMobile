import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:cloud_functions/cloud_functions.dart';

class StripeScreen extends StatefulWidget {
  const StripeScreen({super.key});

  // final Payment payment;
  @override
  State<StripeScreen> createState() => _StripeScreenState();
}

class _StripeScreenState extends State<StripeScreen> {
  late VoidCallback onBackPress;
  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  HttpsCallable onboardStripeFunction =
      FirebaseFunctions.instance.httpsCallable(
    'createExpressAccount',
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Driver Payments',
            ),
            actions: const <Widget>[
              // IconButton(
              //   icon: Icon(Icons.clear),
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              // )
            ],
          ),
          body: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 5.0),
              child: Stack(children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "Set up Stripe Connect to recieve payouts.",
                        softWrap: true,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            MaterialButton(
                              //color: Colors.cyan,
                              //padding: EdgeInsets.all(8.0),
                              elevation: 8.0,
                              child: Container(
                                width: 300,
                                height: 80,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/connectstripe_blurple_2x.png'),
                                      fit: BoxFit.scaleDown),
                                ),
                              ),
                              onPressed: () async {
                                if (kDebugMode) {
                                  print('Tapped');
                                }
                                HttpsCallableResult result =
                                    await onboardStripeFunction
                                        .call(<String, dynamic>{});
                                if (kDebugMode) {
                                  print(result.toString());
                                }
                              },
                            ),
                          ]),
                    ])
              ]))),
    );
  }
}

class TopRectangle extends StatelessWidget {
  final Color? color;
  final double height;
  final double width;
  final Widget child;
  final posi;
  const TopRectangle(
      {super.key,
      this.posi,
      required this.child,
      this.color,
      this.height = 100.0,
      this.width = 500.0});

  @override
  build(context) {
    return Container(
      width: width,
      height: height,
      color: const Color.fromRGBO(76, 86, 96, 1.0),
      child: child,
    );
  }
}

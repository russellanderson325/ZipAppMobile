import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:zipapp/business/auth.dart";
import "package:zipapp/business/user.dart";
import "package:zipapp/business/payment.dart";
import 'package:zipapp/ui/widgets/custom_flat_button.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  _EarningsScreenState createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  late VoidCallback onBackPress;
  final AuthService auth = AuthService();
  final UserService userService = UserService();
  final paymentService = Payment();
  late Payment pay;
  late double screenHeight, screenWidth;

  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();

    paymentService.getPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(
                          top: 70.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: Text(
                        "Driver Earnings",
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Bebas",
                        ),
                      ),
                    ),
                    const Padding(
                        padding: EdgeInsets.only(
                            top: 10.0, bottom: 20.0, left: 15.0, right: 15.0),
                        child: Text(
                          "Cash Amount",
                          style:
                              TextStyle(color: Colors.yellow, fontSize: 22.0),
                          textAlign: TextAlign.center,
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 40.0),
                      child: CustomTextButton(
                        title: "Cash Out",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        textColor: Colors.black,
                        onPressed: () {
                          if (kDebugMode) {
                            print('driver earnings - cash out button clicked');
                          }
                        },
                        color: const Color.fromRGBO(255, 242, 0, 1.0),
                        borderColor: const Color.fromRGBO(212, 20, 15, 1.0),
                        borderWidth: 0,
                      ),
                    ),
                  ],
                ),
                SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: onBackPress,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

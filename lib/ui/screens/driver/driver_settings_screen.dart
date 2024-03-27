import "package:flutter/material.dart";
//import 'package:zip/ui/screens/profile_screen.dart';
//import 'package:zip/ui/screens/defaultTip_screen.dart';
import 'package:zipapp/ui/screens/notInUse/profile_screen.dart';
import 'package:zipapp/ui/screens/notInUse/legal_info_screen.dart';
import 'package:zipapp/ui/screens/notInUse/vehicles_screen.dart';
import 'package:zipapp/ui/screens/notInUse/documents_screen.dart';
//import 'package:zip/services/payment_screen.dart';
import 'package:zipapp/business/auth.dart';

class DriverSettingsScreen extends StatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  State<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends State<DriverSettingsScreen> {
  late VoidCallback onBackPress;
  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 23.0,
            bottom: 20.0,
            left: 0.0,
            right: 0.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //TopRectangle(
              Container(
                color: Colors.black,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color.fromRGBO(255, 242, 0, 1.0)),
                        onPressed: onBackPress,
                      ),
                    ),
                    const Text("Settings",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            backgroundColor: Colors.black,
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 36.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas"))
                  ],
                ),
              ),
              //),

              SettingRec(
                child: ListTile(
                    leading: const Icon(Icons.assignment,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Terms and Conditions",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DocumentsScreen()));
                    }),
              ),

              SettingRec(
                child: ListTile(
                    leading: const Icon(Icons.monetization_on,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Payment",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const VehiclesScreen()));
                      //builder: (context) => PaymentScreen()));
                    }),
              ),
              SettingRec(
                child: ListTile(
                    leading: const Icon(Icons.account_box,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Edit Account",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()));
                    }),
              ),
              SettingRec(
                child: ListTile(
                    leading: const Icon(Icons.lock,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Privacy Policy",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const LegalInformationScreen()));
                    }),
              ),

              SettingRec(
                child: ListTile(
                    leading: const Icon(Icons.not_interested,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Log Out",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      _logOut();

                      Navigator.of(context).pushNamed("/root");
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _logOut() async {
  AuthService().signOut();
}

class TopRectangle extends StatelessWidget {
  final Color? color;
  final double height;
  final double width;
  final Widget child;

  const TopRectangle(
      {super.key,
      required this.child,
      this.color,
      this.height = 100.0,
      this.width = 500.0});

  @override
  build(context) {
    return Container(
      width: width,
      height: height,
      color: Colors.white,
      child: child,
    );
  }
}

class SettingRec extends StatelessWidget {
  final Color? color;
  final decoration;
  final double width;
  final double height;
  // final borderWidth;
  final Widget child;
  const SettingRec(
      {super.key,
      required this.child,
      this.color,
      this.width = 500.0,
      this.decoration,
      this.height = 55.0});

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

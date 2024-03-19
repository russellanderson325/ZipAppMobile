import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zipapp/ui/screens/documents_screen.dart';
import 'package:zipapp/ui/screens/payment/default_tip_screen.dart';
import 'package:zipapp/ui/screens/legal_info_screen.dart';
import 'package:zipapp/ui/screens/safety_features_screen.dart';
import 'package:zipapp/business/auth.dart';
import 'package:mailto/mailto.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
        //backgroundColor: Colors.grey[70],
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
              TopRectangle(
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
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 36.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas"))
                  ],
                ),
              ),
              SettingRec(
                child: ListTile(
                    leading: const Icon(Icons.account_box,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Rules & Safety",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SafetyFeaturesScreen()));
                    }

                    //child: Icon(Icons.account_box, size: 28.0, color: Colors.white),

                    ),
              ),
              SettingRec(
                child: ListTile(
                    leading: const Icon(Icons.monetization_on,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Default Tip",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DefaultTipScreen()));
                    }),
              ),
              SettingRec(
                child: ListTile(
                    leading: const Icon(Icons.drive_eta,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Drive with Zip",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      funcOpenMailComposer();
                    }),
              ),
              SettingRec(
                child: ListTile(
                    leading: const Icon(Icons.assignment,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Terms and Conditions",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
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
                    leading: const Icon(Icons.lock,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Privacy Policy",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Bebas")),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LegalInformationScreen()));
                    }),
              ),
              SettingRec(
                child: ListTile(
                    leading: const Icon(Icons.lock,
                        size: 28.0, color: Color.fromRGBO(255, 242, 0, 1.0)),
                    title: const Text("Sign Out",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromRGBO(255, 242, 0, 1.0),
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

class TopRectangle extends StatelessWidget {
  final color;
  final height;
  final width;
  final child;

  const TopRectangle(
      {super.key,
      this.child,
      this.color,
      this.height = 100.0,
      this.width = 500.0});

  @override
  build(context) {
    return Container(
      width: width,
      height: height,
      color: Colors.black,
      child: child,
    );
  }
}

void _logOut() async {
  AuthService().signOut();
}

class SettingRec extends StatelessWidget {
  final color;
  final decoration;
  final width;
  final height;
  // final borderWidth;
  final child;
  const SettingRec(
      {super.key,
      this.child,
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

void funcOpenMailComposer() async {
  final mailtoLink = Mailto(
    to: ['info@zipgameday.com'],
    subject: 'New Driver',
    body: '',
  );
  await launchUrlString('$mailtoLink');
}

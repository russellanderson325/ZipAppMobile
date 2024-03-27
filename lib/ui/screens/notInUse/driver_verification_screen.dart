import "package:flutter/material.dart";
import "package:zipapp/ui/widgets/custom_text_field.dart";
import 'package:zipapp/business/validator.dart';
import 'package:zipapp/ui/screens/notInUse/main_screen.dart';
import 'package:zipapp/ui/widgets/custom_flat_button.dart';
import 'package:zipapp/ui/widgets/custom_alert_dialog.dart';
import 'package:zipapp/CustomIcons/custom_icons_icons.dart';
import 'package:zipapp/ui/screens/notInUse/driver_main_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _password = TextEditingController();
  late CustomTextField _passwordField;
  final bool _blackVisible = false;
  late VoidCallback onBackPress;
  late VoidCallback backHome;

  @override
  void initState() {
    super.initState();

    onBackPress = () {
      Navigator.of(context).pop();
    };

    backHome = () {
      onBackPress();
      print('back home clicked');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const MainScreen()));
    };

    _passwordField = CustomTextField(
      baseColor: Colors.grey[400] ?? Colors.grey,
      borderColor: Colors.grey[400] ?? Colors.grey,
      errorColor: Colors.red,
      controller: _password,
      obscureText: true,
      hint: "Password",
      validator: Validator.validatePassword,
      customTextIcon: Icon(CustomIcons.lock, color: Colors.grey[400]),
    );
  }

/*
  Uses CustomTextField widget to display text entry areas.
  Calls _emailLogin to verify information and allow customers into main page.
  Forgot Password uses Firebase's reset password function, which sends a reset password
  email to the entered email address.
*/
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
                        "Driver Portal",
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
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 20.0, left: 15.0, right: 15.0),
                      child: _passwordField,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 40.0),
                      child: CustomTextButton(
                        title: "Log In",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        textColor: Colors.black,
                        onPressed: () {
                          if (_password.text == "password") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DriverMainScreen()));
                          } else {
                            _showErrorAlert(
                              title: "Login failed",
                              content: "Incorrect password",
                              onPressed: _retryVerify,
                            );
                          }
                          // _emailLogin(
                          //     email: _email.text,
                          //     password: _password.text,
                          //     context: context);
                        },
                        color: const Color.fromRGBO(255, 242, 0, 1.0),
                        borderColor: const Color.fromRGBO(212, 20, 15, 1.0),
                        borderWidth: 0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          //top: 0.0, bottom: 60.0, left: 10.0, right: 0.0),
                          top: 50.0,
                          bottom: 20.0,
                          left: 10.0,
                          right: 0.0),
                      child: CustomTextButtonWithUnderline(
                        title: "Not a driver?",
                        textColor: const Color.fromRGBO(255, 242, 0, 1.0),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainScreen()));
                        },
                        color: Colors.black,
                        splashColor: Colors.grey[100] ?? Colors.grey,
                        borderColor: Colors.black,
                        borderWidth: 0.0,
                      ),
                    ),
                  ],
                ),
                SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: backHome,
                  ),
                ),
              ],
            ),
            Offstage(
              offstage: !_blackVisible,
              child: GestureDetector(
                onTap: () {},
                child: AnimatedOpacity(
                  opacity: _blackVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.ease,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _changeBlackVisible() {
  //   setState(() {
  //     _blackVisible = !_blackVisible;
  //   });
  // }

  void _retryVerify() {
    onBackPress();
    print('close alert');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MainScreen()));
  }

  /*
    Verifies email and password, then navigates to apps main page
    if information is valid.
  */

  void _showErrorAlert(
      {required String title,
      required String content,
      required VoidCallback onPressed}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          content: content,
          title: title,
          onPressed: onPressed,
        );
      },
    );
  }

  Widget buildAlertTextField(BuildContext context, String title,
      TextEditingController controller, VoidCallback onPressed) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(5.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      title: Text(
        title,
        softWrap: true,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          decoration: TextDecoration.none,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: "Bebas",
        ),
      ),
    );
  }
}

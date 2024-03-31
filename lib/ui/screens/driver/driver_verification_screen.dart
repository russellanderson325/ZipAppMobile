import "package:flutter/material.dart";
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/screens/driver/driver_main_screen.dart';
import 'package:zipapp/ui/widgets/authentication_drawer_widgets.dart';
import 'package:zipapp/ui/screens/main_screen.dart';
import 'package:zipapp/ui/widgets/custom_flat_button.dart';
import 'package:zipapp/ui/widgets/custom_alert_dialog.dart';

class DriverVerificationScreen extends StatefulWidget {
  const DriverVerificationScreen({super.key});

  @override
  State<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState extends State<DriverVerificationScreen> {
  final AuthenticationDrawerWidgets adw = AuthenticationDrawerWidgets();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

/*
  Uses CustomTextField widget to display text entry areas.
  Calls _emailLogin to verify information and allow customers into main page.
  Forgot Password uses Firebase's reset password function, which sends a reset password
  email to the entered email address.
*/
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Verification Portal',
            style: ZipDesign.pageTitleText),
        backgroundColor: ZipColors.primaryBackground,
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.all(0),
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: ZipColors.primaryBackground,
      body: Container(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: screenWidth - 96,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 32),
                adw.promptTextLabel('Password'),
                adw.inputTextField(passwordController, true, null),
                const SizedBox(height: 16),
                CustomTextButton(
                  title: "Log In",
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.black,
                  color: ZipColors.zipYellow,
                  onPressed: () {
                    if (passwordController.text == 'password') {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DriverMainScreen(),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DriverMainScreen(),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 64),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                      'Want to join our team as a driver? Enter your email below.',
                      style: ZipDesign.sectionTitleText),
                ),
                const SizedBox(height: 16),
                adw.promptTextLabel('Email'),
                adw.inputTextField(emailController, false, null),
                const SizedBox(height: 16),
                CustomTextButton(
                  title: "Join our team",
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.black,
                  color: ZipColors.zipYellow,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _retryVerify() {
    Navigator.of(context).pop();
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

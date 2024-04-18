import "package:flutter/material.dart";
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/business/validator.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/screens/driver_only/driver_main_screen.dart';
import 'package:zipapp/ui/widgets/authentication_drawer_widgets.dart';

class DriverVerificationScreen extends StatefulWidget {
  const DriverVerificationScreen({super.key});

  @override
  State<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState extends State<DriverVerificationScreen> {
  final AuthenticationDrawerWidgets adw = AuthenticationDrawerWidgets();
  final UserService userService = UserService();
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Driver Portal', style: ZipDesign.pageTitleText),
        scrolledUnderElevation: 0,
        titleSpacing: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 32.0),
            const Text(
              'Drive for Zip!',
              style: ZipDesign.sectionTitleText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Please sign in below with your driver account password.',
              style: ZipDesign.disabledBodyText.copyWith(fontSize: 14.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            adw.promptTextLabel('Password'),
            adw.inputTextField(
              controller: passwordController,
              obscureText: true,
              validator: Validator.validatePassword,
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {},
              child: Text(
                'Forgot Password?',
                style: ZipDesign.tinyLightText.copyWith(color: Colors.black),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 32.0),
            TextButton(
              onPressed: () {
                if (passwordController.text ==
                    userService.user.driverPassword) {
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
              style: ZipDesign.yellowButtonStyle,
              child: const Text('Sign in as Driver'),
            ),
          ],
        ),
      ),
    );
  }
}

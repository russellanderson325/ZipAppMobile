import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zipapp/business/auth.dart';
import 'package:zipapp/business/validator.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/ui/widgets/authentication_drawer_widgets.dart';
import 'package:zipapp/ui/widgets/custom_alert_dialog.dart';
import 'package:zipapp/ui/widgets/custom_flat_button.dart';

class SignInDrawer extends StatefulWidget {
  final Function switchDrawers;
  const SignInDrawer({super.key, required this.switchDrawers});

  @override
  State<SignInDrawer> createState() => _SignInDrawerState();
}

class _SignInDrawerState extends State<SignInDrawer> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _forgotPass = TextEditingController();

  AuthenticationDrawerWidgets adw = AuthenticationDrawerWidgets();

  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      alignment: Alignment.topCenter,
      width: width,
      height: height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          topLeft: Radius.circular(32),
        ),
      ),
      child: SizedBox(
        width: width - 96,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 16),
            Center(child: adw.draggableIcon()),
            const SizedBox(height: 16),
            const Center(
                child: Text('Log in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 24,
                        fontWeight: FontWeight.w600))),
            const SizedBox(height: 26),
            adw.promptTextLabel('Email'),
            adw.inputTextField(
                controller: _emailController,
                obscureText: false,
                validator: Validator.validateEmail),
            adw.promptTextLabel('Password'),
            adw.inputTextField(
                controller: _passwordController,
                obscureText: true,
                validator: Validator.validatePassword),
            Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 53.0),
                child: CustomTextButton(
                    title: 'Log in',
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    onPressed: () => _emailLogin(
                        email: _emailController.text,
                        password: _passwordController.text),
                    color: ZipColors.zipYellow)),
            CustomTextButton(
              title: 'Forgot your password?',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              onPressed: () {},
              //() async {
              //   await showDialog(
              //     barrierDismissible: false,
              //     context: context,
              //     builder: (context) {
              //       return buildAlertTextField(
              //           context, "Forgot Password", _forgotPass);
              //     },
              //   );
              // },
            ),
            const SizedBox(height: 190),
            _buildCreateAccountButton(),
            const SizedBox(height: 33)
          ],
        ),
      ),
    );
  }

  void _emailLogin({String? email, String? password}) async {
    /// Validates email and password fields
    if (Validator.validateEmail(email!) &&
        Validator.validatePassword(password!)) {
      try {
        /// Hides native keyboard
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await auth.signIn(email, password);
      } catch (e) {
        String exception = auth.getExceptionText(e as PlatformException);
        _showErrorAlert(
          title: "Login failed",
          content: exception,
        );
      }
    }
  }

  void _showErrorAlert(
      {String? title, String? content, VoidCallback? onPressed}) {
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

  Widget _buildCreateAccountButton() {
    return GestureDetector(
        onTap: () {
          widget.switchDrawers.call();
        },
        child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Don't have an account? Create one",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Lexend',
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              Icon(Icons.arrow_forward, color: Colors.black, size: 12),
            ]));
  }
}

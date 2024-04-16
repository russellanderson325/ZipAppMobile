import "package:flutter/material.dart";
import 'package:zipapp/business/auth.dart';
import 'package:flutter/services.dart';
import 'package:zipapp/CustomIcons/custom_icons_icons.dart';
import 'package:zipapp/business/validator.dart';
import 'package:zipapp/main.dart';
import 'package:zipapp/ui/widgets/custom_alert_dialog.dart';
import 'package:zipapp/ui/widgets/custom_flat_button.dart';
import 'package:zipapp/ui/widgets/custom_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _forgotPass = TextEditingController();
  late CustomTextField _emailField;
  late CustomTextField _passwordField;
  bool _blackVisible = false;
  late VoidCallback onBackPress;
  final auth = AuthService();

  @override
  void initState() {
    super.initState();

    onBackPress = () {
      Navigator.of(context).pop();
    };

    _emailField = CustomTextField(
        baseColor: Colors.grey[400] ?? Colors.grey,
        borderColor: Colors.grey[400] ?? Colors.grey,
        errorColor: Colors.red,
        controller: _email,
        hint: "E-mail Address",
        inputType: TextInputType.emailAddress,
        validator: Validator.validateEmail,
        customTextIcon: Icon(Icons.mail, color: Colors.grey[400]));
    _passwordField = CustomTextField(
      baseColor: Colors.grey[400] ?? Colors.grey,
      borderColor: Colors.grey[400] ?? Colors.grey,
      errorColor: Colors.red,
      controller: _password,
      obscureText: true,
      hint: "Password",
      validator: Validator.validatePassword,
      customTextIcon: Icon(CustomIcons.lock, color: Colors.grey.shade400),
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
                        "Sign In",
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
                            top: 20.0, bottom: 10.0, left: 15.0, right: 15.0),
                        child: _emailField),
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
                          _emailLogin(
                              email: _email.text,
                              password: _password.text,
                              context: context);
                        },
                        borderColor: const Color.fromRGBO(212, 20, 15, 1.0),
                        borderWidth: 0,
                        color: const Color.fromRGBO(255, 242, 0, 1.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 20.0, left: 10.0, right: 0.0),
                      child: CustomTextButton(
                        title: "Forgot Password?",
                        textColor: const Color.fromRGBO(255, 242, 0, 1.0),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        onPressed: () async {
                          await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return buildAlertTextField(
                                  context,
                                  "Forgot Password",
                                  _forgotPass,
                                  _changeBlackVisible);
                            },
                          );
                        },
                        color: Colors.black,
                        borderColor: Colors.black,
                        borderWidth: 0.0,
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
                        title: "Don't have an account?",
                        textColor: const Color.fromRGBO(255, 242, 0, 1.0),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        onPressed: () {
                          Navigator.of(context).pushNamed("/signup");
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
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBackPress,
                    color: const Color.fromRGBO(255, 242, 0, 1.0),
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

  void _changeBlackVisible() {
    setState(() {
      _blackVisible = !_blackVisible;
    });
  }

  /*
    Verifies email and password, then navigates to apps main page
    if information is valid.
  */
  void _emailLogin(
      {String? email, String? password, BuildContext? context}) async {
    /// Validates email and password fields
    if (Validator.validateEmail(email!) &&
        Validator.validatePassword(password!)) {
      try {
        /// Hides native keyboard
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        _changeBlackVisible();
        await auth
            .signIn(email, password)
            .then((uid) => Navigator.of(context!).pop());
      } catch (e) {
        String exception = auth.getExceptionText(e as PlatformException);
        _showErrorAlert(
          title: "Login failed",
          content: exception,
          onPressed: _changeBlackVisible,
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
          fontFamily: "Poppins",
        ),
      ),
      content: SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: controller,
              autofocus: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  hintText: "Enter email",
                  hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: "Bebas",
                      fontWeight: FontWeight.w300,
                      decoration: TextDecoration.none),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.black))),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Builder(
                builder: (BuildContext context) {
                  return CustomTextButton(
                    title: "OK",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    textColor: Colors.black54,
                    onPressed: () async {
                      try {
                        await auth.sendResetPassword(_forgotPass.text);
                      } catch (e) {
                        String exception =
                            auth.getExceptionText(e as PlatformException);
                        _showErrorAlert(
                          title: "Error sending reset password email",
                          content: exception,
                          onPressed: _changeBlackVisible,
                        );
                      }
                      navigatorKey.currentState?.pop();
                    },
                    borderColor: Colors.black12,
                    borderWidth: 2,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

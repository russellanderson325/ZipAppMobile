import 'dart:core';
import "package:flutter/material.dart";
// import 'package:zip/business/auth.dart';
import 'package:zipapp/business/validator.dart';
import 'package:flutter/services.dart';
import 'package:zipapp/ui/widgets/custom_alert_dialog.dart';
// import 'package:zip/models/user.dart';
import 'package:zipapp/ui/widgets/custom_flat_button.dart';
import 'package:zipapp/ui/widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  late CustomTextField _firstnameField;
  late CustomTextField _lastnameField;
  late CustomTextField _phoneField;
  late CustomTextField _emailField;
  late CustomTextField _passwordField;
  bool _blackVisible = false;
  late VoidCallback onBackPress;

  var pastRides = [];
  var pastDrives = [];

  // final auth = AuthService();

  @override
  void initState() {
    super.initState();

    onBackPress = () {
      Navigator.of(context).pop();
    };

/*
  Custom text widget that can be found in 'widgets' folder
*/
    _firstnameField = CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400] ?? Colors.grey,
      errorColor: Colors.red,
      controller: _firstname,
      hint: "First Name",
      validator: Validator.validateName,
      customTextIcon: Icon(Icons.person, color: Colors.grey[400]),
    );
    _lastnameField = CustomTextField(
        baseColor: Colors.grey,
        borderColor: Colors.grey[400] ?? Colors.grey,
        errorColor: Colors.red,
        controller: _lastname,
        hint: "Last Name",
        validator: Validator.validateName,
        customTextIcon: Icon(Icons.person, color: Colors.grey[400]));
    _phoneField = CustomTextField(
        baseColor: Colors.grey[400] ?? Colors.grey,
        borderColor: Colors.grey[400] ?? Colors.grey,
        errorColor: Colors.red,
        controller: _number,
        hint: "Phone Number",
        validator: Validator.validateNumber,
        inputType: TextInputType.number,
        customTextIcon: Icon(Icons.phone, color: Colors.grey[400]));
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
        customTextIcon: Icon(Icons.lock, color: Colors.grey[400]));
  }

/*
  Shows the basic UI so users can sign up for an account.
  Once, users enter information and click 'Submit' the widget will
  call the function _signup which will validate and create a account with
  the users information.
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
                        "Create new account",
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Bebas",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 15.0, right: 15.0),
                      child: _firstnameField,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 15.0, right: 15.0),
                      child: _lastnameField,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 15.0, right: 15.0),
                      child: _phoneField,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 15.0, right: 15.0),
                      child: _emailField,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 15.0, right: 15.0),
                      child: _passwordField,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 25.0, horizontal: 40.0),
                      child: CustomTextButton(
                        title: "Sign Up",
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        textColor: Colors.black,
                        onPressed: () {
                          // _signUp(
                          //     firstname: _firstname.text,
                          //     lastname: _lastname.text,
                          //     email: _email.text,
                          //     number: _number.text,
                          //     password: _password.text);
                        },
                        splashColor: Colors.black12,
                        borderColor: const Color.fromRGBO(59, 89, 152, 1.0),
                        borderWidth: 0,
                        color: const Color.fromRGBO(255, 242, 0, 1.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, bottom: 60.0, left: 10.0, right: 0.0),
                      child: CustomTextButtonWithUnderline(
                        title: "Already have an account?",
                        textColor: const Color.fromRGBO(255, 242, 0, 1.0),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        onPressed: () {
                          Navigator.of(context).pushNamed("/signin");
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
  Validates entered information.
  If information is valid, add a new user.
  Else, have user enter new information.
*/
  // void _signUp(
  //     {String firstname,
  //     String lastname,
  //     String number,
  //     String email,
  //     String password,
  //     BuildContext context}) async {
  //   if (Validator.validateName(firstname) &&
  //       Validator.validateName(lastname) &&
  //       Validator.validateEmail(email) &&
  //       Validator.validateNumber(number) &&
  //       Validator.validatePassword(password)) {
  //     try {
  //       SystemChannels.textInput.invokeMethod('TextInput.hide');
  //       _changeBlackVisible();
  //       await auth.signUp(email, password).then((uid) {
  //         auth.addUser(User(
  //           uid: uid,
  //           email: email,
  //           firstName: firstname,
  //           lastName: lastname,
  //           phone: number,
  //           profilePictureURL: '',
  //           lastActivity: DateTime.now(),
  //           pastRides: [],
  //           pastDrives: [],
  //         ));
  //         onBackPress();
  //       });
  //     } catch (e) {
  //       print("Error in sign up: $e");
  //       String exception = auth.getExceptionText(e);
  //       _showErrorAlert(
  //         title: "Signup failed",
  //         content: exception,
  //         onPressed: _changeBlackVisible,
  //       );
  //     }
  //   }
  // }

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
}

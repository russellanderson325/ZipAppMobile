import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import 'package:zipapp/business/auth.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/business/validator.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/authentication_drawer_widgets.dart';
import 'package:zipapp/ui/widgets/custom_flat_button.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late String buttonText;
  late bool dirty;

  final AuthService authService = AuthService();
  final UserService userService = UserService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late String firstName;
  late String lastName;
  late String email;
  late String phone;

  AuthenticationDrawerWidgets adw = AuthenticationDrawerWidgets();

  @override
  void initState() {
    super.initState();
    buttonText = 'Cancel';
    dirty = false;
    _firstNameController
        .addListener(() => _listenerFunction(_firstNameController));
    _lastNameController
        .addListener(() => _listenerFunction(_lastNameController));
    _emailController.addListener(() => _listenerFunction(_emailController));
    _phoneController.addListener(() => _listenerFunction(_phoneController));
    _passwordController
        .addListener(() => _listenerFunction(_passwordController));
    firstName = userService.user.firstName.toProperCase();
    lastName = userService.user.lastName.toProperCase();
    email = userService.user.email;
    phone = userService.user.phone;
  }

  void _listenerFunction(TextEditingController controller) {
    setState(() {
      if (controller.text.isNotEmpty) {
        buttonText = 'Save Changes';
        dirty = true;
      } else {
        buttonText = 'Cancel';
        dirty = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 96,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const SizedBox(height: 80),
                  const Center(
                    child: Text('Edit Account', style: ZipDesign.pageTitleText),
                  ),
                  const SizedBox(height: 32),
                  adw.promptTextLabel('first name'),
                  adw.inputTextField(_firstNameController, false,
                      () => Validator.validateName(_firstNameController.text)),
                  const SizedBox(height: 16),
                  adw.promptTextLabel('last name'),
                  adw.inputTextField(_lastNameController, false,
                      () => Validator.validateName(_lastNameController.text)),
                  const SizedBox(height: 16),
                  adw.promptTextLabel('email'),
                  adw.inputTextField(_emailController, false,
                      () => Validator.validateEmail(_emailController.text)),
                  const SizedBox(height: 16),
                  adw.promptTextLabel('phone number'),
                  adw.inputTextField(_phoneController, false,
                      () => Validator.validateNumber(_phoneController.text)),
                  const SizedBox(height: 16),
                  adw.promptTextLabel('password'),
                  adw.inputTextField(
                      _passwordController,
                      true,
                      () =>
                          Validator.validatePassword(_passwordController.text)),
                  const SizedBox(height: 48),
                  CustomTextButton(
                    title: buttonText,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: ZipColors.zipYellow,
                    onPressed: () {
                      if (dirty) {
                        _changeAccountDetails(
                          inFirstName: _firstNameController.text,
                          inLastName: _lastNameController.text,
                          inEmail: _emailController.text,
                          inPhone: _phoneController.text,
                        );
                      }
                      Navigator.pop(
                          context, [firstName, lastName, email, phone]);
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeAccountDetails({
    required String inFirstName,
    required String inLastName,
    required String inPhone,
    required String inEmail,
  }) {
    if (inFirstName.isNotEmpty) {
      setState(() {
        firstName = inFirstName.toProperCase();
      });
    }
    if (inLastName.isNotEmpty) {
      setState(() {
        lastName = inLastName.toProperCase();
      });
    }
    if (inEmail.isNotEmpty) {
      setState(() {
        email = inEmail;
      });
    }
    if (inPhone.isNotEmpty) {
      setState(() {
        phone = inPhone;
      });
    }
    authService.changeUserData(
      userService.user.uid,
      firstName,
      lastName,
      email,
      phone,
    );
    setState(() {
      dirty = false;
    });
  }
}

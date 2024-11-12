import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/business/validator.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/screens/driver_only/driver_main_screen.dart';
import 'package:zipapp/ui/widgets/authentication_drawer_widgets.dart';
import 'package:zipapp/ui/widgets/custom_alert_dialog.dart';

enum RequestStatus { unsubmitted, submitted, denied, approved }

class DriverPortal extends StatefulWidget {
  const DriverPortal({super.key});

  @override
  State<DriverPortal> createState() => _DriverPortalState();
}

class _DriverPortalState extends State<DriverPortal> {
  AuthenticationDrawerWidgets adw = AuthenticationDrawerWidgets();
  final UserService userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController driverPasswordController =
      TextEditingController();
  final TextEditingController confirmDriverPasswordController =
      TextEditingController();

  bool frontImageAdded = false;
  bool rearImageAdded = false;

  RequestStatus requestStatus = RequestStatus.unsubmitted;

  late int daysTillNextRequest;
  String denialReason = '';

  late bool validDriverPasswords;

  @override
  void initState() {
    super.initState();
    firstNameController.text = userService.user.firstName;
    lastNameController.text = userService.user.lastName;
    _getRequestStatus();
    validDriverPasswords = false;
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 32.0),
            const Text(
              'Become a driver for Zip!',
              style: ZipDesign.sectionTitleText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Request to become a driver with Zip to start earning '
              'money. We will review your request and get back to you'
              ' if you\'ve been accepted.',
              style: ZipDesign.disabledBodyText.copyWith(fontSize: 14.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            Expanded(
              child: listContent(),
            ),
          ],
        ),
      ),
    );
  }

  void _getRequestStatus() {
    // get request status from database
    RequestStatus rs = RequestStatus.unsubmitted;
    if (rs == RequestStatus.submitted) {
      // get request details
    }
    if (rs == RequestStatus.approved) {
      // get driver details
    }
    if (rs == RequestStatus.denied) {
      // get denial details
      _getDenialReason();
    }
    if (rs == RequestStatus.unsubmitted) {
      // get user details
      setState(() {
        daysTillNextRequest = 0;
      });
    }
    setState(() {
      requestStatus = rs;
    });
  }

  void _getDenialReason() {
    // get denial reason from database
    denialReason = 'The information on your drivers license does'
        ' not match the information in your account.';
  }

  Widget listContent() {
    if (requestStatus == RequestStatus.submitted) {
      return submittedView();
    } else if (requestStatus == RequestStatus.approved) {
      return approvedView();
    } else if (requestStatus == RequestStatus.denied) {
      return deniedView();
    } else {
      return unsubmittedView();
    }
  }

  Widget submittedView() {
    return ListView(children: <Widget>[
      adw.promptTextLabel('You\'ve requested!'),
      const SizedBox(height: 8.0),
      adw.infoTextBubble(
          'Please allow some time for us to review the details of your request.'),
      const SizedBox(height: 32.0),
      Center(
        child: Container(
          decoration: BoxDecoration(
            color: ZipColors.submittedYellow,
            border:
                Border.all(color: ZipColors.submittedYellowBorder, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${userService.user.firstName} ${userService.user.lastName}\'s Request',
                  style: ZipDesign.bodyText,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Updated At', style: ZipDesign.disabledBodyText),
                    Text('04/03/2024 at 8:45 AM', style: ZipDesign.bodyText)
                  ],
                ),
                const SizedBox(height: 8.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Status', style: ZipDesign.disabledBodyText),
                    Text('In Review', style: ZipDesign.bodyText)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget approvedView() {
    return ListView(children: <Widget>[
      adw.promptTextLabel('You\'re a driver!'),
      const SizedBox(height: 8.0),
      adw.infoTextBubble(
          'Congratulations, you have been accepted to be a driver with Zip!'),
      const SizedBox(height: 32.0),
      Center(
        child: Container(
          decoration: BoxDecoration(
            color: ZipColors.approvedGreen,
            border:
                Border.all(color: ZipColors.approvedGreenBorder, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${userService.user.firstName} ${userService.user.lastName}\'s Request',
                  style: ZipDesign.bodyText,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Updated At', style: ZipDesign.disabledBodyText),
                    Text('04/03/2024 at 8:45 AM', style: ZipDesign.bodyText)
                  ],
                ),
                const SizedBox(height: 8.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Status', style: ZipDesign.disabledBodyText),
                    Text('Accepted', style: ZipDesign.bodyText)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 32.0),
      adw.promptTextLabel('Password'),
      adw.inputTextField(
          controller: driverPasswordController,
          obscureText: true,
          validator: Validator.validatePassword,
          onChanged: _validatePassword),
      const SizedBox(height: 16.0),
      adw.promptTextLabel('Confirm Password'),
      adw.inputTextField(
          controller: confirmDriverPasswordController,
          obscureText: true,
          validator: Validator.validatePassword,
          onChanged: _validatePassword),
      const SizedBox(height: 16.0),
      adw.infoIconTextBubble(
          'Your driver password cannot be the same as your '
          'rider password and must be at least 6 characters long',
          LucideIcons.alertTriangle),
      const SizedBox(height: 32.0),
      TextButton(
        onPressed: validDriverPasswords
            ? () {
                updateDriverPassword(driverPasswordController.text);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverMainScreen(),
                  ),
                );
              }
            : null,
        style: validDriverPasswords
            ? ZipDesign.yellowButtonStyle
            : ZipDesign.disabledYellowButtonStyle,
        child: const Text('Login as Driver'),
      ),
      const SizedBox(height: 16.0)
    ]);
  }

  Future<void> updateDriverPassword(String password) async {
    try {
      await _firestore.collection('users').doc(userService.user.uid).update({
        'driverPassword': password,
        'isDriver': true,
      });
    } catch (e) {
      print(e);
    }
  }

  bool _validatePassword() {
    bool local = Validator.validatePassword(driverPasswordController.text) &&
        driverPasswordController.text == confirmDriverPasswordController.text;
    if (local) {
      print("Worked");
      setState(() {
        validDriverPasswords = local;
      });
    } else {
      _showErrorAlert(
        title: "Invalid Email",
        content: "Please enter a valid email address.",
        onPressed: () {},
      );
    }
    return local;
  }

  Widget deniedView() {
    return ListView(
      children: <Widget>[
        adw.promptTextLabel('We\'re sorry.'),
        const SizedBox(height: 8.0),
        adw.infoTextBubble('Unfortunately, we have decided to '
            'deny your request to be a driver at this time.'),
        const SizedBox(height: 32.0),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: ZipColors.deniedRed,
              border: Border.all(color: ZipColors.deniedRedBorder, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${userService.user.firstName} ${userService.user.lastName}\'s Request',
                    style: ZipDesign.bodyText,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16.0),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Updated At', style: ZipDesign.disabledBodyText),
                      Text('04/03/2024 at 8:45 AM', style: ZipDesign.bodyText)
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Status', style: ZipDesign.disabledBodyText),
                      Text('Denied', style: ZipDesign.bodyText)
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32.0),
        adw.promptTextLabel('Reasoning'),
        const SizedBox(height: 8.0),
        Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: TailwindColors.gray300, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 24, 24),
              child: Text(
                denialReason,
                style: ZipDesign.disabledBodyText,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32.0),
        TextButton(
          onPressed: daysTillNextRequest > 0
              ? null
              : () {
                  setState(() {
                    requestStatus = RequestStatus.approved;
                  });
                },
          style: daysTillNextRequest > 0
              ? ZipDesign.disabledYellowButtonStyle
              : ZipDesign.yellowButtonStyle,
          child: Text('Request again in $daysTillNextRequest days'),
        )
      ],
    );
  }

  Widget unsubmittedView() {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        adw.promptTextLabel('First Name'),
        const SizedBox(height: 8.0),
        adw.inputTextField(
            controller: firstNameController,
            obscureText: false,
            validator: Validator.validateName),
        const SizedBox(height: 16.0),
        adw.promptTextLabel('Last Name'),
        const SizedBox(height: 8.0),
        adw.inputTextField(
            controller: lastNameController,
            obscureText: false,
            validator: Validator.validateName),
        const SizedBox(height: 16.0),
        adw.promptTextLabel('Drivers License (front)'),
        const SizedBox(height: 8.0),
        dLFront(),
        const SizedBox(height: 16.0),
        adw.promptTextLabel('Drivers License (back)'),
        const SizedBox(height: 8.0),
        dLRear(),
        const SizedBox(height: 16.0),
        adw.infoIconTextBubble(
            'The information on your drivers license'
            ' should match the information on your account.',
            LucideIcons.alertTriangle),
        const SizedBox(height: 16.0),
        adw.promptTextLabel('Comments'),
        adw.commentsBox('Please provide us with any information'
            ' regarding this request...'),
        const SizedBox(height: 32.0),
        TextButton(
          onPressed: validateForm()
              ? () {
                  setState(() {
                    requestStatus = RequestStatus.approved;
                  });
                }
              : null,
          style: validateForm()
              ? ZipDesign.yellowButtonStyle
              : ZipDesign.disabledYellowButtonStyle,
          child: const Text('Request'),
        ),
        const SizedBox(height: 16.0)
      ],
    );
  }

  Widget dLFront() {
    return SizedBox(
      height: 96.0,
      width: 361.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(8.0),
          dashPattern: const [10, 10],
          color: TailwindColors.gray300,
          strokeWidth: 1.0,
          child: frontImageAdded
              ? const Placeholder()
              : Center(
                  child: GestureDetector(
                    onTap: addFrontImage,
                    child: uploadText(),
                  ),
                ),
        ),
      ),
    );
  }

  void addFrontImage() {
    setState(() {
      frontImageAdded = true;
    });
  }

  Widget dLRear() {
    return SizedBox(
      height: 96.0,
      width: 361.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(8.0),
          dashPattern: const [10, 10],
          color: TailwindColors.gray300,
          strokeWidth: 1.0,
          child: rearImageAdded
              ? const Placeholder()
              : Center(
                  child: GestureDetector(
                    onTap: addRearImage,
                    child: uploadText(),
                  ),
                ),
        ),
      ),
    );
  }

  void addRearImage() {
    setState(() {
      rearImageAdded = true;
    });
  }

  Widget uploadText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          LucideIcons.imagePlus,
          color: TailwindColors.gray500,
          size: 24,
        ),
        Text(
          'Click to upload \nPNG or JPG (max 4MB)',
          style: ZipDesign.disabledBodyText.copyWith(fontSize: 14.0),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  bool validateForm() {
    return Validator.validateName(firstNameController.text) &&
        Validator.validateName(lastNameController.text) &&
        frontImageAdded &&
        rearImageAdded;
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
    ).then((value) {
      if (value != null && value) {
        Navigator.of(context).pop(); // Dismiss the dialog
      }
    });
  }
}

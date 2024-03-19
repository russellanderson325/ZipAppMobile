import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zipapp/constants/zip_colors.dart';
// import 'package:zip/ui/widgets/custom_flat_button.dart';
// import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
// import 'package:zip/business/auth.dart';
// import 'package:zip/ui/widgets/custom_gplus_fb_btn.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:zipapp/ui/widgets/custom_flat_button.dart';
import 'package:zipapp/ui/widgets/create_account_drawer.dart';
import 'package:zipapp/ui/widgets/sign_in_drawer.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _index = 0;

  late bool showCreateAccountDrawer;
  late bool showSignInDrawer;

  final int drawerDelayMS = 400;

  static final circleRows = <Widget>[
    const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.circle, color: Colors.black, size: 8),
        SizedBox(width: 4),
        Icon(Icons.circle, color: ZipColors.lightGray, size: 8),
        SizedBox(width: 4),
        Icon(Icons.circle, color: ZipColors.lightGray, size: 8),
      ],
    ),
    const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.circle, color: ZipColors.lightGray, size: 8),
        SizedBox(width: 4),
        Icon(Icons.circle, color: Colors.black, size: 8),
        SizedBox(width: 4),
        Icon(Icons.circle, color: ZipColors.lightGray, size: 8),
      ],
    ),
    const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.circle, color: ZipColors.lightGray, size: 8),
        SizedBox(width: 4),
        Icon(Icons.circle, color: ZipColors.lightGray, size: 8),
        SizedBox(width: 4),
        Icon(Icons.circle, color: Colors.black, size: 8),
      ],
    ),
  ];

  final List<Widget> carousel = [
    _buildCarouselItem('Find a ride with Zip', 0),
    _buildCarouselItem('Enjoy your ride', 1),
    _buildCarouselItem('Cheer on your team', 2)
  ];

  // void authLogin(Future<FirebaseUser> userFuture, BuildContext context) {
  //   userFuture.then((user) {
  //     if (user != null) {
  //       Navigator.of(context).pushNamed("/main");
  //     } else {
  //       _scaffoldKey.currentState.showSnackBar(SnackBar(
  //         content: Text("Login Failed"),
  //       ));
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _index = 0;
    Timer.periodic(const Duration(seconds: 3), (Timer t) => _cycleCarousel());
    showCreateAccountDrawer = false;
    showSignInDrawer = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: ZipColors.primaryBackground,
        resizeToAvoidBottomInset: false,
        body: Stack(alignment: Alignment.bottomCenter, children: <Widget>[
          ListView(
            children: <Widget>[
              const SizedBox(height: 64),
              Center(
                  child: Image.asset(
                'assets/two_tone_zip_black.png',
                height: 96,
                width: 96,
              )),
              const SizedBox(height: 24),
              carousel.elementAt(_index),
              Padding(
                padding: const EdgeInsets.only(top: 48, left: 64, right: 64),
                child: CustomTextButton(
                    title: "Join us",
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    textColor: Colors.black,
                    onPressed: () => showCreateAccount(),
                    color: ZipColors.zipYellow),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
                child: CustomTextButton(
                  title: "Login",
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.black,
                  onPressed: () => showSignIn(),
                ),
              ),
            ],
          ),
          AnimatedPositioned(
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: drawerDelayMS),
              left: 0,
              bottom: showCreateAccountDrawer ? 0 : -703,
              child: CreateAccountDrawer(
                closeDrawer: hideDrawers,
                switchDrawers: showSignIn,
              )),
          AnimatedPositioned(
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: drawerDelayMS),
              left: 0,
              bottom: showSignInDrawer ? 0 : -703,
              child: SignInDrawer(
                closeDrawer: hideDrawers,
                switchDrawers: showCreateAccount,
              )),
          // _drawerStatus == DrawerStatus.createAccount
          //     ? const CreateAccountDrawer()
          //     : const SizedBox(height: 0.0, width: 0.0),
          // _drawerStatus == DrawerStatus.signIn
          //     ? const SignInDrawer()
          //     : const SizedBox(height: 0.0, width: 0.0)
        ]));
  }

  static Widget _buildCarouselItem(String text, int dotToFill) {
    return Column(
      children: [
        Center(
            child: SizedBox(
                width: 244,
                height: 244,
                child: Container(
                  color: Colors.red,
                ))),
        const SizedBox(height: 16),
        Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Lexend',
                    color: Colors.black,
                    fontWeight: FontWeight.w600))),
        const SizedBox(height: 16),
        circleRows.elementAt(dotToFill)
      ],
    );
  }

  void _cycleCarousel() {
    setState(() {
      _index = (_index + 1) % 3;
    });
  }

  void hideDrawers() {
    setState(() {
      showCreateAccountDrawer = false;
      showSignInDrawer = false;
    });
  }

  void showCreateAccount() {
    if (showSignInDrawer) {
      setState(() {
        showSignInDrawer = false;
      });
      Future.delayed(const Duration(milliseconds: 100), () {});
    }
    setState(() => showCreateAccountDrawer = true);
    // setState(() {
    //   if (showSignInDrawer) {
    //     showSignInDrawer = false;
    //     // showCreateAccountDrawer = true;
    //     Future.delayed(
    //         Duration(milliseconds: 100), () => showCreateAccountDrawer = true);
    //   } else {
    //     showCreateAccountDrawer = true;
    //   }
    // });
  }

  void showSignIn() {
    if (showCreateAccountDrawer) {
      setState(() {
        showCreateAccountDrawer = false;
      });
      Future.delayed(const Duration(milliseconds: 100), () {});
    }
    setState(() => showSignInDrawer = true);
    // setState(() {
    //   if (showCreateAccountDrawer) {
    //     showCreateAccountDrawer = false;
    //     // showSignInDrawer = true;
    //     Future.delayed(
    //         Duration(milliseconds: 100), () => showSignInDrawer = true);
    //   } else {
    //     showSignInDrawer = true;
    //   }
    // });
  }
}

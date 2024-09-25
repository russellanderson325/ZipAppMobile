import 'dart:async';
import 'package:flutter/material.dart';

import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/ui/widgets/custom_flat_button.dart';
import 'package:zipapp/ui/widgets/create_account_drawer.dart';
import 'package:zipapp/ui/widgets/sign_in_drawer.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _index = 0;

  late bool showCreateAccountDrawer;
  late bool showSignInDrawer;

  final int drawerDelayMS = 400;

  final DraggableScrollableController _signInScrollController =
      DraggableScrollableController();

  final DraggableScrollableController _createAccountScrollController =
      DraggableScrollableController();

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
      resizeToAvoidBottomInset: true,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
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
          DraggableScrollableSheet(
            initialChildSize: 0.0,
            controller: _createAccountScrollController,
            minChildSize: 0.0,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                  controller: scrollController,
                  child: CreateAccountDrawer(
                    switchDrawers: showSignIn,
                  ));
            },
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.0,
            controller: _signInScrollController,
            minChildSize: 0.0,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                  controller: scrollController,
                  child: SignInDrawer(
                    switchDrawers: showCreateAccount,
                  ));
            },
          ),
        ],
      ),
    );
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
    if (mounted) {
      setState(() {
        _index = (_index + 1) % 3;
      });
    }
  }

  void hideDrawers() {
    if (mounted) {
      setState(() {
        showCreateAccountDrawer = false;
        showSignInDrawer = false;
      });
    }
  }

  void showCreateAccount() {
    if (_signInScrollController.size > 0.0) {
      _signInScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
    }
    _createAccountScrollController.animateTo(0.85,
        duration: Duration(milliseconds: drawerDelayMS),
        curve: Curves.easeInOut);
  }

  void showSignIn() {
    if (_createAccountScrollController.size > 0.0) {
      _createAccountScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
    }
    _signInScrollController.animateTo(0.85,
        duration: Duration(milliseconds: drawerDelayMS),
        curve: Curves.easeInOut);
  }
}

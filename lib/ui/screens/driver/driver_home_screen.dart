import 'package:flutter/material.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/ui/widgets/map.dart' as mapwidget;

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0.0,
        leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 0),
            child: Image.asset(
              'assets/two_tone_zip_black.png',
              width: 40,
              height: 40,
            )),
        title: Text('Good afternoon, ${userService.user.firstName}',
            style: const TextStyle(
                fontSize: 24.0,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w500)),
      ),
      body: const Center(
        child: mapwidget.Map(driver: true),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/ui/screens/account_screen.dart';
import 'package:zipapp/ui/screens/driver/driver_activity_screen.dart';
import 'package:zipapp/ui/screens/driver/driver_home_screen.dart';
import 'package:zipapp/ui/screens/driver/driver_income_screen.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  final UserService userService = UserService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const DriverHomeScreen(),
      const DriverActivityScreen(),
      const DriverIncomeScreen(),
      const AccountScreen(driver: true),
    ];
    const List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Home',
          backgroundColor: Colors.black),
      BottomNavigationBarItem(
          icon: Icon(Icons.sticky_note_2),
          label: 'Activity',
          backgroundColor: Colors.black),
      BottomNavigationBarItem(
          icon: Icon(Icons.credit_card),
          label: 'Income',
          backgroundColor: Colors.black),
      BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
          backgroundColor: Colors.black),
    ];
    return Scaffold(
        body: Center(
          child: pages.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Container(
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: ZipColors.boxBorder))),
            child: BottomNavigationBar(
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(color: Colors.white10),
              selectedItemColor: Colors.white,
              unselectedLabelStyle: const TextStyle(color: Colors.white),
              unselectedItemColor: Colors.white70,
              backgroundColor: ZipColors.primaryBackground,
              items: items,
              currentIndex: _selectedIndex,
              onTap: _onBottomBarItemTapped,
            )));
  }

  void _onBottomBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
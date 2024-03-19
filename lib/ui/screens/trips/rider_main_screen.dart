import 'package:flutter/material.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/ui/screens/account/account_screen.dart';
import 'package:zipapp/ui/screens/main/home_screen.dart';
import 'package:zipapp/ui/screens/payment/payments_screen.dart';

class RiderMainScreen extends StatefulWidget {
  const RiderMainScreen({super.key});

  @override
  State<RiderMainScreen> createState() => _RiderMainScreenState();
}

class _RiderMainScreenState extends State<RiderMainScreen> {
  final UserService userService = UserService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const HomeScreen(),
      const Icon(
        Icons.call,
        size: 150,
      ),
      const PaymentsScreen(),
      const AccountScreen(),
    ];
    const List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Home',
          backgroundColor: ZipColors.primaryBackground),
      BottomNavigationBarItem(
          icon: Icon(Icons.sticky_note_2),
          label: 'Activity',
          backgroundColor: ZipColors.primaryBackground),
      BottomNavigationBarItem(
          icon: Icon(Icons.credit_card),
          label: 'Payments',
          backgroundColor: ZipColors.primaryBackground),
      BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
          backgroundColor: ZipColors.primaryBackground),
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
              selectedLabelStyle: const TextStyle(color: Colors.black),
              selectedItemColor: Colors.black,
              unselectedLabelStyle: const TextStyle(color: Colors.black),
              unselectedItemColor: Colors.black,
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

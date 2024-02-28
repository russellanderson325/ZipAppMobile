import 'package:flutter/material.dart';

import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/ui/screens/search_screen.dart';
import 'package:zipapp/ui/widgets/map.dart' as mapwidget;

typedef MyMarkerSetter = void Function(
    BuildContext context, void Function(LocalSearchResult) methodFromChild);
typedef MyTapToggle = void Function(
    BuildContext context, void Function() methodFromChild);
typedef MyMarkerReset = void Function(
    BuildContext context, void Function() methodFromChild);

class RiderMainScreen extends StatefulWidget {
  const RiderMainScreen({super.key});

  @override
  State<RiderMainScreen> createState() => _RiderMainScreenState();
}

class _RiderMainScreenState extends State<RiderMainScreen> {
  late void Function(LocalSearchResult) setMapMarkers;
  late void Function() toggleTapMode;
  late void Function() resetMarkers;

  final UserService userService = UserService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      mapwidget.Map(
        markerBuilder: (BuildContext context,
            void Function(LocalSearchResult) childMarkerSetter) {
          setMapMarkers = childMarkerSetter;
        },
        markerReset: (BuildContext context, void Function() childReset) {
          resetMarkers = childReset;
        },
      ),
      const Icon(
        Icons.call,
        size: 150,
      ),
      const Icon(
        Icons.camera,
        size: 150,
      ),
      const Icon(
        Icons.chat,
        size: 150,
      ),
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
        appBar: AppBar(
          backgroundColor: ZipColors.primaryBackground,
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
        body: Center(
          child: pages.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(color: Colors.black),
          selectedItemColor: Colors.black,
          unselectedLabelStyle: const TextStyle(color: Colors.black),
          unselectedItemColor: Colors.black,
          backgroundColor: ZipColors.primaryBackground,
          items: items,
          currentIndex: _selectedIndex,
          onTap: _onBottomBarItemTapped,
        ));
  }

  void _onBottomBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

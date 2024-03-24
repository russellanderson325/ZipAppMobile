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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late void Function(LocalSearchResult) setMapMarkers;
  late void Function() toggleTapMode;
  late void Function() resetMarkers;

  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
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
        child: mapwidget.Map(
          markerBuilder: (BuildContext context,
              void Function(LocalSearchResult) childMarkerSetter) {
            setMapMarkers = childMarkerSetter;
          }, 
          markerReset: (BuildContext context, void Function() childReset) {
            resetMarkers = childReset;
          },
        ),
      ),
    );
  }
}

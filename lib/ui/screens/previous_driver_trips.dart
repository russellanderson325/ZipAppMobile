import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/models/rides.dart';
import 'package:zipapp/constants/zip_colors.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  _DriverHistoryScreenState createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  late VoidCallback onBackPress;
  final UserService userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late List<dynamic> pastDrivesList;
  late List<dynamic> pastDriveIDs;
  late DocumentReference rideReference;
  late Ride driverRide;

  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  Future _retrievePastRideIDs() async {
    DocumentReference userRef =
        _firestore.collection('users').doc(userService.userID);
    pastDriveIDs = (await userRef.get()).get('pastDrives');
    if (kDebugMode) {
      print('past ride ids: $pastDriveIDs');
    }

    return pastDriveIDs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text(
            'Past Trips',
          ),
        ),
        body: FutureBuilder<void>(
            future: _retrievePastRideIDs(),
            builder: (context, index) {
              return ListView.builder(
                  itemCount: pastDriveIDs.length,
                  itemBuilder: (context, index) {
                    if (kDebugMode) {
                      print('id = ${pastDriveIDs[index]}');
                    }
                    return Container(
                      height: 50,
                      color: ZipColors.zipYellow,
                      child: Center(
                          child: Text('past drive: ${pastDriveIDs[index]}')),
                    );
                  });
            }));
  }
}

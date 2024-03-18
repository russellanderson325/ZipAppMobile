import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:zipapp/business/user.dart';

class PreviousTripsScreen extends StatefulWidget {
  const PreviousTripsScreen({super.key});

  @override
  _PreviousTripsScreenState createState() => _PreviousTripsScreenState();
}

class _PreviousTripsScreenState extends State<PreviousTripsScreen> {
  late VoidCallback onBackPress;
  final UserService userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late List<QueryDocumentSnapshot> pastRidesList;
  late List<dynamic> pastRideIDs;
  late DocumentReference rideReference;

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
    pastRideIDs = (await userRef.get()).get('pastRides');
    if (kDebugMode) {
      print('past ride ids: $pastRideIDs');
    }
    return pastRideIDs;
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
                  itemCount: pastRideIDs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 50,
                      color: Colors.yellow,
                      child: Center(
                          child: Text('past ride: ${pastRideIDs[index]}')),
                    );
                  });
            }));
  }
}

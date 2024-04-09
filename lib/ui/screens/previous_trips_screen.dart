import 'package:flutter/material.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/ride_activity_item.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/ui/screens/main_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zipapp/ui/screens/search_screen.dart';
import 'package:zipapp/ui/widgets/map.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_place_plus/google_place_plus.dart';
import 'package:zipapp/constants/keys.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/services/position_service.dart';



class PreviousTripsScreen extends StatefulWidget {
  final List<LatLng>? initialCoordinates; // Define initialCoordinates parameter
final MyMarkerSetter? markerBuilder;
  final MyMarkerReset? markerReset;
  final List<LatLng>? rideCoordinates;
  final Function(String)? onTripSelected;
  
  

  const PreviousTripsScreen({Key? key, 
  this.initialCoordinates,
   this.markerBuilder, 
   this.markerReset,  this.rideCoordinates, this.onTripSelected
   }) : super(key: key);


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
  late void Function(LocalSearchResult) setMapMarkers;
   bool navigateToMainScreenCalled = false; 
  

   
  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    pastRideIDs = []; // Initialize pastRideIDs with an empty list
    super.initState();
  }

  Future _retrievePastRideIDs() async {
    pastRideIDs = ['Tenderloin, San Fransisco, CA', 'Chinatown, San Fransisco, CA', 'ride3']; // Debug purposes

    //DocumentReference userRef = _firestore.collection('users').doc(userService.userID);
    if (kDebugMode) {
      print('past ride ids: $pastRideIDs');
    }
    return pastRideIDs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        title: const Text('Past Trips',
        style: ZipDesign.pageTitleText),
        scrolledUnderElevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'View previous trips here. Click on a ride to load up a previous trip route',
               textAlign: TextAlign.left,
              style: ZipDesign.sectionTitleText,
             
            ),
          ),
          Expanded(
  child: FutureBuilder<void>(
    future: _retrievePastRideIDs(),
    builder: (context, snapshot) {
      return ListView.separated(
        itemCount: pastRideIDs.length,
        separatorBuilder: (context, index) => Divider(), // Add divider here
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showConfirmationDialog(context, pastRideIDs[index]);
            },
            child: Container(
              height: 50,
              color: ZipColors.primaryBackground,
              child: Center(
                child: Text('past ride: ${pastRideIDs[index]}'),
              ),
            ),
          );
        },
      );
    },
  ),
),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String rideID) async {
  showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Load Previous Trip?'),
        content: Text('Do you want to load the previous trip: $rideID?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Close the dialog
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true); // Close the dialog
              List<LatLng> destCoordinates = await _getCoordinatesForRide(rideID);
              print(await _getCoordinatesForRide(rideID));
              
              _navigateToMainScreen(context, destCoordinates);
               navigateToMainScreenCalled = true;
            },
            child: Text('Yes'),
          ),
        ],
      );
    },
  );
}



  Future<List<LatLng>> _getCoordinatesForRide(String rideID) async {
    // Hardcoded coordinates for each ride
    if (rideID == 'Tenderloin, San Fransisco, CA') {
      return [
        LatLng( 37.7847,
 -122.4145)// Example coordinates for ride1 (San Francisco)
        // Additional coordinates for ride1 (Los Angeles)
      ];
    } else if (rideID == 'Chinatown, San Fransisco, CA') {
      return [
        LatLng(37.7946
, -122.4079) 
      ];
    } else if (rideID == 'ride3') {
      return [
        LatLng(51.5074, -0.1278), // Example coordinates for ride3 (London)
        LatLng(48.8566, 2.3522), // Additional coordinates for ride3 (Paris)
      ];
    } else {
      // Handle the case where the rideID doesn't match any predefined coordinates
      // You might want to throw an exception, log an error, or return a default value
      throw Exception("Coordinates not available for rideID: $rideID");
    }
  }

  void _navigateToMainScreen(BuildContext context, List<LatLng> destCoordinates) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Map(
        initialCoordinates: destCoordinates,
        markerBuilder: (context, methodFromChild) => pastRideIDs,
        markerReset:(context, methodFromChild) => pastRideIDs,
       
           onNavigateToMainScreenCalled: () {
          setState(() {
            navigateToMainScreenCalled = true;
          });
        },

        
      ),
    ),
  );
}  


}
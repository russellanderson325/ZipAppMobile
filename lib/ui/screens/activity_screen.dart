import 'package:flutter/material.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/ride_activity_item.dart';
import 'package:zipapp/ui/screens/previous_trips_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import the LatLng class
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
class ActivityScreen extends StatefulWidget {
   final List<LatLng>? initialCoordinates; // Define initialCoordinates parameter
final MyMarkerSetter? markerBuilder;
  final MyMarkerReset? markerReset;
  final List<LatLng>? rideCoordinates;
  
  const ActivityScreen({Key? key, 
  this.initialCoordinates,
   this.markerBuilder, 
   this.markerReset,  this.rideCoordinates, 
   }) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Ride> rides = [];
   bool navigateToMainScreenCalled = false; 

  @override
  void initState() {
    super.initState();
    _populateRideActivityData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        title: const Text(
          'Activity',
          style: ZipDesign.pageTitleText,
        ),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Past',
              textAlign: TextAlign.left,
              style: ZipDesign.sectionTitleText,
            ),
            rides.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: rides.length,
                      itemBuilder: (context, index) {
                        return RideActivityItem(
                          destination: rides[index].destination,
                          dateTime: rides[index].dateTime,
                          price: rides[index].price,
                        );
                      },
                    ),
                  )
                : const SizedBox(),
            SizedBox(height: 16), // Add some spacing below the list
            ElevatedButton(
              onPressed: () {
                // Navigate to PreviousTripsScreen when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviousTripsScreen(
                      onTripSelected: (destination) {
                        _navigateToMainScreen(context, destination);
                      },
                    ),
                  ),
                );
              },
              child: Text('View Previous Trips'),
            ),
          ],
        ),
      ),
    );
  }

  void _populateRideActivityData() async {
    List<Ride> tempRides = [];
    // Fetch coordinates dynamically for each ride
    try {
      for (String rideID in ['Tenderloin, San Fransisco, CA', 'Chinatown, San Fransisco, CA', 'ride3']) {
        List<LatLng> coordinates = await _getCoordinatesForRide(rideID);
        tempRides.add(Ride(
          destination: rideID,
          dateTime: DateTime(2024, 10, 12, 14, 30),
          price: 12.23,
          coordinates: coordinates,
        ));
      }
      setState(() {
        rides = tempRides;
      });
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }
void _navigateToMainScreen(BuildContext context, String destination) async {
  // Fetch coordinates for the destination
  List<LatLng> destCoordinates = await _getCoordinatesForRide(destination);
  // Navigate to the Map screen with the destination coordinates
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Map(
        initialCoordinates: destCoordinates,
        markerBuilder: (context, methodFromChild) => rides,
        markerReset: (context, methodFromChild) => rides,
        onNavigateToMainScreenCalled: () {
          setState(() {
            navigateToMainScreenCalled = true;
          });
        },
      ),
    ),
  );
}

  Future<List<LatLng>> _getCoordinatesForRide(String rideID) async {
    // Use the same logic as in PreviousTripsScreen to fetch coordinates for rides
    // Hardcoded coordinates for each ride
    if (rideID == 'Tenderloin, San Fransisco, CA') {
      return [LatLng(37.7847, -122.4145)];
    } else if (rideID == 'Chinatown, San Fransisco, CA') {
      return [LatLng(37.7946, -122.4079)];
    } else if (rideID == 'ride3') {
      return [LatLng(51.5074, -0.1278), LatLng(48.8566, 2.3522)];
    } else {
      throw Exception("Coordinates not available for rideID: $rideID");
    }
  }

  void _showPreviousTrip(String destination) {
    // Show the selected trip
    print('Selected Trip: $destination');
    // You can navigate to another screen or perform any action here
  }
}

class Ride {
  final String destination;
  final DateTime dateTime;
  final double price;
  final List<LatLng> coordinates; // Add coordinates field

  Ride({
    required this.destination,
    required this.dateTime,
    required this.price,
    required this.coordinates,
  });
}

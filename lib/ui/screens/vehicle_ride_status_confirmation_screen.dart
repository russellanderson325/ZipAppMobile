import "dart:async";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:lucide_icons/lucide_icons.dart";
import "package:zipapp/business/ride.dart";
import "package:zipapp/business/user.dart";
import "package:zipapp/constants/zip_colors.dart";
import "package:zipapp/business/ride.dart";
import "package:zipapp/constants/zip_design.dart";
import "package:zipapp/models/rides.dart";
import "package:zipapp/services/payment.dart";
import "package:zipapp/ui/widgets/message_overlay.dart";

class VehicleRideStatusConfirmationScreen extends StatefulWidget {
  final RideService ride;
  final Function resetMap;
  const VehicleRideStatusConfirmationScreen({
    Key? key,
    required this.ride,
    required this.resetMap,
  }) : super(key: key);

  @override
  State<VehicleRideStatusConfirmationScreen> createState() => VehicleRideStatusConfirmationScreenState(); // Modify this line
}

class VehicleRideStatusConfirmationScreenState extends State<VehicleRideStatusConfirmationScreen> {
  VehicleRideStatusConfirmationScreenState();
  String rideId = "";
  String statusMessage = "";
  String rideStatus = "";
  int incrementKey = 0;
  RideService? ride;
  UserService userService = UserService();
  bool _isMounted = false;
  String status = "";
  StreamSubscription<Ride>? _rideSubscription; // Declare this in your state class


  @override
  void initState() {
    super.initState();
    _isMounted = true;
    statusMessage = "";
    ride = widget.ride;
    print("Ride ID: ${ride!.rideID}");
    _rideSubscription = ride?.getRideStream().listen((ride) {
      statusUpdate(ride.status);
    });
  }

  @override
  void dispose() {
    _rideSubscription?.cancel(); // Cancel the subscription
    if (!userService.isRiding()) {
      ride?.cancelRide();
    }
    _isMounted = false;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Information"),
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: ListView(
          children: <Widget>[
            Center(
              child: Text(statusMessage),
            ),
            const SizedBox(height: 250),
            TextButton.icon(
              onPressed: () {
                ride?.cancelRide();
              },
              icon: const Icon(LucideIcons.trash),
              style: ZipDesign.redButtonStyle,
              label: const Text('Cancel Ride')
            ),
            const SizedBox(height: 5),
            const Center(
              child: Text(
              "If the ride is cancelled, no charge will be made",
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
            )
            ),

          ],
        ),
      )
    );
  }

  /*
   * Update the status of the ride
   * @param status The status of the ride
   * @return void
   */
  void statusUpdate(String status) {
    if (status == this.status) return;
    print("statusUpdate: $status");
    this.status = status;
    if (_isMounted) {
      setState(() {
        rideStatus = status;
        incrementKey++;
        switch (status) {
          case "INITIALIZING":
            print("Searching");
            statusMessage = "Searching for a driver...";
            break;
          case "WAITING":
            print("Waiting");
            statusMessage = "Waiting for driver to accept...";
            break;
          case "IN_PROGRESS":
            print("In Progress");
            statusMessage = "Driver connected and en route..."; 
            print("Starting in progress ride with ID: ${ride!.rideID}");
            userService.startRide(ride!.rideID);
            break;
          case "ENDED":
            print("Ended");
            statusMessage = "Ride has ended, thank you for riding with us. Your payment has been processed.";
            userService.endRide();
            Future.microtask(() => widget.resetMap());
            break;
          case "CANCELED":
            print("Canceled");
            statusMessage = "Ride has been canceled. No charge has been made.";
            userService.endRide();
            Future.microtask(() => widget.resetMap());
            Navigator.pop(context);
            break;
        }
      });
    }
  }
  

  /*
   * Show the VehicleRequestAwaitingConfirmationScreenState as a bottom sheet
   * @param context The context
   * @return void
   */
  static void showVehicleRequestAwaitingConfirmationScreen(
      BuildContext context,
      RideService ride,
      Function resetMap,
    ) {
    print("Showing VehicleRequestAwaitingConfirmationScreenState with ride ID: ${ride.rideID}");
    // Show the bottom sheet
    showModalBottomSheet(
      clipBehavior: Clip.hardEdge,
      barrierColor: const Color.fromARGB(60, 0, 0, 0),
      context: context,
      isScrollControlled: true,
      // isDismissible: false,
      // enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        // side: BorderSide(color: ZipColors.boxBorder, width: 1.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: VehicleRideStatusConfirmationScreen(ride: ride, resetMap: resetMap),
        );
      },
    );
  }
}
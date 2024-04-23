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
  State<VehicleRideStatusConfirmationScreen> createState() => VehicleRideStatusConfirmationScreenState();
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
  StreamSubscription<Ride>? _rideSubscription;


  @override
  void initState() {
    super.initState();
    _isMounted = true;
    statusMessage = "";
    ride = widget.ride;

    _rideSubscription = ride?.getRideStream().listen((ride) {
      statusUpdate(ride.status);
    });
  }

  @override
  void dispose() {
    _rideSubscription?.cancel();
    if (!userService.isRiding()) {
      Future.microtask(() => widget.resetMap());
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
            const SizedBox(height: 260),
            TextButton.icon(
              onPressed: () {
                if (status != "CANCELED" && status != "ENDED") {
                  ride?.cancelRide();
                } else {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(LucideIcons.trash),
              style: ZipDesign.redButtonStyle,
              label: Text((status != "CANCELED" && status != "ENDED") ? 'Cancel Ride' : 'Close')
            ),
            const SizedBox(height: 5),
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
    this.status = status;
    if (_isMounted) {
      setState(() {
        rideStatus = status;
        incrementKey++;
        switch (status) {
          case "INITIALIZING":
            statusMessage = "Searching for a driver...";
            break;
          case "WAITING":
            statusMessage = "Waiting for driver to accept...";
            break;
          case "IN_PROGRESS":
            statusMessage = "Driver connected and en route..."; 
            userService.startRide(ride!.rideID);
            break;
          case "ENDED":
            statusMessage = "Ride has ended, thank you for riding with us. Your payment has been processed.";
            userService.endRide();
            Future.microtask(() => widget.resetMap());
            break;
          case "CANCELED":
            statusMessage = "Ride canceled. No charge has been made.";
            userService.endRide();
            Future.microtask(() => widget.resetMap());
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
    // Show the bottom sheet
    showModalBottomSheet(
      clipBehavior: Clip.hardEdge,
      barrierColor: const Color.fromARGB(0, 0, 0, 0),
      context: context,
      isScrollControlled: true,
      // isDismissible: false,
      // enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        side: BorderSide(color: ZipColors.boxBorder, width: 1.0),
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
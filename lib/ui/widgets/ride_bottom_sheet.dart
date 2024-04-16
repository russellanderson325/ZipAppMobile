import 'package:flutter/material.dart';
import 'package:zipapp/models/rides.dart';
import 'package:zipapp/business/drivers.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/business/ride.dart';

class RideDetails extends StatelessWidget {
  final bool driver;
  final Ride ride;
  final DriverService driverService = DriverService();
  final UserService userService = UserService();
  final RideService rideService = RideService();
  final double screenHeight, screenWidth;

  RideDetails({
    super.key,
    required this.driver,
    required this.ride,
    required this.screenHeight,
    required this.screenWidth,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CircleAvatar(
                      radius: 50,
                      child: Image.asset(
                          'assets/profile_default.png') //driver ? Image.network(ride.driverPictureURL) : Image.network(ride.userPictureURL),
                      ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  driver ? Text(ride.userName) : Text(ride.driverName),
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FloatingActionButton.extended(
                      backgroundColor: Colors.red,
                      onPressed: () {
                        _cancelRide();
                      },
                      label: const Text('Cancel'),
                      icon: const Icon(Icons.cancel),
                    )
                  ])
            ],
          ),
        ],
      ),
    );
  }

  void _cancelRide() {
    rideService.cancelRide();
  }
}

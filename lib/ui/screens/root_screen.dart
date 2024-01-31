import 'package:flutter/material.dart';
import 'package:zipapp/business/drivers.dart';
import 'package:zipapp/business/location.dart';
// import 'package:zipapp/business/ride.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/ui/screens/welcome_screen.dart';
import 'package:zipapp/ui/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _RootScreenState();
}

enum LoadingState {
  none,
  loading,
  done,
}

/// This class sets up all of the services that
/// the app will use while running.
class _RootScreenState extends State<RootScreen> {
  LoadingState loading = LoadingState.none;

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            // TODO: create a splashscreen / loading screen
            color: Colors.white,
          );
        } else {
          if (snapshot.hasData) {
            switch (loading) {
              case LoadingState.none:
                _initializeServices(snapshot.data!.uid).whenComplete(() {
                  setState(() {
                    loading = LoadingState.done;
                  });
                });
                loading = LoadingState.loading;
                return _buildWaitingScreen();
              case LoadingState.loading:
                return _buildWaitingScreen();
              case LoadingState.done:
                return const MainScreen();
              default:
                return const WelcomeScreen();
            }
          } else {
            return const WelcomeScreen();
          }
        }
      },
    );
    //return const WelcomeScreen();
  }

  Future<bool> _initializeServices(String uid) async {
    UserService userService = UserService();
    userService.setupService(uid);
    LocationService locationService = LocationService();
    await locationService.setupService();
    DriverService driverService = DriverService();
    await driverService.setupService();
    // RideService rideService = RideService();
    return true;
  }
}

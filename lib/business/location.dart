import 'dart:async';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  // final Geolocator geolocator = Geolocator();
  GeoFlutterFire geo = GeoFlutterFire();
  // late GeoLocationStatus geolocationStatus;
  Position position = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0);
  bool initizalized = false;
  LocationSettings locationOptions = const LocationSettings(
      accuracy: LocationAccuracy.high, distanceFilter: 25, timeLimit: Duration(seconds: 10));
  Stream<Position> positionStream = const Stream.empty();
  late StreamSubscription<Position> positionSub;
  bool isPositionSubInitialized = false;

  factory LocationService() {
    return _instance;
  }

  LocationService._internal() {
    if (kDebugMode) {
      print("LocationService created");
    }
  }

  Future<bool> setupService({bool reinit = false}) async {
    try {
      if (isPositionSubInitialized) {
        await positionSub.cancel();
        isPositionSubInitialized = false; // Reset the flag
      }
      PermissionStatus status =
          await LocationPermissions().checkPermissionStatus();
      // Get permission from user
      if (kDebugMode) {
        print("location permissions status checked");
      }
      while (status != PermissionStatus.granted) {
        status = await LocationPermissions().requestPermissions();
      }
      if (kDebugMode) {
        print("location permissions have been granted by user");
      }
      // Ensure position is not null after setup
      print("Latitude4: ${position.latitude}");
      print("Longitiude4: ${position.longitude}");
      if (kDebugMode) {
        print("position: $position");
      }
      position = await Geolocator.getCurrentPosition();
      if (kDebugMode) {
        print("position2: $position");
      }
      print("Latitude3: ${position.latitude}");
      print("Longitiude3: ${position.longitude}");
      // while (position == null) {
      //   print(
      //       "current position is null - using geolocator to get current position now.");
      //   position = await Geolocator.getCurrentPosition();
      // }
      // if (kDebugMode) {
      //   print("Latitude: ${position.latitude}");
      //   print("Longitiude: ${position.longitude}");
      // }
      // Creating the position stream with location options and debouncing (to avoid spamming the database with updates)
      positionStream = Geolocator.getPositionStream(locationSettings: locationOptions)
          .transform(debouncePositionStream(const Duration(seconds: 10)))
          .asBroadcastStream();
      positionSub = positionStream.listen((Position position) {
        this.position = position;
        // if (kDebugMode) {
        //   print("Latitude2: ${position.latitude}");
        //   print("Longitiude2: ${position.longitude}");
        // }
      });
      if (kDebugMode) {
        print("LocationService initialized");
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing LocationService $e");
      }
      return false;
    }
  }

  GeoFirePoint getCurrentGeoFirePoint() {
    return geo.point(
        latitude: position.latitude, longitude: position.longitude);
  }
}

// Debounce the position stream to avoid spamming the database with updates
// Basically just projecting the position stream to a new stream that only emits a 
// new position if the last position was emitted more than the interval ago
StreamTransformer<Position, Position> debouncePositionStream(Duration interval) {
  DateTime? lastTime;

  return StreamTransformer.fromHandlers(
    handleData: (Position data, EventSink<Position> sink) {
      final now = DateTime.now();
      if (lastTime == null || now.difference(lastTime!) > interval) {
        lastTime = now;
        sink.add(data);
      }
    },
  );
}

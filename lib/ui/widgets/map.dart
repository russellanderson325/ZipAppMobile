import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => MapSampleState();
}

class MapSampleState extends State<Map> {
  String mapTheme = '';
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Position? userPosition;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context)
        .loadString('assets/mapthemes/uber_theme.json')
        .then((value) {
      mapTheme = value;
    });
    _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userPosition == null
      ? const Center(child: CircularProgressIndicator())
      : GoogleMap(
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle(mapTheme);
          _controller.complete(controller);
        },
      ),
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              FloatingActionButton.extended(
                onPressed: _goToTheLake,
                label: const Text('To the lake!'),
                icon: const Icon(Icons.directions_boat),
              ),
              FloatingActionButton(
                onPressed: _goToMe,
                child: const Icon(Icons.my_location),
              )
            ],
          )),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<void> _goToMe() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(userPosition!.latitude, userPosition!.longitude), zoom: 14.4746)
    ));
  }

  void _getCurrentPosition() async {
    Position position = await _determinePosition();
    setState(() {
      userPosition = position;
    });
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    
    bool serviceEnabled;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}

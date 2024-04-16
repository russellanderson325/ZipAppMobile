import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place_plus/google_place_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/business/drivers.dart';

import 'package:zipapp/constants/keys.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/services/position_service.dart';
import 'package:zipapp/ui/screens/search_screen.dart';
import 'package:zipapp/ui/screens/vehicles_screen.dart';
import 'package:zipapp/ui/widgets/message_overlay.dart';

class MapWidget extends StatefulWidget {
  final bool driver;
  const MapWidget({super.key, required this.driver});

  @override
  State<MapWidget> createState() => MapWidgetSampleState();
}

class MapWidgetSampleState extends State<MapWidget> {
  //general map code
  String mapTheme = '';
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  PositionService positionService = PositionService();
  LatLng? userLatLng, searchLatLng;
  final markers = <Marker>[];
  final polylines = <Polyline>[];
  PolylinePoints polylinePoints = PolylinePoints();
  DriverService driverService = DriverService();
  Map<String, bool> driverStates = {
    'isWorking': false,
    'onBreak': false,
  };
  DateTime lastClockInButtonPress = DateTime(0);
  DateTime lastClockOutButtonPress = DateTime(0);
  DateTime lastStartBreakButtonPress = DateTime(0);
  DateTime lastEndBreakButtonPress = DateTime(0);

  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context)
        .loadString('assets/mapthemes/uber_theme.json')
        .then((value) {
      mapTheme = value;
    });

    if (mounted) {
      positionService.getPosition().then((value) {
        setState(() {
          userLatLng = LatLng(value.latitude, value.longitude);
          markers.add(Marker(
            markerId: const MarkerId("userPosition"),
            position: userLatLng!,
            infoWindow: const InfoWindow(title: "You are here"),
          ));
        });
      });
      updateDriverStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        widget.driver ? driverBox(width, height) : searchBox(width, height),
        Expanded(
          child: userLatLng == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  myLocationEnabled: true,
                  compassEnabled: true,
                  initialCameraPosition:
                      CameraPosition(target: userLatLng!, zoom: 17.5),
                  mapToolbarEnabled: false,
                  markers: markers.toSet(),
                  myLocationButtonEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    controller.setMapStyle(mapTheme);
                    _controller.complete(controller);
                  },
                  polylines: polylines.toSet(),
                  zoomControlsEnabled: false,
                ),
        ),
      ],
    );
  }

  void angryMessage(message) {
    if (mounted) {
      MessageOverlay(
        message: message,
        duration: const Duration(seconds: 2),
        color: "#F54747",
        textColor: "#FFFFFF",
        background: true,
        opacity: 1,
      ).show(context);
    }
  }

  //driver code
  void clockIn() async {
    // Prevent the user from spamming the clock in button
    if (DateTime.now().difference(lastClockInButtonPress).inSeconds < 5) {
      angryMessage("Please wait a few seconds before trying again.");
      return;
    }
    lastClockInButtonPress = DateTime.now();

    // Clock in the driver
    Map<String, dynamic> response = await driverService.clockIn();

    // If the response is not successful, show an error message and return
    if (!response['success']) {
      angryMessage(response['response']);
      return;
    }

    // Start driving
    driverService.startDriving();

    // Update the UI
    setState(() {
      driverStates['isOnBreak'] = false;
      driverStates['isWorking'] = true;
    });
  }

  void clockOut() async {
    if (DateTime.now().difference(lastClockOutButtonPress).inSeconds < 5) {
      angryMessage("Please wait a few seconds before trying again.");
      return;
    }
    lastClockOutButtonPress = DateTime.now();

    var response = await driverService.clockOut();
    if (!response['success']) {
      angryMessage(response['response']);
      return;
    }

    driverService.stopDriving();

    setState(() {
      driverStates['isOnBreak'] = false;
      driverStates['isWorking'] = false;
    });
  }

  void startBreak() async {
    if (DateTime.now().difference(lastStartBreakButtonPress).inSeconds < 5) {
      angryMessage("Please wait a few seconds before trying again.");
      return;
    }
    lastStartBreakButtonPress = DateTime.now();

    var response = await driverService.startBreak();
    if (!response['success']) {
      angryMessage(response['response']);
      return;
    }

    driverService.stopDriving();

    setState(() {
      driverStates['isOnBreak'] = true;
      driverStates['isWorking'] = true;
    });
  }

  void endBreak() async {
    if (DateTime.now().difference(lastEndBreakButtonPress).inSeconds < 5) {
      angryMessage("Please wait a few seconds before trying again.");
      return;
    }
    lastEndBreakButtonPress = DateTime.now();

    var response = await driverService.endBreak();
    if (!response['success']) {
      angryMessage(response['response']);
      return;
    }

    driverService.startDriving();

    setState(() {
      driverStates['isOnBreak'] = false;
      driverStates['isWorking'] = true;
    });
  }

  Future<void> updateDriverStatus() async {
    // Fetch the driver states asynchronously.
    Map<String, bool> states = await driverService.getDriverStates();
    // Once the data is available, then update the state synchronously.
    setState(() {
      driverStates = states;
    });
  }

  SizedBox driverBox(double screenWidth, double screenHeight) {
    return SizedBox(
      width: screenWidth,
      height: 68,
      child: Container(
        decoration: const BoxDecoration(
          color: ZipColors.primaryBackground,
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: driverStates['isWorking']!
            ? Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed:
                          driverStates['isOnBreak']! ? endBreak : startBreak,
                      icon: driverStates['isOnBreak']!
                          ? const Icon(LucideIcons.play)
                          : const Icon(LucideIcons.pause),
                      label: driverStates['isOnBreak']!
                          ? const Text('Resume driving')
                          : const Text('Start break'),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(0)),
                        iconColor: MaterialStateProperty.all(Colors.black),
                        iconSize: MaterialStateProperty.all(16),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black),
                        backgroundColor:
                            MaterialStateProperty.all(ZipColors.zipYellow),
                        textStyle:
                            MaterialStateProperty.all(ZipDesign.labelText),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: clockOut,
                      icon: const Icon(LucideIcons.logOut),
                      label: const Text('Clock out'),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(0)),
                        iconColor: MaterialStateProperty.all(Colors.black),
                        iconSize: MaterialStateProperty.all(16),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black),
                        backgroundColor:
                            MaterialStateProperty.all(ZipColors.zipYellow),
                        textStyle:
                            MaterialStateProperty.all(ZipDesign.labelText),
                      ),
                    ),
                  ),
                ],
              )
            : TextButton.icon(
                onPressed: clockIn,
                icon: const Icon(LucideIcons.logIn),
                label: const Text('Clock in as a driver'),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                  iconColor: MaterialStateProperty.all(Colors.black),
                  iconSize: MaterialStateProperty.all(16),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  backgroundColor:
                      MaterialStateProperty.all(ZipColors.zipYellow),
                  textStyle: MaterialStateProperty.all(ZipDesign.labelText),
                ),
              ),
      ),
    );
  }

  //rider code

  SizedBox searchBox(double screenWidth, double screenHeight) {
    return SizedBox(
      width: screenWidth,
      height: 68,
      child: Container(
        decoration: const BoxDecoration(
          color: ZipColors.primaryBackground,
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: GestureDetector(
          onTap: () => openSearchScreen(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: ZipColors.boxBorder, width: 1.0),
              color: Colors.white,
            ),
            child: const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Icon(Icons.search, color: Colors.black, size: 30.0),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    'Where would you like to go?',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontSize: 16.0,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openSearchScreen() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SearchScreen()));
    if (result != null) {
      addSearchedMarker(result);
    } else {
      print('result is null');
    }
  }

  void addSearchedMarker(LocalSearchResult searchResult) async {
    GooglePlace googlePlace = GooglePlace(Keys.map);
    await googlePlace.details.get(searchResult.placeId).then(
      (value) async {
        setState(() {
          searchLatLng = LatLng(value!.result!.geometry!.location!.lat!,
              value.result!.geometry!.location!.lng!);
        });
        PolylineResult? result = await _addSearchResult(searchResult);
        _moveCamera(
            latlng: LatLng(value!.result!.geometry!.location!.lat! - 0.0015,
                value.result!.geometry!.location!.lng!));

        // Show the vehicle request screen
        VehiclesScreenState.showVehiclesScreen(
          context,
          (result!.distanceValue)!.toDouble(),
          value.result!.geometry!.location!.lat!,
          value.result!.geometry!.location!.lng!,
          _resetMarkers,
        );
      },
    );
  }

  Future<PolylineResult?> _addSearchResult(
      LocalSearchResult searchResult) async {
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(24, 24)),
      'assets/destination_map_marker.png',
    );

    _resetMarkers();
    setState(() {
      markers.add(Marker(
        markerId: MarkerId(searchResult.placeId),
        position: searchLatLng!,
        infoWindow: InfoWindow(title: searchResult.name),
        icon: customIcon,
      ));
    });
    return await _updatePolylines();
  }

  void _moveCamera({latlng, zoom = 17}) async {
    latlng ??= userLatLng!;
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latlng, zoom: zoom.toDouble())));
  }

  void _resetMarkers() {
    if (mounted) {
      setState(() {
        markers
            .removeWhere((element) => element.markerId.value != "userPosition");
      });
    }
    _updatePolylines();
  }

  Future<PolylineResult> _updatePolylines() async {
    if (markers.length > 1) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Keys.map,
        PointLatLng(
            markers.first.position.latitude, markers.first.position.longitude),
        PointLatLng(
            markers.last.position.latitude, markers.last.position.longitude),
      );
      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = [];
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
        Polyline polyline = Polyline(
          polylineId: const PolylineId("userRoute"),
          color: const Color.fromARGB(255, 255, 193, 21),
          points: polylineCoordinates,
          width: 5,
          visible: true,
        );
        if (mounted) {
          setState(() {
            polylines.add(polyline);
          });
        }
      }
      return result;
    } else {
      if (mounted) {
        setState(
          () {
            polylines.clear();
          },
        );
      }
      return PolylineResult();
    }
  }
}

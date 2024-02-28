import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place_plus/google_place_plus.dart';

import 'package:zipapp/constants/keys.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/services/position_service.dart';
import 'package:zipapp/ui/screens/main_screen.dart';
import 'package:zipapp/ui/screens/search_screen.dart';

class Map extends StatefulWidget {
  final MyMarkerSetter markerBuilder;
  final MyMarkerReset markerReset;

  const Map({Key? key, required this.markerBuilder, required this.markerReset})
      : super(key: key);

  @override
  State<Map> createState() => MapSampleState();
}

class MapSampleState extends State<Map> {
  String mapTheme = '';
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  PositionService positionService = PositionService();
  LatLng? userLatLng, searchLatLng;

  final markers = <Marker>[];
  final polylines = <Polyline>[];

  PolylinePoints polylinePoints = PolylinePoints();

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
              infoWindow: const InfoWindow(title: "You are here")));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.markerBuilder.call(context, addSearchedMarker);
    widget.markerReset.call(context, _resetMarkers);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        searchBox(width, height),
        SizedBox(
          width: width,
          height: height * 0.74,
          child: userLatLng == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  myLocationEnabled: true,
                  compassEnabled: true,
                  initialCameraPosition:
                      CameraPosition(target: userLatLng!, zoom: 14.4746),
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
                  child: const Row(children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child:
                          Icon(Icons.search, color: Colors.black, size: 30.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text('Where would you like to go?',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.none,
                            fontSize: 16.0,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w500,
                          )),
                    )
                  ]))),
        ));
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
      (value) {
        setState(() {
          searchLatLng = LatLng(value!.result!.geometry!.location!.lat!,
              value.result!.geometry!.location!.lng!);
        });
        _addSearchResult(searchResult);
        _moveCamera(latlng: searchLatLng);
      },
    );
  }

  void _addSearchResult(LocalSearchResult searchResult) {
    if (mounted) {
      _resetMarkers();
      setState(() {
        markers.add(Marker(
            markerId: MarkerId(searchResult.placeId),
            position: searchLatLng!,
            infoWindow: InfoWindow(title: searchResult.name)));
      });
      _updatePolylines();
    }
  }

  void _moveCamera({latlng, zoom = 14.4746}) async {
    latlng ??= userLatLng!;
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latlng, zoom: zoom)));
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

  void _updatePolylines() async {
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
          color: Colors.blue,
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
    } else {
      if (mounted) {
        setState(() {
          polylines.clear();
        });
      }
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place_plus/google_place_plus.dart';
import 'package:zipapp/constants/keys.dart';
import 'package:zipapp/services/position_service.dart';
import 'package:zipapp/ui/screens/main_screen.dart';
import 'package:zipapp/ui/screens/search.dart';

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

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final markers = <Marker>[];
  final polylines = <Polyline>[];

  PolylinePoints polylinePoints = PolylinePoints();

  late bool tapMode;

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
    tapMode = false;
  }

  @override
  Widget build(BuildContext context) {
    widget.markerBuilder.call(context, addSearchedMarker);
    widget.markerReset.call(context, _resetMarkers);
    return Scaffold(
      body: Column(
        children: [
          Search(),
          Expanded(
            child: userLatLng == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: userLatLng!, zoom: 14.4746),
                    mapToolbarEnabled: false,
                    markers: markers.toSet(),
                    onMapCreated: (GoogleMapController controller) {
                      controller.setMapStyle(mapTheme);
                      _controller.complete(controller);
                    },
                    onTap: (latlng) => _maybeAddMarker(latlng),
                    polylines: polylines.toSet(),
                    zoomControlsEnabled: false,
                  ),
          ),
        ],
      ),
      // floatingActionButton: Padding(
      //     padding: const EdgeInsets.only(top: 12.0),
      //     child: FloatingActionButton(
      //       onPressed: () => _moveCamera(zoom: 14.4746),
      //       child: const Icon(Icons.my_location),
      //     )),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
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
    // zoom ??= await controller.getZoomLevel();
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latlng, zoom: zoom)));
  }

  void _maybeAddMarker(LatLng latlng) {
    _resetMarkers();
    if (tapMode && mounted) {
      setState(() {
        markers.add(Marker(
            markerId: MarkerId(DateTime.now().toString()), position: latlng));
      });
      _updatePolylines();
    }
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
      // with polylinepoints
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
      ////

      // without polylinepoints
      // print("updating polylines");
      // Polyline polyline = Polyline(
      //   polylineId: const PolylineId("userRoute"),
      //   color: Colors.blue,
      //   points: [userLatLng!, markers.last.position],
      //   width: 5,
      //   visible: true,
      // );
      // if (mounted) {
      //   print('adding polyline');
      //   setState(() {
      //     polylines.add(polyline);
      //   });
      // }
    } else {
      if (mounted) {
        setState(() {
          polylines.clear();
        });
      }
    }
  }
}

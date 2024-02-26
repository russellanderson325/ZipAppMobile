import 'package:flutter/material.dart';
import 'package:google_place_plus/google_place_plus.dart';

import 'package:zipapp/constants/keys.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/services/position_service.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => SearchState();
}

class SearchState extends State<Search> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final String mapAPIKey = Keys.map;

  final TextEditingController searchController = TextEditingController();
  final int radius = 120;

  final PositionService positionService = PositionService();

  final GooglePlace _googlePlace = GooglePlace(Keys.map);

  late FocusNode _focusNode;

  LatLon? userLatLon;

  List<LocalSearchResult> places = [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    positionService.getPosition().then((value) {
      userLatLon = LatLon(value.latitude, value.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: ZipColors.primaryBackground,
        ),
        child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
              top: 6,
            ),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.black),
                contentPadding: EdgeInsets.all(0),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                fillColor: Colors.white,
                hintText: "Where would you like to go?",
                hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w500),
                filled: true,
                // suffixIcon: IconButton(
                //     onPressed: () => {
                //           searchController.clear(),
                //         },
                //     icon: const Icon(Icons.highlight_off))
              ),
              focusNode: _focusNode,
              onChanged: (value) => value != "" ? _getPlaces(value) : {},
            )));
  }

  void _getPlaces(String value) async {
    var result = await _googlePlace.autocomplete
        .get(value, radius: radius, language: 'en', location: userLatLon!);
    if (result != null && result.predictions != null && mounted) {
      Iterable<LocalSearchResult> resultsList = result.predictions!.map((p) {
        return LocalSearchResult(name: p.description!, placeId: p.placeId!);
      });
      setState(() => places = resultsList.toList());
    }
  }
}

class LocalSearchResult {
  final String name;
  final String placeId;

  LocalSearchResult({required this.name, required this.placeId});
}

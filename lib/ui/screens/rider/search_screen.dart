import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_place_plus/google_place_plus.dart';

import 'package:zipapp/constants/keys.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/services/position_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
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
    _focusNode.requestFocus();
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        automaticallyImplyLeading: false,
        toolbarHeight: 10.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: ZipColors.boxBorder),
                ),
                child: TextField(
                  focusNode: _focusNode,
                  controller: searchController,
                  onChanged: (value) => _getPlaces(value),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search Here",
                    prefixIcon: IconButton(
                      onPressed: () => {
                        _focusNode.unfocus(),
                        SystemChannels.textInput.invokeMethod('TextInput.hide'),
                        Navigator.pop(context)
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => searchController.clear(),
                      icon: const Icon(Icons.highlight_off),
                    ),
                  ),
                ),
              ),
            ),
            places.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.fromLTRB(16.0, 0.0, 6.0, 0.0),
                            title: Text(places[index].name),
                            trailing: IconButton(
                              icon: const Icon(Icons.north_west),
                              onPressed: () {
                                searchController.text = places[index].name;
                              },
                            ),
                            onTap: () => Navigator.pop(context, places[index]),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
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

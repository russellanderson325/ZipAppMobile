import 'package:flutter/material.dart';
import 'package:google_place_plus/google_place_plus.dart';

import 'package:zipapp/constants/keys.dart';
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
    _focusNode.requestFocus();
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 10.0,
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(children: <Widget>[
              // SearchBar(
              //   padding: MaterialStateProperty.all<EdgeInsets>(
              //       const EdgeInsets.symmetric(horizontal: 2)),
              //   leading: IconButton(
              //       onPressed: () => Navigator.pop(context),
              //       icon: const Icon(Icons.arrow_back, color: Colors.black)),
              //   controller: searchController,
              //   hintText: "Search Here",
              //   trailing: <Widget>[
              //     IconButton(
              //         onPressed: () => searchController.clear(),
              //         icon:
              //             const Icon(Icons.highlight_off, color: Colors.black)),
              //   ],
              //   onChanged: (value) => _getPlaces(value),
              //   onSubmitted: (text) => {
              //     if (places.isNotEmpty &&
              //         places
              //             .where((element) =>
              //                 element.name.toLowerCase() == text.toLowerCase())
              //             .isNotEmpty)
              //       {
              //         Navigator.pop(
              //             context,
              //             places
              //                 .where((element) =>
              //                     element.name.toLowerCase() ==
              //                     text.toLowerCase())
              //                 .first)
              //       }
              //     else
              //       {_focusNode.requestFocus()}
              //   },
              //   focusNode: _focusNode,
              // ),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(50.0),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 2.0,
                              spreadRadius: 1)
                        ]),
                    child: TextField(
                      focusNode: _focusNode,
                      controller: searchController,
                      onChanged: (value) => _getPlaces(value),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search Here",
                          prefixIcon: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.black),
                          ),
                          suffixIcon: IconButton(
                              onPressed: () => searchController.clear(),
                              icon: const Icon(Icons.highlight_off))),
                    ),
                  )),
              places.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(
                                    16.0, 0.0, 6.0, 0.0),
                                title: Text(places[index].name),
                                trailing: IconButton(
                                  icon: const Icon(Icons.north_west),
                                  onPressed: () {
                                    searchController.text = places[index].name;
                                  },
                                ),
                                onTap: () =>
                                    Navigator.pop(context, places[index])));
                        // return ListTile(
                        //     title: Text(places[index].name),
                        //     trailing: IconButton(
                        //       icon: const Icon(Icons.north_west),
                        //       onPressed: () {
                        //         _focusNode.unfocus();
                        //         searchController.text = places[index].name;
                        //       },
                        //     ),
                        //     onTap: () => Navigator.pop(context, places[index]));
                      },
                    ))
                  : const SizedBox()
            ])));
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
  // final GooglePlace _googlePlace = GooglePlace(Keys.map);
  final String name;
  final String placeId;
  // late LatLng latlng;

  LocalSearchResult({required this.name, required this.placeId}) {
    // bool? set;
    // _setLatLng(placeId).then((value) => set = value);
    // print(set);
  }

  // Future<bool> _setLatLng(String placeId) async {
  //   await _googlePlace.details.get(placeId).then((value) {
  //     if (value != null && value.result != null) {
  //       latlng = LatLng(value.result!.geometry!.location!.lat!,
  //           value.result!.geometry!.location!.lng!);
  //       return true;
  //     }
  //   });
  //   return false;
  // }
}

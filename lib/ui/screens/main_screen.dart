import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:zipapp/business/auth.dart';
import 'package:zipapp/business/drivers.dart';
import 'package:zipapp/business/location.dart';
import 'package:zipapp/business/notifications.dart';
import 'package:zipapp/business/payment.dart' as payment_details;
import 'package:zipapp/business/ride.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/keys.dart';
import 'package:zipapp/constants/privacy_policies.dart';
import 'package:zipapp/CustomIcons/my_flutter_app_icons.dart';
import 'package:zipapp/models/user.dart';
import 'package:zipapp/models/driver.dart';
import 'package:zipapp/services/payment.dart';
import 'package:zipapp/ui/screens/search_screen.dart';
import 'package:zipapp/ui/screens/settings_screen.dart';
import 'package:zipapp/ui/screens/previous_trips_screen.dart';
import 'package:zipapp/ui/screens/promos_screen.dart';
import 'package:zipapp/ui/widgets/ride_bottom_sheet.dart';
import 'package:zipapp/ui/screens/driver_verification_screen.dart';
import 'package:zipapp/ui/screens/payment_history_screen.dart';
import 'package:zipapp/ui/widgets/map.dart' as main_map;

enum BottomSheetStatus {
  closed,
  welcome,
  setPin,
  size,
  confirmation,
  searching,
  rideDetails
}

typedef MyMarkerSetter = void Function(
    BuildContext context, void Function(LocalSearchResult) methodFromChild);
typedef MyMarkerReset = void Function(
    BuildContext context, void Function() methodFromChild);

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  /*final GlobalKey<MapScreen> mapScaffoldKey;
  MainScreen(this.mapScaffoldKey);*/
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //this is the global key used for the scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late GlobalKey<MapScreen> mapScaffoldKey;
  late GlobalKey<SearchScreenState> searchScaffoldKey;
  late GlobalKey<main_map.MapSampleState> mapScaffoldKey2;
  late double screenHeight, screenWidth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late VoidCallback onBackPress;

  ///these are the services that this screen uses.
  ///you can call these services anywhere in this class.
  final UserService userService = UserService();
  final LocationService locationService = LocationService();
  final RideService rideService = RideService();
  final NotificationService notificationService = NotificationService();
  final fireBaseUser = auth.FirebaseAuth.instance.currentUser;

  ///these are used to manipulate the textfield
  ///so that you can make sure the text is in sync
  ///with the prediction.
  final searchController = TextEditingController();
  final FocusNode searchNode = FocusNode();
  String address = '';
  late LatLng pinDestination;
  final paymentService = payment_details.Payment();
  late bool zipxl;
  late double price;

  bool checkBoxValue = false;
  bool _checked = false;
  bool taccepted = true;
  bool paccepted = true;

  bool pinDropDestination = false;
  //bool _menuVisible;
  //bool termsSelect;

  String termsAndConditionsStr = 'terms and conditions not found';

  ///maps api key used for the prediction
  final String mapKey = Keys.map;

  late void Function(LocalSearchResult) setMapMarkers;
  late void Function() resetMarkers;

  ///these are for translating place details into coordinates
  ///used for creating a ride in the database
  // final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Keys.map);
  // late PlacesDetailsResponse details;

  ///these are used for controlling the bottomsheet
  ///and other things to do with creating a ride.
  late BottomSheetStatus bottomSheetStatus;

  ///this is used for toggle visibility for Drop A Pin icon
  late bool showDropPin;

  ///these are for the toggle in the top left part of the
  ///screen.
  static const bool _isCustomer = true;
  static Text customerText = const Text("Customer",
      softWrap: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontFamily: "Bebas",
        fontWeight: FontWeight.w600,
      ));

  ///these are for the toggle in the bottom left part of the
  ///screen.
  static bool _isLight = true;
  static Text mapStyleText = const Text("Light Mode",
      softWrap: false,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16.0,
        fontFamily: "Bebas",
        fontWeight: FontWeight.w600,
      ));

  // ///this is text for the sidebar
  // static Text viewProfileText = const Text("View Profile",
  //     softWrap: true,
  //     style: TextStyle(
  //       color: Colors.white,
  //       fontSize: 16.0,
  //       fontFamily: "Bebas",
  //       fontWeight: FontWeight.w600,
  //     ));
  @override
  void initState() {
    super.initState();
    mapScaffoldKey = GlobalKey();
    mapScaffoldKey2 = GlobalKey();
    bottomSheetStatus = BottomSheetStatus.welcome;
    showDropPin = false;
    onBackPress = () {
      Navigator.of(context).maybePop();
    };
    _checkLegal();
    _retrieveTermsAndConditions();
  }

  //This method checks to see if the user in firebase has accepted the TC and Privacy Policy
  void _checkLegal() async {
    //Calls the reference documents for all users
    DocumentReference termsandConditionsAcceptanceRef =
        _firestore.collection('users').doc(userService.user.uid);
    bool acceptedTerms =
        //calls the specifcic document of the users
        (await termsandConditionsAcceptanceRef.get()).get('acceptedtc');

    //If the terms and conditions is not accepted show the alert dialog
    if (acceptedTerms == false) {
      _termsAlert(context);
    } else {
      _showAlert(context);
    }
  }

  void _retrieveTermsAndConditions() async {
    DocumentReference termsAndConditionsRef =
        _firestore.collection('config_settings').doc('admin_settings');
    termsAndConditionsStr =
        (await termsAndConditionsRef.get()).get('TermsAndConditions');
    print('terms and conditions str = $termsAndConditionsStr');
  }

  // user defined function
  void _privacyAlert(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text(
            " Privacy Policy for Mobile",
            style: TextStyle(color: Color.fromRGBO(255, 242, 0, 1.0)),
          ),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                //Row
                children: <Widget>[
                  const Text(
                    PrivacyPolicies.mobile,
                    style: TextStyle(
                      color: Color.fromRGBO(255, 242, 0, 1.0),
                      decoration: TextDecoration.none,
                      fontSize: 18.0,
                      fontFamily: "Bebas",
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  //check box right here
                  CheckboxListTile(
                    title: const Text(
                        "Click here to accept these Privacy Policies",
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontFamily: "Bebas",
                          fontWeight: FontWeight.w600,
                        )),
                    controlAffinity: ListTileControlAffinity.platform,
                    value: checkBoxValue,
                    onChanged: (bool? value) {
                      setState(() {
                        checkBoxValue = true;
                        DocumentReference policyReference = _firestore
                            .collection('users')
                            .doc(userService.user.uid);
                        policyReference
                            .update({'acceptedPrivPolicy': paccepted});
                      });
                    },
                    activeColor: Colors.white,
                    checkColor: Colors.red,
                  )
                ],
              ),
            );
          }),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Next",
              ),
              onPressed: () async {
                DocumentReference termsandConditionsReference =
                    _firestore.collection('users').doc(userService.user.uid);
                bool acceptedPolicy = (await termsandConditionsReference.get())
                    .get('acceptedPrivPolicy');
                ;
                if (acceptedPolicy == true) {
                  Navigator.of(context).pop();
                  _showAlert(context);
                } else {
                  null;
                }
                ;
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
      barrierDismissible: false,
    );
  }

  // user defined function
  void _termsAlert(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text(
            " Zip Terms & Conditions",
            style: TextStyle(color: Color.fromRGBO(255, 242, 0, 1.0)),
          ),
          //This allows the state to be able to change in the alert dialog box
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            //Makes it so the text can be scrollable
            return SingleChildScrollView(
              child: Column(
                //Row
                children: <Widget>[
                  Text(
                    termsAndConditionsStr,
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 242, 0, 1.0),
                      decoration: TextDecoration.none,
                      fontSize: 18.0,
                      fontFamily: "Bebas",
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  //The start of the checkbox
                  CheckboxListTile(
                    title: const Text(
                        "Click here to accept these Terms and Conditions.",
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontFamily: "Bebas",
                          fontWeight: FontWeight.w600,
                        )),
                    controlAffinity: ListTileControlAffinity.platform,
                    value: _checked,
                    // Changes the value when checked and set state updates the value on screen
                    onChanged: (bool? value) {
                      setState(() {
                        _checked = true;
                        DocumentReference termsandConditionsAcceptanceRef =
                            _firestore
                                .collection('users')
                                .doc(userService.user.uid);
                        termsandConditionsAcceptanceRef
                            .update({'acceptedtc': taccepted});
                      });
                    },
                    activeColor: Colors.white,
                    checkColor: Colors.red,
                  ),
                ],
              ),
            );
          }),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Next",
              ),
              onPressed: () async {
                DocumentReference termsandConditionsAcceptanceRef =
                    _firestore.collection('users').doc(userService.user.uid);
                bool acceptedTerms =
                    (await termsandConditionsAcceptanceRef.get())
                        .get('acceptedtc');
                ;
                if (acceptedTerms == true) {
                  Navigator.of(context).pop();
                  _privacyAlert(context);
                } else {
                  null;
                }
                ;
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
      barrierDismissible: false,
    );
  }

// user defined function
  void _showAlert(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Welcome, ${userService.user.firstName}!",
            style: const TextStyle(color: Color.fromRGBO(255, 242, 0, 1.0)),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Ordering a Zip is simple:\n1. Enter your destination.\n2. Choose cart size.\n3. Enter your pickup location.\n\nA Zip cart will pick you up!",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 242, 0, 1.0),
                    decoration: TextDecoration.none,
                    fontSize: 18.0,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
    );
  }

  ///this returns a scaffold that contains the entire mainscreen.
  ///here you'll find that we call the map (bottom of this file),
  ///drawer(see buildDrawer function), and create the bottomsheet
  ///and the button for moving to your location. The textfield with
  ///the autocomplete functionality is also here.

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    notificationService.registerContext(context);
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(children: <Widget>[
          // TheMap(
          //   key: mapScaffoldKey,
          // ),
          main_map.Map(
            key: mapScaffoldKey,
            markerBuilder: (BuildContext context,
                void Function(LocalSearchResult) childMarkerSetter) {
              setMapMarkers = childMarkerSetter;
            },
            markerReset: (BuildContext context, void Function() childReset) {
              resetMarkers = childReset;
            },
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
                child: Stack(children: <Widget>[
              // Visibility(
              // visible: _menuVisible,
              // child:
              Card(
                  color: Colors.transparent,
                  elevation: 100,
                  child: IconButton(
                      iconSize: 44,
                      color: const Color.fromRGBO(255, 242, 0, 1.0),
                      icon: const Icon(Icons.menu),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer()))
            ])),
          ),
          Visibility(
              visible: showDropPin,
              child: const Stack(children: <Widget>[
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: SafeArea(
                //     child: IconButton(
                //       icon: Icon(Icons.arrow_back, color: Colors.white),
                //       onPressed: onBackPress
                //     ),
                //   ),
                // ),
                Center(
                    //alignment: Alignment.center,
                    child: Icon(
                  Icons.push_pin,
                  color: Colors.white,
                  size: 55,
                ))
              ]))
        ]),
        drawer: buildDrawer(context),
        bottomSheet: _buildBottomSheet());
  }

// Positioned(
//                   top: 70,
//                   bottom: 100,
//                   left: 100,
//                   right: 100,
//                   //alignment: Alignment.center,
//                   child: Icon(
//                     Icons.push_pin,
//                     color: Colors.white,
//                     size: 55,
//                   ))
  Widget _buildBottomSheet() {
    switch (bottomSheetStatus) {
      case BottomSheetStatus.closed:
        return const SizedBox(
          height: 0,
          width: 0,
        );
      case BottomSheetStatus.welcome:
        showDropPin = false;
        return Container(
          color: Colors.black,
          width: screenWidth,
          height: screenHeight * 0.35,
          padding: EdgeInsets.only(
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            top: screenHeight * 0.01,
            bottom: screenHeight * 0.01,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Hello, ${userService.user.firstName}!",
                        style: const TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 20.0,
                          fontFamily: "Bebas",
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Where are you headed?",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 22.0,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                  // Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: <Widget>[
                  GestureDetector(
                      onTap: () => {
                            print(''),
                            print(userService.user.firstName),
                            print(''),
                            searchLocation()
                          },
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            color: Colors.white,
                          ),
                          height: screenHeight * 0.07,
                          width: screenWidth * 0.8,
                          child: const Row(children: [
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Icon(Icons.search,
                                  color: Colors.black, size: 30.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text('Search Destination',
                                  style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                    fontSize: 15.0,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w400,
                                  )),
                            )
                          ])
                          // )
                          )
                      // child: TextField(
                      //     onTap: () => {
                      //       setState(() => bottomSheetStatus =
                      //           BottomSheetStatus.closed),
                      //       searchOverlayController.toggle()
                      //     },

                      //     // onTap: () async {
                      //     //   setState(() {
                      //     //     bottomSheetStatus =
                      //     //         BottomSheetStatus.closed;
                      //     //   });
                      //     //   Prediction p = await PlacesAutocomplete.show(
                      //     //           context: context,
                      //     //           hint: 'Search Destination',
                      //     //           startText: searchController.text == ''
                      //     //               ? ''
                      //     //               : searchController.text,
                      //     //           apiKey: mapKey,
                      //     //           language: "en",
                      //     //           components: [
                      //     //             Component(Component.country, "us")
                      //     //           ],
                      //     //           mode: Mode.overlay)
                      //     //       .then((v) async {
                      //     //     if (v != null) {
                      //     //       address = v.description!;
                      //     //       searchController.text = address;
                      //     //       details = await _places
                      //     //           .getDetailsByPlaceId(v.placeId!);
                      //     //     } else {
                      //     //       searchController.text = '';
                      //     //       address = '';
                      //     //       setState(() {
                      //     //         bottomSheetStatus =
                      //     //             BottomSheetStatus.welcome;
                      //     //       });
                      //     //     }
                      //     //     searchNode.unfocus();
                      //     //     _pickSize();
                      //     //     return Future<Prediction>.value(v);
                      //     //   }
                      //     //   );
                      //     // },
                      //     controller: searchController,
                      //     focusNode: searchNode,
                      //     textInputAction: TextInputAction.go,
                      //     onSubmitted: (s) {
                      //       _pickSize();
                      //     },
                      //     decoration: InputDecoration(
                      //       icon: Container(
                      //         margin: const EdgeInsets.only(left: 15),
                      //         width: 10,
                      //         height: 10,
                      //         child: const Icon(
                      //           Icons.search,
                      //           color: Colors.black,
                      //         ),
                      //       ),
                      //       hintText: "Search Destination",
                      //       border: InputBorder.none,
                      //       contentPadding: const EdgeInsets.only(
                      //           left: 15.0, top: 9.0),
                      //     ))
                      ),
                  // ]),
                  Row(
                    key: const Key('setPinRow'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: Colors.black,
                              border:
                                  Border.all(color: Colors.white, width: 1.0),
                            ),
                            height: screenHeight * 0.07,
                            width: screenWidth * 0.8,
                            child: const Row(children: [
                              Padding(
                                padding: EdgeInsets.only(left: 15.0),
                                child: Icon(Icons.pin_drop,
                                    color: Colors.white, size: 30.0),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 15.0),
                                child: Text('Or Set On Map',
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 242, 0, 1.0),
                                      decoration: TextDecoration.none,
                                      fontSize: 15.0,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w400,
                                    )),
                              )
                            ])),
                      )
                    ],
                  ),

                  //insert previous destinations if user has any
                ],
              ),
            ],
          ),
        );
      case BottomSheetStatus.setPin:
        return Container(
          color: Colors.black,
          width: screenWidth,
          height: screenHeight * 0.25,
          padding: EdgeInsets.only(
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            top: screenHeight * 0.03,
            bottom: screenHeight * 0.01,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                          ),
                          height: screenHeight * 0.07,
                          width: screenWidth * 0.8,
                          child: TextField(
                              onTap: () async {
                                setState(() {
                                  bottomSheetStatus = BottomSheetStatus.closed;
                                });
                              },
                              controller: searchController,
                              focusNode: searchNode,
                              textInputAction: TextInputAction.go,
                              onSubmitted: (s) {
                                _pickSize();
                              },
                              decoration: InputDecoration(
                                icon: Container(
                                  margin:
                                      const EdgeInsets.only(left: 20, top: 5),
                                  width: 10,
                                  height: 10,
                                  child: const Icon(
                                    MyFlutterApp.golfCart,
                                    color: Colors.black,
                                  ),
                                ),
                                hintText: 'Pin Destination',
                                /*listenForPin(),*/
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                    left: 15.0, top: 16.0),
                              ))),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.all(5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor:
                                  const Color.fromRGBO(255, 242, 0, 1.0),
                              minimumSize: const Size(84, 40)),
                          onPressed: () async {
                            pinDropDestination = true;
                            pinDestination =
                                mapScaffoldKey.currentState!._getPinDrop();
                            _pickSize();
                          },
                          child: const Text('Set Destination'))
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      case BottomSheetStatus.size:
        showDropPin = false;
        return Container(
          color: Colors.black,
          width: screenWidth,
          height: screenHeight * 0.25,
          padding: EdgeInsets.only(
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            top: screenHeight * 0.01,
            bottom: screenHeight * 0.01,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //Image.asset('assets/golf_cart.png'),
                      Text(
                        'Choose a Golf Cart size:',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 22.0,
                          fontFamily: "Bebas",
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FloatingActionButton.extended(
                        backgroundColor: const Color.fromRGBO(255, 242, 0, 1.0),
                        onPressed: () {
                          zipxl = false;
                          _checkPrice();
                        },
                        label: const Text('ZipX'),
                      ),
                      FloatingActionButton.extended(
                        backgroundColor: const Color.fromRGBO(255, 242, 0, 1.0),
                        onPressed: () {
                          zipxl = true;
                          _checkPrice();
                        },
                        label: const Text('ZipXL'),
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //Image.asset('assets/golf_cart.png'),
                      Text(
                        '3 riders            5 riders',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 22.0,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      case BottomSheetStatus.confirmation:
        showDropPin = false;
        return Container(
          color: Colors.black,
          width: screenWidth,
          height: screenHeight * 0.35,
          padding: EdgeInsets.only(
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            top: screenHeight * 0.01,
            bottom: screenHeight * 0.01,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Price: ",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Color.fromRGBO(255, 242, 0, 1.0))),
                      Text("\$$price",
                          style: const TextStyle(
                              fontSize: 16.0,
                              color: Color.fromRGBO(255, 242, 0, 1.0))),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FloatingActionButton.extended(
                          heroTag: "confirmRide",
                          backgroundColor:
                              const Color.fromRGBO(255, 242, 0, 1.0),
                          onPressed: () async {
                            var paymentMethodID =
                                await _navigateAndDisplaySelection(context);
                            print("TESTING PAYMENT ID: $paymentMethodID");
                            _lookForRide();
                          },
                          label: const Text('Confirm'),
                          icon: const Icon(Icons.check)),
                      FloatingActionButton.extended(
                        heroTag: 'cancelRide',
                        backgroundColor: const Color.fromRGBO(255, 242, 0, 1.0),
                        onPressed: () {
                          _cancelRide();
                        },
                        label: const Text('Cancel'),
                        icon: const Icon(Icons.cancel),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      case BottomSheetStatus.searching:
        showDropPin = false;
        return Container(
            color: Colors.black,
            height: screenHeight * 0.25,
            width: screenWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  ),
                ),
                const Text("Looking for driver",
                    softWrap: true,
                    style: TextStyle(
                        color: Color.fromRGBO(255, 242, 0, 1.0),
                        fontWeight: FontWeight.w400,
                        fontSize: 22.0,
                        fontFamily: "Bebas")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(255, 242, 0, 1.0),
                      // primary: const Color.fromRGBO(255, 242, 0, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                  onPressed: () {
                    _cancelRide();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ));
      case BottomSheetStatus.rideDetails:
        showDropPin = false;
        return RideDetails(
          driver: false,
          ride: rideService.ride,
          screenHeight: 0,
          screenWidth: 0,
        );
      default:
        return const SizedBox(
          height: 0,
          width: 0,
        );
    }
  }

  void searchLocation() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SearchScreen()));
    // MaterialPageRoute(
    //     builder: (context) =>
    //         const Payment()))
    if (!context.mounted) {
      print('returning from searchLocation() because context is not mounted.');
      return;
    }
    if (result != null) {
      setMapMarkers(result);
    } else {
      print('result is null');
    }
    // setState(() => bottomSheetStatus = BottomSheetStatus.confirmation);
  }

  ///this will logout the user.
  void _logOut() async {
    AuthService().signOut();
  }

  ///this will pull up setPin bottomsheet and display pin icon
  void _setPinOnMap() async {
    setState(() {
      bottomSheetStatus = BottomSheetStatus.setPin;
      showDropPin = true;
    });
  }

  ///this will pull up the bottomsheet and ask if the user what
  ///size cart they want
  void _pickSize() async {
    //TODO fix setPin check
    if ((searchController.text == address &&
            searchController.text.isNotEmpty) ||
        pinDropDestination == true) {
      setState(() {
        bottomSheetStatus = BottomSheetStatus.size;
      });
    }
  }

  Future<double> _rideDistance(bool pinDropDestination) async {
    double length;
    if (pinDropDestination) {
      length = Geolocator.distanceBetween(
          locationService.position.latitude,
          locationService.position.longitude,
          pinDestination.latitude,
          pinDestination.longitude);
    } else {
      length = 0;
      // length = Geolocator.distanceBetween(
      //     locationService.position.latitude,
      //     locationService.position.longitude,
      //     details.result.geometry!.location.lat,
      //     details.result.geometry!.location.lng);
    }
    // convert meters to miles
    length = length * 0.000621371;
    print("ride distance = $length");
    return length;
  }

  ///this will pull up the bottomsheet and ask if the user wants
  ///to move forward with the ride process
  void _checkPrice() async {
    //get current count of currentRides Collection
    DocumentReference currentRidesReference =
        _firestore.collection('CurrentRides').doc('currentRides');
    int currentNumberOfRides =
        (await currentRidesReference.get()).get('ridesGoingNow');

    if (searchController.text == address && searchController.text.isNotEmpty ||
        pinDropDestination == true) {
      double length = await _rideDistance(pinDropDestination);
      price =
          await paymentService.getAmmount(zipxl, length, currentNumberOfRides);
      print('price calculated');
      setState(() {
        bottomSheetStatus = BottomSheetStatus.confirmation;
      });
    }
  }

  ///once the rider clicks confirm it will create a ride and look
  ///for a driver
  void _lookForRide() async {
    print(rideService.ride);
    // if (pinDropDestination) {
    //   rideService.startRide(pinDestination.latitude, pinDestination.longitude,
    //       onRideChange, price);
    // } else {
    //   rideService.startRide(details.result.geometry!.location.lat,
    //       details.result.geometry!.location.lng, onRideChange, price);
    // }
  }

  void _returnToWelcome() {
    setState(() {
      bottomSheetStatus = BottomSheetStatus.welcome;
    });
  }

  ///if the rider clicks the cancel button, it will dismiss
  ///the bottomsheet and cancel the ride.
  void _cancelRide() {
    setState(() {
      bottomSheetStatus = BottomSheetStatus.welcome;
    });
    rideService.cancelRide();
  }

  void onRideChange(BottomSheetStatus status) {
    setState(() {
      bottomSheetStatus = status;
    });
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => PaymentScreen(
    //             paymentService: paymentService,
    //             key: const Key("PaymentScreen"),
    //           )),
    // );
    // return result;
  }

  ///this builds the sidebar also known as the drawer.
  Widget buildDrawer(BuildContext context) {
    _buildHeader() {
      return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userService.userID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              User user = User.fromDocument(snapshot.data!);
              return SizedBox(
                  height: screenHeight * 0.36,
                  child: DrawerHeader(
                    padding: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                    decoration: const BoxDecoration(color: Colors.black),
                    child: Column(children: [
                      buildTopRowOfDrawerHeader(context),
                      CircleAvatar(
                        radius: 60.0,
                        child: ClipOval(
                          child: SizedBox(
                            width: 130.0,
                            height: 130.0,
                            child: user.profilePictureURL == ''
                                ? Image.asset('assets/profile_default.png')
                                : Image.network(
                                    user.profilePictureURL,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                '${user.firstName} ${user.lastName}',
                                style: const TextStyle(
                                  color: Color.fromRGBO(255, 242, 0, 1.0),
                                  fontSize: 16.0,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                        ],
                      )
                    ]),
                  ));
            } else {
              return const DrawerHeader(child: Column());
            }
          });
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildHeader(),
          ListTile(
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            title: const Text('Payment'),
            onTap: () {
              Navigator.of(context).pop();
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => const Payment()));
            },
          ),
          ListTile(
            title: const Text('Payment History'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryScreen()));
            },
          ),
          ListTile(
            title: const Text('Previous Trips'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PreviousTripsScreen()));
            },
          ),
          ListTile(
            title: const Text('Promo Codes'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PromosScreen()));
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()));
            },
          ),
          ListTile(
            title: const Text('Log Out'),
            onTap: () {
              _logOut();
              _scaffoldKey.currentState?.openEndDrawer();
              Navigator.of(context).pushNamed("/root");
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Switch(
              value: _isLight,
              onChanged: (value) {
                setState(() {
                  _isLight = value;
                });
              },
              activeColor: Colors.blue[400],
              activeTrackColor: Colors.blue[100],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: mapStyleText,
          ),
        ],
      ),
    );
  }

  ///this displays user information above the drawer
  Widget buildTopRowOfDrawerHeader(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Switch(
            value: _isCustomer,
            onChanged: (value) {
              setState(() {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const VerificationScreen()));
              });
            },
            activeColor: Colors.blue[400],
            activeTrackColor: Colors.blue[100],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: customerText,
        ),
      ],
    );
  }
}

///this is the map class for displaying the google map

class TheMap extends StatefulWidget {
  const TheMap({required Key key}) : super(key: key);
  @override
  State<TheMap> createState() => MapScreen();
}

class MapScreen extends State<TheMap> {
  ///variables and services needed to  initialize the map
  ///and location of the user.
  final DriverService driverService = DriverService();
  LocationService location = LocationService();
  static LatLng _initialPosition = const LatLng(0, 0);
  // static LatLng _lastPosition;
  late LatLng _destinationPin;

  ///these three objects are used for the markers
  ///that display nearby drivers.
  final Set<Marker> _markers = {};
  BitmapDescriptor pinLocationIcon = BitmapDescriptor.defaultMarker;
  Set<LatLng> driverPositions = {
    const LatLng(32.62532, -85.46849),
    const LatLng(32.62932, -85.46249)
  };
  late List<Driver> driversList;

  ///this controller helps you manipulate the map
  ///from different places.
  final Completer<GoogleMapController> _controller = Completer();
/*
  // for my drawn routes on the map
  // this will hold the generated polylines
  Set<Polyline> _polylines = Set<Polyline>();
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
// which generates every polyline between start and finish
  PolylinePoints polylinePoints;
*/
  late BitmapDescriptor _sourceIcon;

  late BitmapDescriptor _destinationIcon;

  late LatLng pinDrop;

  // the user's initial location and current location
// as it moves
//  LocationData currentLocation;
// a reference to the destination location
  // LocationData destinationLocation;
// wrapper around the location API
  // Location location;

  ///this initalizes the map, user location, and drivers nearby.
  @override
  void initState() {
    super.initState();
    _setCustomMapPin();
    _getUserLocation();
    _getNearbyDrivers();
    pinDrop = const LatLng(32.62532, -85.46849);

    // polylinePoints = PolylinePoints();
  }

  ///this initializes the cameraposition of the map.
  static final CameraPosition _currentPosition = CameraPosition(
    target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //key: mapScaffoldKey,
        body: _initialPosition == null
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            :
            //Listener  ( child:
            GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _currentPosition,
                onMapCreated: (GoogleMapController controller) {
                  _setStyle(controller);
                  _controller.complete(controller);
                  setMapPins();
                  _getUserLocation();
                  //setPolylines();
                },
                onCameraMoveStarted: () {
                  print("camera moving");
                },
                onCameraMove: (position) {
                  //_destinationPin = position.target;
                  pinDrop = position.target;
                  //print('${position.target}');
                },
                onCameraIdle: () async {},
                zoomGesturesEnabled: true,
                markers: _markers,
                //polylines: _polylines,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                mapToolbarEnabled: true,
              ),
        //),

        floatingActionButton: FloatingActionButton(
            onPressed: () => _goToMe(),
            backgroundColor: const Color.fromRGBO(255, 242, 0, 1.0),
            child: const Icon(Icons.my_location)));
    //return new Scaffold();
  }

  LatLng _getPinDrop() {
    return pinDrop;
  }

  void _setUserDefinedPin() {
    setState(() {
      print("hjhjjhj");

      /*_markers.add(Marker(
              markerId: MarkerId('pinDrop'),
              position: _initialPosition,
              icon: pinLocationIcon));*/
    });
  }

  ///this sets the icon for the markers
  void _setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 4), 'assets/golf_cart.png');
  }

  ///this sets style for dark mode
  void _setStyle(GoogleMapController controller) async {
    String value =
        await DefaultAssetBundle.of(context).loadString('assets/map_style.txt');
    controller.setMapStyle(value);
  }

  ///this gets the current users location
  void _getUserLocation() async {
    setState(() {
      _initialPosition =
          LatLng(location.position.latitude, location.position.longitude);
    });
    driverPositions.forEach((dr) => _markers.add(Marker(
          markerId: const MarkerId('testing'),
          position: dr,
          icon: pinLocationIcon,
        )));
  }

  void setMapPins() {
    setState(() {
      // source pin
      _markers.add(Marker(
          markerId: const MarkerId('source'),
          position: _initialPosition,
          icon: _sourceIcon));
      // destination pin
      /*  _markers.add(Marker(
          markerId: MarkerId('destination'),
          position: LatLng(37.430119406953, -122.0874490566),
          icon: _destinationIcon));*/
    });
  }

  /* void setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        "AIzaSyDsPh6P9PDFmOqxBiLXpzJ1sW4kx-2LN5g",
        _initialPosition.latitude,
        _initialPosition.longitude,
        37.430119406953,
        -122.0874490566);
    result.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });

    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("p"),
          color: Colors.blue,
          points: polylineCoordinates);
      _polylines.add(polyline);
    });
  }*/

  Future<void> _goToMe() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.position.latitude, location.position.longitude),
        zoom: 14.47)));
  }

  void _getNearbyDrivers() {}
}

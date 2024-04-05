import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:zipapp/business/drivers.dart';
import 'package:zipapp/business/location.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/models/driver.dart';
import 'package:zipapp/models/request.dart';
import 'package:zipapp/models/rides.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class RideService {
  static final RideService _instance = RideService._internal();
  final bool showDebugPrints = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentReference rideReference;
  late DocumentReference currentRidesReference;
  late bool isSearchingForRide;
  late bool goToNextDriver;
  late Stream<Ride> rideStream;
  late StreamSubscription rideSubscription;
  late Ride ride;
  late Function statusUpdate;
  late bool removeRide;
  late double pickupRadius;
  late String rideID;
  Driver? acceptedDriver;
  // Services
  LocationService locationService = LocationService();
  DriverService driverService = DriverService();
  UserService userService = UserService();
  // Subscriptions
  late Stream<List<DocumentSnapshot>> nearbyDrivers;

  /*
   * Singleton constructor for RideService
   * @return RideService
   */
  factory RideService() {
    return _instance;
  }

  /*
   * Internal constructor for RideService
   * Initializes the Firestore references for the rides and current rides collections
   * and sets the rideID to the ID of the ride document.
   * @return RideService
   */
  RideService._internal() {
    rideReference = _firestore.collection('rides').doc();
    rideID = rideReference.id;
    currentRidesReference =
        _firestore.collection('CurrentRides').doc('currentRides');
  }

  /*
   * Start the ride. This function is called when the user requests a ride.
   * It initializes the ride in Firestore, starts listening to the ride document
   * and sends requests to nearby drivers. It will continue to send requests
   * until a driver accepts or the request times out.
   * @param lat: double - latitude of the user's current location
   * @param long: double - longitude of the user's current location
   * @param statusUpdateIn: Function - callback function to update the UI with the ride status
   * @param paymentPrice: double - the price of the ride
   * @return void
   */
  void startRide(double lat, double long, Function statusUpdateIn, double paymentPrice, String model) async {
    statusUpdate = statusUpdateIn;
    statusUpdate("SEARCHING");
    await _initializeRideInFirestore(lat, long);
    rideStream = rideReference
        .snapshots()
        .map((snapshot) => Ride.fromDocument(snapshot))
        .asBroadcastStream();
    rideSubscription = rideStream.listen(_onRideUpdate); // Listen to changes in ride Document and update service
    int timesSearched = 0;
    double radius = 1;
    isSearchingForRide = true;
    goToNextDriver = false;

    /// Main searching loop, get 10 closest drivers within the radius and in order of distance,
    /// send a request, wait for an answer or timeout the request after 70 seconds. Continue until
    /// a driver accepts or if there are no drivers or no driver accepted, waits 60 seconds for
    /// availability to change and restart with a new list of drivers up to 5 times.
    while (isSearchingForRide) {
      List<Driver> nearbyDrivers = await driverService.getNearbyDriversListWithModel(radius, model);
      print("Nearby drivers: $nearbyDrivers");
      if (nearbyDrivers.isNotEmpty && timesSearched < 6) {
        print('Nearby drivers not empty');
        for (int i = 0; i < nearbyDrivers.length; i++) {
          print(i);
          if (isSearchingForRide) {
            print("Is searching for ride...");
            print("Driver: ${nearbyDrivers[i].uid}");
            Driver driver = nearbyDrivers[i];
            await rideReference.update({'status': 'WAITING'});
            bool driverAccepted = await _sendRequestToDriver(driver, model, paymentPrice);
            if (driverAccepted) acceptedDriver = driver;
          }
        }
        timesSearched += 1;
      } else {
        timesSearched += 1;
        radius += 10;
        if (timesSearched > 5) {
          isSearchingForRide = false;
        } else {
          await Future.delayed(const Duration(seconds: 60));
        }
      }
    }
    if (ride.status == "IN_PROGRESS") {
      if (kDebugMode) {
        print("Ride is in progress with user: ${ride.driverName}");
      }
    } else {
      await rideReference.update({'lastActivity': DateTime.now(), 'status': "CANCELED"});
    }
  }

  /*
  * Cancel the ride. Update the status of the ride in firestore, cancel the ride subscription 
  * and remove the rider from the current rides collection.
  * @return void
  */
  void cancelRide() async {
    isSearchingForRide = false;
    goToNextDriver = true;
    statusUpdate("CANCELED");
    rideSubscription.cancel();
    DocumentSnapshot myRide = await rideReference.get();
    if (acceptedDriver == null) return;
    _getDriverReference(acceptedDriver!.uid).collection('requests').doc(rideID).delete();
    // If the ride exists, remove the rider from the current rides collection
    if (myRide.exists) {
      removeCurrentRider();
      rideReference.update({
        'lastActivity': DateTime.now(),
        'status': "CANCELED",
      });
    }
  }

  void endRide() async {
    rideSubscription.cancel();
    rideReference.update({
      'lastActivity': DateTime.now(),
      'status': "ENDED",
    });
  }

  _getDriverReference(String driverID) {
    return _firestore.collection('drivers').doc(driverID);
  }

  /// Sends a request to the specified driver using the service's current pickup and destination GeoFirePoints.
  /// Sets a 60 second timeout on the request for the driver to answer by, and waits for 70 seconds to get a responce
  /// before timing out locally.
  Future<bool> _sendRequestToDriver(Driver driver, String model, double paymentPrice) async {
    GeoFirePoint destination = locationService.getCurrentGeoFirePoint();
    GeoFirePoint pickup = locationService.getCurrentGeoFirePoint();
    // Convert GeoFirePoint to Map before sending
    Map<String, dynamic> destinationData = {
      'geopoint': destination.data['geopoint'], // Instance of GeoPoint
      'geohash': destination.data['geohash']
    };

    Map<String, dynamic> pickupData = {
      'geopoint': pickup.data['geopoint'],
      'geohash': pickup.data['geohash']
    };

    String pAmount = paymentPrice.toString();

    _firestore
      .collection('drivers')
      .doc(driver.uid)
      .collection('requests')
      .doc(rideID)
      .set(
        Request(
          id: rideID,
          name: userService.user.firstName,
          destinationAddress: destinationData,
          pickupAddress: pickupData,
          price: "\$$pAmount",
          photoURL: userService.user.profilePictureURL,
          model: model,
          timeout: Timestamp.fromMillisecondsSinceEpoch(
            Timestamp.now().millisecondsSinceEpoch + 60000
          )
        )
      .toJson());
      
  int iterations = 0;
    // Timeout loop for current request
    while (!goToNextDriver) {
      await Future.delayed(const Duration(seconds: 1));
      iterations++;
      if (iterations >= 70) {
        goToNextDriver = true;
        return Future.value(false);
      }
    }
    goToNextDriver = false;
    return Future.value(true);
  }

  void _retrievePickupRadius() async {
    // pickup radius is retrieved from config settings in firestore
    // double check with sponsors as to how the pickup radius should be implemented
    DocumentReference adminSettingsRef = _firestore.collection('config_settings').doc('admin_settings');
    pickupRadius = (await adminSettingsRef.get()).get('PickupRadius').toDouble();
  }

  // This method is attached to the ride stream and run every time the ride document in firestore changes.
  // Use it to keep the UI state in sync and the local Ride object updated.
  void _onRideUpdate(Ride updatedRide) {
    bool wasRideAlreadyCanceled = false;
    if (updatedRide.status == "CANCELED" && ride.status == "CANCELED") {
      wasRideAlreadyCanceled = true;
    }
    ride = updatedRide;
    statusUpdate(ride.status);
    switch (updatedRide.status) {
      case 'CANCELED':
        removeRide = true;
        isSearchingForRide = false;
        // updateUI(BottomSheetStatus.closed);
        if (!wasRideAlreadyCanceled) cancelRide();
        break;
      case 'IN_PROGRESS':
        isSearchingForRide = false;
        goToNextDriver = true;
        break;
      case 'INITIALIZING':
        break;
      case 'SEARCHING':
        goToNextDriver = true;
        break;
      case 'WAITING':
        break;
      case 'ENDED':
        removeRide = true;
        isSearchingForRide = false;
        goToNextDriver = false;
        removeCurrentRider();
        break;
      default:
    }
  }

  Future<void> _initializeRideInFirestore(double lat, double long) async {
    GeoFirePoint destination = locationService.getCurrentGeoFirePoint();
    GeoFirePoint pickup = locationService.getCurrentGeoFirePoint();
    DocumentSnapshot myRide = await rideReference.get();
    if (kDebugMode) {
      print('** rideReference = ${myRide.id}');
    }
    addCurrentRider();
    if (!myRide.exists) {
      // Create new ride document for the user
      await rideReference.set({
        'uid': userService.userID,
        'userName': userService.user.firstName,
        'userPhotoURL': userService.user.profilePictureURL,
        'drid': '',
        'lastActivity': DateTime.now(),
        'pickupAddress': pickup.data,
        'destinationAddress': destination.data,
        'status': "INITIALIZING",
      });
      addCurrentRider();
    } else {
      // Update user's ride document
      await rideReference.update({
        'uid': userService.userID,
        'userName': userService.user.firstName,
        'userPhotoURL': userService.user.profilePictureURL,
        'drid': '',
        'lastActivity': DateTime.now(),
        'pickupAddress': pickup.data,
        'destinationAddress': destination.data,
        'status': "INITIALIZING"
      });
    }
  }

  Future<void> addCurrentRider() async {
    // current Number of rides in "CurrentRides" collection
    int currentNumberOfRides =
        (await currentRidesReference.get()).get('ridesGoingNow');
    await currentRidesReference
        .set({'ridesGoingNow': currentNumberOfRides + 1});
  }

  Future<void> removeCurrentRider() async {
    // current Number of rides in "CurrentRides" collection
    int currentNumberOfRides =
        (await currentRidesReference.get()).get('ridesGoingNow');
    await currentRidesReference
        .set({'ridesGoingNow': currentNumberOfRides - 1});
  }

  Stream<Ride> getRideStream() {
    return rideReference.snapshots().map((snapshot) {
      return Ride.fromDocument(snapshot);
    });
  }

  Stream<QuerySnapshot> getRiderHistory() {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    CollectionReference paymentsMethods = FirebaseFirestore.instance
        .collection('rides')
        .doc(firebaseUser?.uid)
        .collection('payments');
    var paymentHist = paymentsMethods;
    if (kDebugMode) {
      print('payment history: $paymentHist');
    }
    return paymentsMethods.snapshots();
  }
}

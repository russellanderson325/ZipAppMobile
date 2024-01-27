import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';

class Ride {
  final String uid;
  final String userPictureURL;
  final String userName;
  final String drid;
  final String driverPictureURL;
  final String driverName;
  // final GeoFirePoint destinationAddress;
  // final GeoFirePoint pickupAddress;
  final String status;

  Ride(
      {required this.uid,
      required this.userName,
      required this.userPictureURL,
      required this.drid,
      required this.driverName,
      required this.driverPictureURL,
      // this.destinationAddress,
      // this.pickupAddress,
      required this.status});

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'userName': userName,
      'userPictureURL': userPictureURL,
      'drid': drid,
      'driverName': driverName,
      'driverPictureURL': driverPictureURL,
      // 'destinationAddress': destinationAddress,
      // 'pickupAddress': pickupAddress,
      'status': status
    };
  }

  factory Ride.fromJson(Map<String, Object> doc) {
    if (kDebugMode) {
      print('doc = ');
      print(doc);
    }
    Ride ride = Ride(
        uid: doc['uid'] as String,
        userName: doc['userName'] as String,
        userPictureURL: doc['userPictureURL'] as String,
        drid: doc['drid'] as String,
        driverName: doc['driverName'] as String,
        driverPictureURL: doc['driverPictureURL'] as String,
        // destinationAddress: extractGeoFirePoint(doc['destinationAddress']),
        // pickupAddress: extractGeoFirePoint(doc['pickupAddress']),
        status: doc['status'] as String);
    return ride;
  }

  factory Ride.fromDocument(DocumentSnapshot doc) {
    return Ride.fromJson(doc.data() as Map<String, Object>);
  }

  // static GeoFirePoint extractGeoFirePoint(Map<String, dynamic> pointMap) {
  //   GeoPoint point = pointMap['geopoint'];
  //   return GeoFirePoint(point.latitude, point.longitude);
  // }
}

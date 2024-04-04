// import 'dart:collection';
// import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';
import '../utils.dart';

class Driver {
  final String uid;
  final String firstName;
  final String lastName;
  final String profilePictureURL;
  final DateTime lastActivity;
  final String fcmToken; // Firebase Cloud Messaging Token
  final bool isWorking;
  final bool isAvailable;
  final GeoFirePoint? geoFirePoint;
  final String currentRideID;
  final List<String> daysOfWeek;
  final bool isOnBreak;

  Driver(
      {required this.uid,
      required this.firstName,
      required this.lastName,
      required this.lastActivity,
      required this.profilePictureURL,
      this.geoFirePoint,
      required this.fcmToken,
      required this.isWorking,
      required this.isAvailable,
      required this.currentRideID,
      required this.daysOfWeek,
      required this.isOnBreak});

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'lastActivity': lastActivity,
      'profilePictureURL': profilePictureURL,
      'geoFirePoint': geoFirePoint as Object,
      'fcmToken': fcmToken,
      'isWorking': isWorking,
      'isAvailable': isAvailable,
      'currentRideID': currentRideID,
      'daysOfWeek': daysOfWeek,
      'isOnBreak': isOnBreak
    };
  }

  factory Driver.fromJson(Map<String, dynamic> doc) {
    Driver driver = Driver(
      uid: doc['uid'] as String,
      firstName: doc['firstName'] as String,
      lastName: doc['lastName'] as String,
      lastActivity: convertStamp(doc['lastActivity'] as Timestamp),
      profilePictureURL: doc['profilePictureURL'] as String,
      geoFirePoint: extractGeoFirePoint(doc['geoFirePoint']),
      fcmToken: doc['fcmToken'] ?? "",
      isWorking: doc['isWorking'] ?? false,
      isAvailable: doc['isAvailable'] ?? false,
      isOnBreak: doc['isOnBreak'] as bool,
      currentRideID: doc['currentRideID'] as String,
      daysOfWeek: [], 
      //daysOfWeekConvert(doc['daysOfWeek']),
    );
    //totalHoursWorked: doc['totalHoursWorked']);
    return driver;
  }

  factory Driver.fromDocument(DocumentSnapshot doc) {
    return Driver.fromJson(doc.data() as Map<String, dynamic>);
  }

  static GeoFirePoint extractGeoFirePoint(Map<String, dynamic> pointMap) {
    GeoPoint point = pointMap['geopoint'];
    return GeoFirePoint(point.latitude, point.longitude);
  }

  static List<int> daysOfWeekConvert(List workDays) {
    Map dayConvert = <String, int>{};
    dayConvert['sunday'] = 0;
    dayConvert['monday'] = 1;
    dayConvert['tuesday'] = 2;
    dayConvert['wednesday'] = 3;
    dayConvert['thursday'] = 4;
    dayConvert['friday'] = 5;
    dayConvert['saturday'] = 6;

    for (var i = 0; i < workDays.length; i++) {
      String temp = workDays[i].toLowerCase();
      workDays[i] = dayConvert[temp];
    }
    return workDays as List<int>;
  }
}

class CurrentShift {
  final DateTime shiftStart;
  final DateTime shiftEnd;
  final DateTime startTime;
  final DateTime endTime;
  final int totalBreakTime;
  final int totalShiftTime;
  final DateTime breakStart;
  final DateTime breakEnd;

  CurrentShift(
      {required this.shiftStart,
      required this.shiftEnd,
      required this.startTime,
      required this.endTime,
      required this.totalBreakTime,
      required this.totalShiftTime,
      required this.breakStart,
      required this.breakEnd});

  Map<String, Object> toJson() {
    return {
      'shiftStart': shiftStart,
      'shiftEnd': shiftEnd,
      'startTime': startTime,
      'endTime': endTime,
      'totalBreakTime': totalBreakTime,
      'totalShiftTime': totalShiftTime,
      'breakStart': breakStart,
      'breakEnd': breakEnd,
    };
  }

  factory CurrentShift.fromJson(Map<String, dynamic> doc) {
    CurrentShift shift = CurrentShift(
        shiftStart: convertStamp(doc['shiftStart'] as Timestamp),
        shiftEnd: convertStamp(doc['shiftEnd'] as Timestamp),
        startTime: convertStamp(doc['startTime'] as Timestamp),
        endTime: convertStamp(doc['endTime'] as Timestamp),
        totalBreakTime: doc['totalBreakTime'] as int,
        totalShiftTime: doc['totalShiftTime'] as int,
        breakStart: convertStamp(doc['breakStart'] as Timestamp),
        breakEnd: convertStamp(doc['breakEnd'] as Timestamp));
    return shift;
  }

  factory CurrentShift.fromDocument(DocumentSnapshot doc) {
    return CurrentShift.fromJson(doc.data() as Map<String, dynamic>);
  }
}

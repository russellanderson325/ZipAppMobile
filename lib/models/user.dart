import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../utils.dart';

class User {
  final String uid;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String profilePictureURL;
  final double credits;
  final String homeAddress;
  DateTime lastActivity;
  final bool isDriver;
  final double defaultTip;
  bool acceptedtc;
  bool acceptedPrivPolicy;
  bool isRiding;
  String currentRideId;
  var pastRides;
  var pastDrives;

  User({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.credits = 0,
    this.homeAddress = "",
    required this.lastActivity,
    required this.profilePictureURL,
    this.isDriver = false,
    this.defaultTip = 0,
    this.acceptedtc = false,
    this.acceptedPrivPolicy = false,
    this.isRiding = false,
    this.currentRideId = "",
    this.pastRides,
    this.pastDrives
  });

  Map<String, Object> toJson() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'lastActivity': lastActivity,
      'email': email,
      'credits': credits,
      'homeAddress': homeAddress,
      'profilePictureURL': profilePictureURL,
      'isDriver': isDriver,
      'defaultTip': defaultTip,
      'acceptedtc': acceptedtc,
      'acceptedPrivPolicy': acceptedPrivPolicy,
      'isRiding': isRiding,
      'currentRideId': currentRideId,
      'pastRides': pastRides ?? [],
      'pastDrives': pastDrives ?? []
    };
  }

  factory User.fromJson(Map<String, dynamic> doc) {
    num creds = (doc['credits'] ?? 0.0) as num;
    num defTip = (doc['defaultTip'] ?? 0.0) as num;

    User user = User(
        uid: doc['uid'] as String,
        firstName: (doc['firstName'] ?? '') as String,
        lastName: (doc['lastName'] ?? '') as String,
        lastActivity: convertStamp(doc['lastActivity'] as Timestamp),
        phone: (doc['phone'] ?? '') as String,
        email: (doc['email'] ?? '') as String,
        credits: creds.toDouble(),
        homeAddress: (doc['homeAddress'] ?? '') as String,
        profilePictureURL: (doc['profilePictureURL'] ?? '') as String,
        isDriver: (doc['isDriver'] ?? false) as bool,
        acceptedtc: (doc['acceptedtc'] ?? false) as bool,
        acceptedPrivPolicy: (doc['acceptedPrivPolicy'] ?? false) as bool,
        isRiding: (doc['isRiding'] ?? false) as bool,
        currentRideId: doc['currentRideId'] ?? '',
        pastRides: doc['pastRides'] ?? [],
        pastDrives: doc['pastDrives'] ?? [],
        defaultTip: defTip.toDouble());
    return user;
  }

  factory User.fromFirebaseUser(auth.User fuser) {
    User user = User(
        uid: fuser.uid,
        firstName: (fuser.displayName != null &&
                fuser.displayName!.contains(" "))
            ? fuser.displayName!.substring(0, fuser.displayName!.indexOf(' '))
            : fuser.displayName ?? '',
        lastName: (fuser.displayName != null &&
                fuser.displayName!.contains(" "))
            ? fuser.displayName!.substring(
                fuser.displayName!.indexOf(' ') + 1, fuser.displayName!.length)
            : '',
        lastActivity: DateTime.now(),
        phone: fuser.phoneNumber ?? '',
        email: fuser.email ?? '',
        credits: 0,
        homeAddress: '',
        profilePictureURL: fuser.photoURL ?? '',
        isDriver: false,
        acceptedtc: false,
        acceptedPrivPolicy: false,
        isRiding: false,
        currentRideId: '',
        pastRides: [],
        pastDrives: [],
        defaultTip: 0.0);
    return user;
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data() as Map<String, dynamic>);
  }

  void updateActivity() {
    lastActivity = DateTime.now();
  }
}

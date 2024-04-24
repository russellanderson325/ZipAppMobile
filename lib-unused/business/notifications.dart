import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:zipapp/business/user.dart';

class NotificationService {
  // static final NotificationService _instance = NotificationService._internal();
  late BuildContext currentContext;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  UserService userService = UserService();
  late StreamSubscription iosSubscription;

  // factory NotificationService() {
  //   return _instance;
  // }

  // NotificationService._internal() {
  //   print("NotificationService Created");
  //   if (Platform.isIOS) {
  //     iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
  //       _saveDeviceToken();
  //     });
  //     _fcm.requestNotificationPermissions(IosNotificationSettings());
  //   } else {
  //     // Android
  //     _saveDeviceToken();
  //   }

  //   _fcm.configure(
  //     onMessage: (Map<String, dynamic> message) async {
  //       print("onMessage: $message");

  //       // Configure this if block to allow showing notifications as snackbar
  //       /*    if (false) {
  //         final snackbar = SnackBar(
  //             content: Text(message['notification']['title']),
  //             action: SnackBarAction(
  //                 label: 'Go',
  //                 onPressed: () {
  //                   // Go to new page here or do something in a service etc
  //                 }));
  //         ScaffoldMessenger.of(currentContext).showSnackBar(snackbar);
  //       } */

  //       showDialog(
  //         context: currentContext,
  //         builder: (context) => AlertDialog(
  //           content: ListTile(
  //             title: Text(message['notification']['title']),
  //             subtitle: Text(message['notification']['body']),
  //           ),
  //           actions: <Widget>[
  //             TextButton(
  //               child: const Text('Ok'),
  //               onPressed: () => Navigator.of(context).pop(),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //     onLaunch: (Map<String, dynamic> message) async {
  //       if (kDebugMode) {
  //         print("onLaunch: $message");
  //       }
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       if (kDebugMode) {
  //         print("onResume: $message");
  //       }
  //     },
  //   );
  // }

  void registerContext(BuildContext context) {
    currentContext = context;
  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken() async {
    auth.User? user = auth.FirebaseAuth.instance
        .currentUser; //await auth.FirebaseAuth.instance.currentUser();
    String? fcmToken = await _fcm.getToken();
    var tokens = _db
        .collection('users')
        .doc(user?.uid)
        .collection('tokens')
        .doc(fcmToken);
    await tokens.set({
      'token': fcmToken,
      'createdAt': FieldValue.serverTimestamp(), // optional
      'platform': Platform.operatingSystem // optional
    });
  }
}

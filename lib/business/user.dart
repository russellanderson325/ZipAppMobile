import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:zipapp/models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String userID = '';
  late Stream<User> userStream;
  late StreamSubscription userSub;
  late User user;

  factory UserService() {
    return _instance;
  }

  UserService._internal() {
    if (kDebugMode) {
      print("UserService Created with user: $userID");
    }
  }

  void setupService(String id) {
    if (userID != id) {
      userSub.cancel();
      userID = id;
      userStream = _db
          .collection("users")
          .doc(userID)
          .snapshots()
          .map((DocumentSnapshot snapshot) {
        return User.fromDocument(snapshot);
      });
      userSub = userStream.listen((user) {
        this.user = user;
      });
      print("UserService setup with user: $userID");
    }
  }

  Stream<User> getUserStream() {
    return _db
        .collection("users")
        .doc(userID)
        .snapshots()
        .map((DocumentSnapshot snapshot) {
      return User.fromDocument(snapshot);
    });
  }
}

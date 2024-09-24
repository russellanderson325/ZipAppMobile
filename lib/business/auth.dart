import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zipapp/models/user.dart';
import 'package:flutter/services.dart';

enum AuthProblems { userNotFound, passwordNotValid, networkError, unknownError }

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  //final Fires
  Stream<auth.User?> get user => _auth.authStateChanges();

  Future<auth.User?> googleSignIn() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount!.authentication;

      final auth.OAuthCredential credential =
          auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      auth.User? user = (await _auth.signInWithCredential(credential)).user;
      updateUserData(user!);
      return user;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return null;
    }
  }

  // Future<auth.User> facebookSignIn() async {
  //   try {
  //     FacebookLoginResult facebookLoginResult = await _handleFBSignIn();
  //     final accessToken = facebookLoginResult.accessToken.token;
  //     if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
  //       final auth.FacebookAuthCredential facebookAuthCred =
  //           auth.FacebookAuthProvider.credential(accessToken);
  //       final user = (await _auth.signInWithCredential(facebookAuthCred)).user;
  //       updateUserData(user);
  //       return user;
  //     } else {
  //       return null;
  //     }
  //   } catch (error) {
  //     print(error);
  //     return null;
  //   }
  // }

  // Future<FacebookLoginResult> _handleFBSignIn() async {
  //   FacebookLogin facebookLogin = FacebookLogin();
  //   FacebookLoginResult facebookLoginResult =
  //       await facebookLogin.logIn(['email']);
  //   switch (facebookLoginResult.status) {
  //     case FacebookLoginStatus.cancelledByUser:
  //       print("Cancelled");
  //       break;
  //     case FacebookLoginStatus.error:
  //       print("error");
  //       break;
  //     case FacebookLoginStatus.loggedIn:
  //       print("Logged In");
  //       break;
  //   }
  //   return facebookLoginResult;
  // }

  Future<String> signIn(String email, String password) async {
    auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    updateUserData(result.user!);
    return result.user!.uid;
  }

  Future<String> signUp(String email, String password) async {
    auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user!.uid;
  }

  Future<auth.User?> getCurrentUser() async {
    auth.User? user = _auth.currentUser;
    return user;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }

  Future<void> addUser(User user) async {
    DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
    if (doc.exists) {
      // print("user ${user.firstName} ${user.email} already exists");
    } else {
      // print("user ${user.firstName} ${user.email} added");
      _db.doc("users/${user.uid}").set(user.toJson());
    }
  }

  Future<void> updateUserData(auth.User fuser) async {
    DocumentReference userRef = _db.collection('users').doc(fuser.uid);
    DocumentSnapshot doc = await userRef.get();

    if (!doc.exists) {
      User user = User.fromFirebaseUser(fuser);
      return userRef.set(user.toJson(), SetOptions(merge: true));
    } else {
      User user = User.fromDocument(doc);
      user.updateActivity();
      return userRef.set(user.toJson(), SetOptions(merge: true));
    }
  }

  void changeUserData(String userID, String firstName, String lastName,
      String email, String phone) async {
    try {
      return await _db.collection('users').doc(userID).update({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      });
    } catch (e) {
      // print(e);
    }
  }

  Future<void> sendResetPassword(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

  String getExceptionText(Exception e) {
    if (e is auth.FirebaseAuthException) {
      print("FROM FIREBASE ${e.code}");
      switch (e.code) {
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'User account is disabled.';
        case 'user-not-found':
          return 'User with this e-mail not found.';
        case 'wrong-password':
          return 'Invalid password.';
        case 'too-many-requests':
          return 'Too many requests to login. Please try again later.';
        case 'network-request-failed':
          return 'No internet connection.';
        case 'email-already-in-use':
          return 'Email address is already taken.';
        case 'weak-password':
          return 'Password is too weak.';
        default:
          return 'Unknown error occured.';
      }
    } else {
      return 'Unknown error occured.';
    }
  }
}

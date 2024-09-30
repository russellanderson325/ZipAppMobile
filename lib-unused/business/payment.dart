import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

class Payment {
  //PaymentMethod _paymentMethod;
  var customerData = {};
  late DocumentReference cardDocumentID;
  //*******CHANGE THESE VARIABLES TO WHAT THE RIDER IS GOING TO HAVE TO PAY***********
  //SO FAR THESE ARE PLACEHOLDER NUMBERS

  //NOTE: THIS VALUE SHOULD BE THE MAXIMUM CHARGEBALE AMOUNT CALCULATED FROM COST ALGORITHM!!!!!!!!!!!!!!!!!!!!!
  //ZIP WILL ONLY CAPTURE A CERTAIN AMOUNT FROM THE MAXIMUM; THE REST WILL BE RELEASED
  //AMOUNT IS IN CENTS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //E.G. 1000 = $10.00 DOLLARS
  late double amount;
  final currency = "usd";
  final fireBaseUser = auth.FirebaseAuth.instance.currentUser;
  //var email = fireBaseUser.email;
  //var paymentMethodList;
  //Payment(amount, currency, paymentMethod, fireBaseUser);

  HttpsCallable getAmountFunction = FirebaseFunctions.instance.httpsCallable(
    'calculateCost',
  );

  Future<double> getAmount(
      bool zipXL, double length, int currentNumberOfRequests) async {
    double message;
    HttpsCallableResult result = await getAmountFunction
        .call(<String, dynamic>{
      'miles': length,
      'zipXL': zipXL,
      'customerRequests': currentNumberOfRequests
    });
    message = result.data['cost'];
    message = double.parse((message).toStringAsFixed(2));
    //set ammount so that it can be used in payment_screen.dart
    //multiply by 100 cause the payment service moves the decimal place over twice.
    amount = message * 100;
    //this.amount = double.parse(usdFormat.format(message));
    return message;
  }

  Future<void> getTipsAccum() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    CollectionReference userThings = FirebaseFirestore.instance
        .collection('drivers')
        .doc(firebaseUser?.uid)
        .collection('firstName');

    if (kDebugMode) {
      print(userThings);
    }
  }

  // Future<void> _getCustomer() async {
  //   print("i have been called");
  //   var firebaseUser = auth.FirebaseAuth.instance.currentUser;
  //   FirebaseFirestore.instance
  //       .collection('stripe_customers')
  //       .doc(firebaseUser.uid)
  //       .get()
  //       .then((DocumentSnapshot documentSnapshot) {
  //     if (documentSnapshot.exists) {
  //       print("customer exists");
  //       //customerData.forEach((k, v) => print('${k}: ${v}'));
  //     } else {
  //       print('Customer does not exist');
  //     }
  //   });
  // }

  //Data: amount, currency, paymnet_methodID, email, ride_complete
  Future<DocumentReference> triggerCloudFunctionPaymentIntent(
      paymentDetails, card) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection("stripe_customers")
        .doc(firebaseUser?.uid)
        .collection('payments')
        .add({
      "amount": paymentDetails.amount,
      "currency": currency,
      "payment_method": paymentDetails.paymentMethod,
      "receipt_email": firebaseUser?.email,
      "card_last4": card,
    });
    return documentReference;
  }

  Future<DocumentSnapshot?> validatePayment(docID) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    DocumentSnapshot? docReference;
    while (docReference == null) {
      await FirebaseFirestore.instance
          .collection("stripe_customers")
          .doc(firebaseUser?.uid)
          .collection('payments')
          .doc(docID)
          .collection('valid_check')
          .doc('payment_intent')
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          docReference = documentSnapshot;
        } else {
          docReference = null;
        }
      });
    }
    return docReference;
  }

  Future<void> sendRefundRequest(docId) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (kDebugMode) {
      print("sendRefundRequest() has been called");
    }
    await FirebaseFirestore.instance
        .collection("stripe_customers")
        .doc(firebaseUser?.uid)
        .collection('payments')
        .doc(docId)
        .collection('refund')
        .doc("refund_doc")
        .set({"refund": true});
    // return doc;
  }

  Future<bool> getRefundStatus(docId) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (kDebugMode) {
      print("getRefundStatus() has been called");
    }
    bool doc;
    doc = await FirebaseFirestore.instance
        .collection("stripe_customers")
        .doc(firebaseUser?.uid)
        .collection('payments')
        .doc(docId)
        .collection('refund')
        .doc("refund_doc")
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        doc = true;
        return true;
      } else {
        return false;
      }
    });
    return doc;
  }

  //Data: amount, currency, paymnet_methodID, email, ride_complete
  //TEST
  Future<void> collectPayment(docId) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("stripe_customers")
        .doc(firebaseUser?.uid)
        .collection('payments')
        .doc(docId)
        .update({"ride_completed": true})
        .then((value) => print("Ride is finished and paymnet collected"))
        .catchError((error) => print("Failed to update ride completion."));
    // return doc;
  }

Future<void> collectTips(docID) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("stripe_customers")
        .doc(firebaseUser?.uid)
        .get();
  }

//Add Payment method to user
  Future<void> setPaymentMethodID(paymentmethod) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    cardDocumentID = await FirebaseFirestore.instance
        .collection("stripe_customers")
        .doc(firebaseUser?.uid)
        .collection('payment_methods')
        .add({"id": paymentmethod.id});
    if (kDebugMode) {
      print("TEST: card ${cardDocumentID.id}");
      print("TEST cardID: ${cardDocumentID.id}");
    }
  }

//Functionality that deletes the Payment Method
  Future<String> deletePaymentMethod(paymentListID) {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    CollectionReference paymentsMethods = FirebaseFirestore.instance
        .collection('stripe_customers')
        .doc(firebaseUser?.uid)
        .collection('payment_methods');
    paymentsMethods
        .doc(paymentListID)
        .collection('payment')
        .doc('valid_check')
        .delete();
    return paymentsMethods
        .doc(paymentListID)
        .delete()
        .then((value) => "Card Succesfully Deleted")
        .catchError((error) => "Failed to delete Card");
  }

  Stream<QuerySnapshot> getPaymentHistory() {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    CollectionReference paymentsMethods = FirebaseFirestore.instance
        .collection('stripe_customers')
        .doc(firebaseUser?.uid)
        .collection('payments');
    return paymentsMethods.snapshots();
  }

  //This function will return a Query snapshot of payment method cards
  Stream<QuerySnapshot> getPaymentMethods() {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    CollectionReference paymentsMethods = FirebaseFirestore.instance
        .collection('stripe_customers')
        .doc(firebaseUser?.uid)
        .collection('payment_methods');
    return paymentsMethods.snapshots();
  }

  Stream<DocumentSnapshot> getRefund(docId) {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    DocumentReference doc = FirebaseFirestore.instance
        .collection("stripe_customers")
        .doc(firebaseUser?.uid)
        .collection('payments')
        .doc(docId)
        .collection('refund')
        .doc("refund_doc");
    return doc.snapshots();
  }

  /*_loadingDialog(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CircularProgressIndicator();
      },
    );
  }
*/
//   Future<DocumentSnapshot?> checkPaymentAdded() async {
//     var firebaseUser = auth.FirebaseAuth.instance.currentUser;
//     if (kDebugMode) {
//       print("card document id: $cardDocumentID");
//     }
//     var cardID = cardDocumentID.id;
//     if (kDebugMode) {
//       print("card id: $cardID");
//     }
//     DocumentSnapshot? docReference;
//     if (kDebugMode) {
//       print("payment doc reference: $docReference");
//     }
//     while (docReference == null) {
//       //print("TEST3: ${docReference.data()}");
//       await FirebaseFirestore.instance
//           .collection("stripe_customers")
//           .doc(firebaseUser?.uid)
//           .collection('payment_methods')
//           .doc(cardID)
//           .collection('payment')
//           .doc('valid_check')
//           .get()
//           .then((DocumentSnapshot documentSnapshot) {
//         if (documentSnapshot.exists) {
//           if (kDebugMode) {
//             print("payment snapshot exists");
//           }
//           docReference = documentSnapshot;
//           if (kDebugMode) {
//             print("payment doc reference: ${docReference?.data()}");
//           }
//         } else {
//           if (kDebugMode) {
//             print("payment snapshot not found");
//           }
//           docReference = null;
//         }
//       });
//       // print("TEST4: ${docReference.data()}");
//     }
//     //Navigator.of(context).pop();
//     if (kDebugMode) {
//       print("payment doc reference.data: ${docReference?.data()}");
//     }
//     return docReference;
//   }
}
/*
  This file contains the Payment class which is used to handle all the payment methods and payment intents.
  It contains methods to create, delete, and retrieve payment methods, as well as to create payment intents.
  It also contains a method to show an alert dialog to confirm the deletion of a payment method.
  Apple Pay and Google Pay are also supported in this class.

  We use Firebase Functions for all secret key handling and payment method stuff.
*/
import 'dart:async';
import 'dart:ffi';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class Payment {
  static final _firebaseUser = auth.FirebaseAuth.instance.currentUser;
  static final FirebaseFunctions functions = FirebaseFunctions.instance;

  // Firebase Functions
  static final getPaymentMethodDetailsCallable = functions.httpsCallable('getPaymentMethodDetails');
  static final removePaymentMethodCallable = functions.httpsCallable('removePaymentMethod');
  static final attachPaymentMethodToCustomerCallable = functions.httpsCallable('attachPaymentMethodToCustomer');
  static final createPaymentIntentCallable = functions.httpsCallable('createPaymentIntent');
  static final getAmmountFunctionCallable = functions.httpsCallable('calculateCost');


  static Future<double> getAmmount(bool zipXL, double length, int currentNumberOfRequests) async {
    double amount;
    HttpsCallableResult result = await getAmmountFunctionCallable
        .call(<String, dynamic>{
      'miles': length,
      'zipXL': zipXL,
      'customerRequests': currentNumberOfRequests
    });
    amount = result.data['cost'];
    //set ammount so that it can be used in payment_screen.dart
    //multiply by 100 cause the payment service moves the decimal place over twice.
    return amount;
  }
  /*
   * This method is used to create a payment intent. It basically declares the intention
   * to make a payment and returns the payment intent (sort of).
   * @param amount - the amount to be paid
   * @param currency - the currency code for the payment
   * @return Future<String> - a future that resolves to the payment intent
   */
  static Future<String> createPaymentIntent(int amount, String currency) async {
    try {
      final HttpsCallableResult result = await createPaymentIntentCallable.call(
        {
          'amount': amount,
          'currency': currency,
        }
      );
      return result.data;
    } catch (e) {
      return '';
    }
  }

  /*
   * This method is used to show the payment sheet to make a payment.
   * It should show the Apple Pay sheet for iOS and the Google Pay sheet 
   * for Android (hopefully -- Android still needs testing).
   * @param label - the label for the payment
   * @param amount - the amount to be paid
   * @param currencyCode - the currency code for the payment
   * @param merchantCountryCode - the merchant country code
   */
  static void showPaymentSheetToMakePayment(label, amount, currencyCode, merchantCountryCode) async {
    String paymentIntent = await createPaymentIntent(amount, currencyCode);
    DocumentReference<Map<String, dynamic>> stripeCustomer = await FirebaseFirestore.instance
        .collection('stripe_customers')
        .doc(_firebaseUser?.uid);

    var documentSnapshot = await stripeCustomer.get();
    var customerId = documentSnapshot.data()?['customer_id'];

    // Initialize the payment sheets for iOS and Andriod
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        customerId: customerId,
        customFlow: false,
        paymentIntentClientSecret: paymentIntent.toString(),
        allowsDelayedPaymentMethods: false,
        removeSavedPaymentMethodMessage: 'Remove Payment Method',
        primaryButtonLabel: 'Pay',
        style: ThemeMode.system,
        applePay: PaymentSheetApplePay(
          merchantCountryCode: merchantCountryCode,
          cartItems: [
            ApplePayCartSummaryItem.immediate(label: label, amount: (amount / 100).toString()),
          ],
          buttonType: PlatformButtonType.pay,
        ),
        googlePay: PaymentSheetGooglePay(
          merchantCountryCode: merchantCountryCode,
          currencyCode: currencyCode,
          label: label,
          amount: (amount / 100).toString(),
        ),
      ),
    );

    try {
      // Present the Payment Sheet
      await Stripe.instance.presentPaymentSheet();
      print("Payment successful");
    } catch (error) {
      print("Payment failed: $error");
    }
  }

  // Card Payment Functionality via Stripe

  /*
  * This method adds the payment method id to the firebase database.
  * @param paymentMethodId - the id of the payment method
  * @return Future<void> - a future that resolves when the payment method id is added
  */
  static Future<void> setPaymentMethodIdAndFingerprint(String paymentMethodId, String fingerprint) async {
    DocumentReference<Map<String, dynamic>> stripeCustomer = FirebaseFirestore.instance
          .collection('stripe_customers')
          .doc(_firebaseUser?.uid);
    
    var documentSnapshot = await stripeCustomer.get();
    var customerId = documentSnapshot.data()?['customer_id'];
          
    // First check to see if finger print already exists in users payment methods
    var querySnapshot = await stripeCustomer
        .collection('payment_methods')
        .where('fingerprint', isEqualTo: fingerprint)
        .get();

    // If the fingerprint exists, we don't want to add it again and we delete the payment method from the Stripe API
    if (querySnapshot.docs.isNotEmpty) {
      await removePaymentMethod(paymentMethodId);
      throw Exception('Payment method already exists');
    }
    // If the fingerprint doesn't exist, we add the payment method to the database
    if (_firebaseUser != null) {
      await stripeCustomer
          .collection('payment_methods')
          .add({
            "id": paymentMethodId,
            "fingerprint": fingerprint,
          });
    }

    // Attach the payment method to the customer in the Stripe API
    attachPaymentMethodToCustomerCallable.call(
      {
        'paymentMethodId': paymentMethodId,
        'customerId': customerId,
      }
    );
  }

  /*
  * This method is used to create a payment method. It creates the payment method 
  * and stores it in the Stripe server.
  * @return Future<PaymentMethod?> - a future that resolves to the payment method
  */
  static Future<PaymentMethod?> createPaymentMethod() async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      return paymentMethod;
    } catch (e) {
      print("Error creating payment method...");
      rethrow;
    }
  }

  /*
  * This method is used to delete a payment method Id from the firebase database.
  * We also delete the payment method from the Stripe API (!!!IMPORTANT!!!).
  * @param paymentListId - the id of the payment method
  * @return Future<void> - a future that resolves when the payment method is deleted
  */
  static Future<void> removePaymentMethod(String paymentMethodId) async {
    if (_firebaseUser != null) {
      try {
        // First we call the cloud function to remove the payment method from the Stripe API
        // If it fails, we don't want to delete the payment method from the database
        await removePaymentMethodCallable.call({'paymentMethodId': paymentMethodId});

        // Get the payment method document from the database where the id matches the paymentMethodId
        var querySnapshot = await FirebaseFirestore.instance
            .collection('stripe_customers')
            .doc(_firebaseUser?.uid)
            .collection('payment_methods')
            .where('id', isEqualTo: paymentMethodId)
            .get();

        // Loop through the documents and delete each one
        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print('Error calling function: $e');
      }
    }
  }

  /*
  * This method retrieves all payment method Ids that we store for the current user.
  * @return List<String> - a list of payment method ids
  */
  static Future<List<String>> getPaymentMethodIds() async {
    if (_firebaseUser != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('stripe_customers')
            .doc(_firebaseUser!.uid)
            .collection('payment_methods')
            .get();

        // Process data into a list
        List<String> paymentMethodIds = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['id'])
          .where((id) => id.length > 0) // Filter out empty ids
          .map((id) => id as String) // Cast remaining ids to String
          .toList();

        return paymentMethodIds;
      } catch (e) {
        print("Error fetching payment method IDs: $e");
        return [];
      }
    } else {
      return [];
    }
  }
  
  /*
  * This method is used to get the payment method details by the payment method id.
  * @param paymentMethodId - the id of the payment method
  * @return Map<String, dynamic>? - the payment method details
  */
  static Future<Map<String, dynamic>?> getPaymentMethodById(String paymentMethodId) async {
    try {
      final results = await getPaymentMethodDetailsCallable.call({'paymentMethodId': paymentMethodId});
      Map<String, dynamic> data = results.data;
      data['id'] = paymentMethodId; // Add the payment method id to the data
      return data;
    } catch (e) {
      print('Error calling function: $e');
      return null;
    }
  }

  /*
  * This method retrieves all payment methods and their details for the current user.
  * @return List<Map<String, dynamic>?> - a list of payment method details
  */
  static Future<List<Map<String, dynamic>?>> getPaymentMethodsDetails() async {
    List<String> paymentMethodIds = await getPaymentMethodIds();
    // Wait for all futures to complete and collect their results
    final results = await Future.wait(paymentMethodIds.map(getPaymentMethodById));
    // Filter out nulls if necessary, depending on whether you want to keep or discard failed lookups
    return results.where((result) => result != null).toList();
  }
}

// Graveyard of old methods
// Ignore the code/comments below here, it's just for reference or in case it's needed later

// Shows the Delete Alert Dialog (needs a BuildContext to be passed if used within a widget)
// I don't think this is used anywhere, but it's here just in case (Jordyn Lewis 3/20/24)
// static Future<void> showDeleteAlertDialog(BuildContext context, String paymentListId, Function onDelete) async {
//   return showCupertinoDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return CupertinoAlertDialog(
//         title: const Text("Delete?"),
//         content: const Text("Are you sure?"),
//         actions: <Widget>[
//           CupertinoDialogAction(
//             child: const Text("No"),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           CupertinoDialogAction(
//             child: const Text("Yes"),
//             onPressed: () {
//               onDelete().then(() {
//                 Navigator.of(context).pop();
//               });
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

// Adds a Payment Method Dialog (static context needed)
// I don't think this is used anywhere, but it's here just in case (Jordyn Lewis 3/20/24)
// static Future<void> addPaymentMethodDialog(BuildContext context) async {
//   return showCupertinoDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (BuildContext context) {
//       return CupertinoAlertDialog(
//         title: const Text("Payment Added Successfully!"),
//         actions: <Widget>[
//           CupertinoDialogAction(
//               child: const Text("OK"),
//               onPressed: () => Navigator.of(context).pop(),
//           ),
//         ],
//       );
//     },
//   );
// }
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     // backgroundColor: Colors.grey[800],
//     // key: _scaffoldKey,
//     appBar: AppBar(
//       title: const Text(
//         'Payment Methods',
//       ),
//       actions: <Widget>[
//         IconButton(
//           icon: const Icon(Icons.clear),
//           onPressed: () {
//             setState(() {
//               // _paymentIntent = null;
//               // _paymentMethod = null;
//             });
//             Navigator.pop(context);
//           },
//         )
//       ],
//     ),
//     body: ListView(
//       // controller: _controller,
//       // padding: EdgeInsets.zero,
//       // children: <Widget>[
//         //Gets Payment Methods
//       //   Card(
//       //     child: ExpansionTile(
//       //       leading: const Icon(Icons.view_headline),
//       //       title: const Text("Payment Methods"),
//       //       children: [
//       //         StreamBuilder<QuerySnapshot>(
//       //           stream: _getPaymentMethods(),
//       //           builder: (context, snapshot) {
//       //             /* Timer(Duration(seconds: 2), () {
//       //               print("Yeah, this line is printed after 2 seconds");
//       //             });*/
//       //             /*if (snapshot.hasError) {
//       //               return CircularProgressIndicator();
//       //             }*/
//       //             if (snapshot.hasData) {
//       //               debugPrint("build widget: ${snapshot.data}");
//       //               List<QueryDocumentSnapshot> paymentList =
//       //                   snapshot.data!.docs;
//       //               return DataTable(
//       //                 columnSpacing: 50,
//       //                 columns: const <DataColumn>[
//       //                   DataColumn(
//       //                     label: Text(
//       //                       'Brand',
//       //                       style: TextStyle(fontStyle: FontStyle.italic),
//       //                     ),
//       //                   ),
//       //                   DataColumn(
//       //                     label: Text(
//       //                       'Last4',
//       //                       style: TextStyle(fontStyle: FontStyle.italic),
//       //                     ),
//       //                   ),
//       //                   DataColumn(
//       //                     label: Text(
//       //                       'Ending',
//       //                       style: TextStyle(fontStyle: FontStyle.italic),
//       //                     ),
//       //                   ),
//       //                   //Column for trash icon
//       //                   DataColumn(
//       //                     label: Text(""),
//       //                   ),
//       //                 ],
//       //                 rows: List<DataRow>.generate(
//       //                   paymentList.length,
//       //                   (index) => DataRow(
//       //                       /*onSelectChanged: (bool selected) {
//       //                         if (selected) {
//       //                           log.add('row-selected: ${itemRow.index}');
//       //                         }
//       //                       },*/
//       //                       cells: [
//       //                         DataCell(
//       //                             Text(paymentList[index]["card"]["brand"]),
//       //                             onTap: () {
//       //                           print(
//       //                               "TESTING Id: ${paymentList[index]['id']})");
//       //                           //ONLY FOR PAYMENT ONLY //MUST DELETE THIS***************
//       //                           Navigator.pop(
//       //                               context, paymentList[index]['id']);
//       //                         }),
//       //                         DataCell(
//       //                             Text(paymentList[index]["card"]["last4"]),
//       //                             onTap: () {
//       //                           //ONLY FOR PAYMNET ONLY! MUST DELETE THIS******************
//       //                           Navigator.pop(
//       //                               context, paymentList[index]['id']);
//       //                         }),
//       //                         DataCell(
//       //                             //(var number = 5);
//       //                             Text(
//       //                                 '${paymentList[index]["card"]["exp_month"]}/${paymentList[index]["card"]["exp_year"]}'),
//       //                             onTap: () {
//       //                           Navigator.pop(context,
//       //                               paymentList[index]['card']['id']);
//       //                         }),
//       //                         DataCell(
//       //                           const Icon(Icons.delete_outline),
//       //                           onTap: () async {
//       //                             print("TEST: ${paymentList[index].id}");
//       //                             await _showDeleteAlertDialog(
//       //                                 paymentList[index].id);
//       //                           },
//       //                         )
//       //                       ]),
//       //                 ),
//       //               );
//       //             } else {
//       //               // We can show the loading view until the data comes back.
//       //               debugPrint('build loading widget');
//       //               return const CircularProgressIndicator();
//       //             }
//       //           },
//       //         ),
//       //       ],
//       //     ),
//       //   ),
//       //   // const Card(
//       //   //   child: ListTile(
//       //   //     leading: Icon(Icons.add_circle_outline),
//       //   //     title: Text("Add new credit/debit card"),
//       //   //     // onTap: () {
//       //   //     //   StripePayment.paymentRequestWithCardForm(
//       //   //     //           CardFormPaymentRequest())
//       //   //     //       .then((paymentMethod) {
//       //   //     //     ScaffoldMessenger.of(context).showSnackBar(
//       //   //     //         SnackBar(content: Text('Received ${paymentMethod.id}')));
//       //   //     //     setState(() {
//       //   //     //       //_getCustomer();
//       //   //     //       _paymentMethod = paymentMethod;
//       //   //     //       _setPaymentMethodIdAndFingerprint(_paymentMethod);
//       //   //     //       _addPaymentMethodDialog();
//       //   //     //     });
//       //   //     //   }).catchError(setError);
//       //   //     //   //_addPaymentMethodDialog();
//       //   //     // },
//       //   //   ),
//       //   // ),
//       //   /* Divider(),
//       //   Text('Customer data method:'),
//       //   Text(
//       //     JsonEncoder.withIndent('  ')
//       //         .convert(_paymentMethod?.toJson() ?? {}),
//       //     style: TextStyle(fontFamily: "Monospace"),
//       //   ),*/
//       // ],
//     ),
//   );
// }
/* Expanded(
                      child: SizedBox(
                        height: 400.0,
                        child: ListView.builder(
                          // leading: Icon(Icons.view_headline),
                          itemCount: paymentList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                  '${paymentList[index]["brand"]} ending in ${paymentList[index]["last4"]} \t\t Ending on ${paymentList[index]["monthAndYear"]}'),
                            );
                          },
                        ),
                      ),
                    );*/
/*FutureBuilder(
                future: _getPaymentMethods(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    debugPrint("build widget: ${snapshot.data}");
                    var paymentList = snapshot.data;
                    print("PaymentList: $paymentList");
                    print(
                        'TEST: ${paymentList[0]["brand"]} ending in ${paymentList[0]["last4"]} \t\t\t\t Ending on ${paymentList[0]["monthAndYear"]}');
                    return ExpansionTile(
                        leading: Icon(Icons.credit_card),
                        title: Text("Credit cards"),
                        children: new List.generate(
                            snapshot.data.length,
                            (index) => new Card(
                                    //title: Text(
                                    //  '${paymentList[index]["brand"]} ending in ${paymentList[index]["last4"]} \t\t Ending on ${paymentList[index]["monthAndYear"]}'),
                                    child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                          '${paymentList[index]["brand"]} ending in ${paymentList[index]["last4"]} \t\t Ending on ${paymentList[index]["monthAndYear"]}'),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.delete_outline),
                                          onPressed: () {
                                            _scaffoldKey.currentState
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'This will delete ${paymentList[index]}')));
                                          },
                                          //icon: Icon(Icons.delete_outline),
                                        )
                                      ],
                                    ),
                                  ],
                                ))));
                  } else {
                    // We can show the loading view until the data comes back.
                    debugPrint('build loading widget');
                    return CircularProgressIndicator();
                  }
                },
              ),*/
/*  FutureBuilder(
            future: _getPaymentMethods(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                debugPrint("build widget: ${snapshot.data}");
                return ExpansionTile(
                    // leading: Icon(Icons.view_headline),
                    title: Text("Existing cards"),
                    children: new List.generate(
                        snapshot.data.length,
                        (index) => new ListTile(
                              title: Text(
                                  '${snapshot.data[index]["brand"]} ending in ${snapshot.data[index]["last4"]} \t\t Ending on ${snapshot.data[index]["monthAndYear"]}'),
                            )));
              } else {
                // We can show the loading view until the data comes back.
                debugPrint('build loading widget');
                return 
              }
            },
          ),*/
//)),*/
// ignore: await_only_futures
/*var paymentMethodList = [];
    var firebaseUser = await auth.FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('stripe_customers')
        .doc(firebaseUser.uid)
        .collection('payment_methods')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var paymentMethod = doc.data();
        bool check = paymentMethod["type"] == "card";
        List emptyList = [];
        if (!check) {
          //do nothing
          print("oh no: $paymentMethod");
          return emptyList;
        } else {
          print("i got here324: $paymentMethod");
          var map = new Map();
          var last4 = paymentMethod["card"]["last4"];
          print("ads: $last4");
          var brand = paymentMethod["card"]["brand"];
          print("watch out: $brand");
          // var type =
          var monthAndYear =
              "${paymentMethod["card"]["exp_month"]}/${paymentMethod["card"]["exp_year"]}";
          map["last4"] = last4;
          map["brand"] = brand;
          map["monthAndYear"] = monthAndYear;
          paymentMethodList.add(map);
        }
      });
    });
    return paymentMethodList;*/
//POtential GetPaymethod methods screen
/*
                      return ExpansionTile(
                        leading: Icon(Icons.credit_card),
                        title: Text("Credit cards"),
                        children:
                            snapshot.data.docs.map((DocumentSnapshot document) {
                          bool check = document.data()["type"] == "card";
                          if (!check) {
                            //do nothing
                            return SizedBox.shrink();
                          } else {
                            print(
                                'TEST: ${document.data()["card"]["brand"]} ending in ${document.data()["card"]["last4"]} \t\t Ending on ${document.data()["card"]["exp_month"]}/${document.data()["card"]["exp_year"]}');
                            return new Card(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                      '${document.data()["card"]["brand"]} ending in ${document.data()["card"]["last4"]} \t\t Ending on ${document.data()["card"]["exp_month"]}/${document.data()["card"]["exp_year"]}'),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.delete_outline),
                                      onPressed: () {
                                        _scaffoldKey.currentState.showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'This will delete ${document.data()["card"]["last4"]}')));
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ));
                          }
                        }).toList(),
                      );*/
/*Future<void> createPaymentMethod() async {
    StripePayment.setStripeAccount(null);
    //tax = ((totalCost * taxPercent) * 100).ceil() / 100;
    //amount = ((totalCost + tip + tax) * 100).toInt();
    //print('amount in pence/cent which will be charged = $amount');
    //step 1: add card
    PaymentMethod paymentMethod = PaymentMethod();
    paymentMethod = await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) {
      return paymentMethod;
    }).catchError((e) {
      print('Errore Card: ${e.toString()}');
    });
    paymentMethod != null
        ? processPaymentAsDirectCharge(paymentMethod)
        : showDialog(
            context: context,
            builder: (BuildContext context) => ShowDialogToDismiss(
                title: 'Error',
                content:
                    'It is not possible to pay with this card. Please try again with a different card',
                buttonText: 'CLOSE'));
} */
// Future<void> _getCustomer() async {
  //   print("i have been called");
  //   var firebaseUser = auth.FirebaseAuth.instance.currentUser;
  //   FirebaseFirestore.instance
  //       .collection('stripe_customers')
  //       .doc(firebaseUser?.uid)
  //       .get()
  //       .then((DocumentSnapshot documentSnapshot) {
  //     if (documentSnapshot.exists) {
  //       _customerId = documentSnapshot.data()['customer_id'];
  //       _setupSecret = documentSnapshot.data()['setup_secret'];
  //       customerData = documentSnapshot.data();
  //       if (kDebugMode) {
  //         print("hello");
  //       }
  //       //customerData.forEach((k, v) => print('${k}: ${v}'));
  //     } else {
  //       if (kDebugMode) {
  //         print('Customer does not exist');
  //       }
  //     }
  //   });
  // }
// Future<void> _triggerCloudFunctionPaymentIntent(data) async {
  //   var firebaseUser = await auth.FirebaseAuth.instance.currentUser;
  //   FirebaseFirestore.instance
  //       .collection("stripe_customers")
  //       .doc(firebaseUser.uid)
  //       .collection('payments')
  //       .add(data);
  // }
// void setError(dynamic error) {
  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(SnackBar(content: Text(error.toString())));
  //   setState(() {
  //     _error = error.toString();
  //   });
  // }
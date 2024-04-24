/*
  This file contains the Payment class which is used to handle all the payment methods and payment intents.
  It contains methods to create, delete, and retrieve payment methods, as well as to create payment intents.
  It also contains a method to show an alert dialog to confirm the deletion of a payment method.
  Apple Pay and Google Pay are also supported in this class.

  We use Firebase Functions for all secret key handling and payment method stuff.
*/
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zipapp/models/primary_payment_method.dart';

class Payment {
  static final _firebaseUser = auth.FirebaseAuth.instance.currentUser;
  static final FirebaseFunctions functions = FirebaseFunctions.instance;
  static PrimaryPaymentMethod primaryPaymentMethodStatic = PrimaryPaymentMethod(
    applePay: false,
    googlePay: false,
    card: false,
    paymentMethodId: '',
  );
  static const currency = "USD";


  // Firebase Functions
  static final getPaymentMethodDetailsCallable = functions.httpsCallable('getPaymentMethodDetails');
  static final removePaymentMethodCallable = functions.httpsCallable('removePaymentMethod');
  static final attachPaymentMethodToCustomerCallable = functions.httpsCallable('attachPaymentMethodToCustomer');
  static final createPaymentIntentCallable = functions.httpsCallable('createPaymentIntent');
  static final capturePaymentIntentCallable = functions.httpsCallable('capturePaymentIntent');
  static final cancelPaymentIntentCallable = functions.httpsCallable('cancelPaymentIntent');
  static final getAmountFunctionCallable = functions.httpsCallable('calculateCost');

  static void addPaymentDetailsToFirebase(paymentDetails) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
      .collection("stripe_customers")
      .doc(firebaseUser?.uid)
      .collection('payments')
      .doc(paymentDetails['paymentIntentId'])
      .set({
        "rideId": paymentDetails['rideId'],
        "payment_method": paymentDetails['paymentMethod'],
        "receipt_email": firebaseUser?.email,
        "captured": false,
        "rideCanceled": false,
        "rideCompleted": false,
        "rideRefunded": false,
        "paymentIntentId": paymentDetails['paymentIntentId'],
        "paymentMethod": paymentDetails?['id'],
        "amount": paymentDetails['amount'],
        "currency": currency,
        "card_last4": paymentDetails?['last4'],
      });
  }

  static void capturePaymentIntentFromFirebaseByUserIdAndRideId(userId, rideId) async {
    Query<Map<String, dynamic>> paymentSnapshot = FirebaseFirestore.instance
      .collection("stripe_customers")
      .doc(userId)
      .collection('payments')
      .where('rideId', isEqualTo: rideId);
    
    try {
      // Execute the query to get the QuerySnapshot
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await paymentSnapshot.get();

      // Check if the snapshot contains any documents
      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
          String paymentIntentId = doc.get('paymentIntentId');

          capturePaymentIntent(paymentIntentId);

          doc.reference.update({
            "captured": true,
            "rideCompleted": true,
          });
        }
      } else {
        print("No documents found with the specified rideId.");
      }
    } catch (e) {
      // Handle errors if the field does not exist or query fails
      print("Error fetching documents: $e");
    }
  }

  static void cancelPaymentIntentFromFirebaseByUserIdAndRideId(userId, rideId) async {
    Query<Map<String, dynamic>> paymentSnapshot = FirebaseFirestore.instance
      .collection("stripe_customers")
      .doc(userId)
      .collection('payments')
      .where('rideId', isEqualTo: rideId);
    
    try {
      // Execute the query to get the QuerySnapshot
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await paymentSnapshot.get();

      // Check if the snapshot contains any documents
      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
          String paymentIntentId = doc.get('paymentIntentId');

          cancelPaymentIntent(paymentIntentId);

          doc.reference.update({
            "captured": false,
            "rideCanceled": true,
          });
        }
      } else {
        print("No documents found with the specified rideId.");
      }
    } catch (e) {
      // Handle errors if the field does not exist or query fails
      print("Error fetching documents: $e");
    }
  }

  /*
   * Fetches the payment methods from the cache if they exist
   * Otherwise, fetches from the Stripe API
   * @return Future<List<Map<String, dynamic>?>> The payment methods
   */
  static Future<List<Map<String, dynamic>?>> fetchPaymentMethodsIfNeeded(forceUpdate) async {
    List<Map<String, dynamic>?> cachedPaymentMethods = await Payment.getPaymentMethodsCache();
    if (cachedPaymentMethods.isEmpty || forceUpdate) {
      forceUpdate = false;
      // Fetch from Stripe API
      List<Map<String, dynamic>?> fetchedMethods = await Payment.getPaymentMethodsDetails();
      Payment.setPaymentMethodsCache(fetchedMethods);
      return fetchedMethods;
    } else {  
      return cachedPaymentMethods;
    }
  }

  static Future<Map<String, dynamic>?> getPrimaryPaymentMethodDetails() async {
    PrimaryPaymentMethod primaryPaymentMethod = await Payment.getPrimaryPaymentMethod();
    if (!primaryPaymentMethod.applePay && !primaryPaymentMethod.googlePay) {
      Future<Map<String, dynamic>?> paymentMethod = Payment.getPaymentMethodById(primaryPaymentMethod.paymentMethodId);
      return paymentMethod;
    } else {
      // If the primary payment method is Apple/Google Pay, return a map with the brand and id
      Map<String, dynamic> paymentMethod = {
        'brand': Platform.isIOS ? 'Apple Pay' : 'Google Pay',
        'last4': "",
        'id': Platform.isIOS ? 'apple_pay' : 'google_pay',
      };
      return Future.value(paymentMethod);
    }
  }

  static Future<PrimaryPaymentMethod> setPrimaryPaymentMethod(bool applePay, bool googlePay, bool card, String paymentMethodId) async {
    PrimaryPaymentMethod primaryPaymentMethod = PrimaryPaymentMethod(
      applePay: applePay,
      googlePay: googlePay,
      card: card,
      paymentMethodId: paymentMethodId,
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('primaryPaymentMethod', json.encode(primaryPaymentMethod));
    primaryPaymentMethodStatic = primaryPaymentMethod;
    return primaryPaymentMethod;
  }

  /*
   * This method is used to get the primary payment method for the user.
   * If the user has not set a primary payment method, it will set the primary payment method
   * based on the platform (Apple Pay for iOS, Google Pay for Android).
   * Note: It is stored in the shared preferences.
   * @return Future<PrimaryPaymentMethod> - a future that resolves to the primary payment method
   */
  static Future<PrimaryPaymentMethod> getPrimaryPaymentMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String primaryPaymentMethodString = prefs.getString('primaryPaymentMethod') ?? '';
    // Check if the primary payment method is set in shared preferences
    if (primaryPaymentMethodString == ''){
      // If the primary payment method is not set, set it based on the platform
      PrimaryPaymentMethod primaryPaymentMethod = PrimaryPaymentMethod(
        applePay: Platform.isIOS,
        googlePay: Platform.isAndroid,
        card: false,
      );
      // Store the primary payment method in shared preferences
      prefs.setString('primaryPaymentMethod', json.encode(primaryPaymentMethod));
      return primaryPaymentMethod;
    } else {
      // If the primary payment method is set, get it from shared preferences
      PrimaryPaymentMethod primaryPaymentMethod = PrimaryPaymentMethod.fromJson(json.decode(primaryPaymentMethodString));

      // If the primary payment method doesn't exist in Firebase set and return the primary payment method to Apple/Google Pay
      // Check to see if payment method id is in Firebase
      List<Map<String, dynamic>?> paymentMethodsInFirebase = await getPaymentMethodsDetails();
      List<String> paymentMethodIds = paymentMethodsInFirebase.map((e) => (e?['id']).toString()).toList();
      if (!paymentMethodIds.contains(primaryPaymentMethod.paymentMethodId)) {
        primaryPaymentMethod = await setPrimaryPaymentMethod(Platform.isIOS, Platform.isAndroid, false, '');
        primaryPaymentMethodStatic = primaryPaymentMethod;
        return primaryPaymentMethod;
      } else {
        primaryPaymentMethodStatic = primaryPaymentMethod;
        return primaryPaymentMethod;
      }
    }
  }

  /*
   * This method is used to calculate the cost of a ride based on the length of the ride.
   * @param zipXL - a boolean indicating whether the ride is a ZipXL ride
   * @param length - the length of the ride
   * @param currentNumberOfRequests - the number of requests the user has made
   * @return Future<double> - a future that resolves to the cost of the ride
   */
  static Future<double> getAmount(bool zipXL, double length, int currentNumberOfRequests) async {
    double amount;
    HttpsCallableResult result = await getAmountFunctionCallable
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
   * This method is used to modify the price of a payment intent and capture it.
   * This is specifically useful when the user decides to split the fair among users.
   * @param paymentIntent - the payment intent to be captured
   * @param amount - the amount to be captured
   */
  static void modifyPriceAndCapturePaymentIntent(String paymentIntent, int amount) async {
    try {
      await capturePaymentIntentCallable.call(
        {
          'paymentIntent': paymentIntent,
          'amount': amount,
        }
      );
    } catch (e) {
      print('Error capturing payment intent: $e');
    }
  }

  static Future<Map<String, dynamic>> cancelPaymentIntent(String paymentIntentId) async {
    try {
      final results = await cancelPaymentIntentCallable.call({'paymentIntentId': paymentIntentId});

      Map<String, dynamic> response = Map<String, dynamic>.from(results.data);
      return response;
    } catch (error) {
      print('Error capturing payment intent: $error');
      rethrow;
    }
  }

  /*
   * This method is used to capture a payment intent. It basically charges the user.
   * @param paymentIntent - the payment intent to be captured
   */
  static Future<Map<String, dynamic>> capturePaymentIntent(String paymentIntentId) async {
    try {
      final results = await capturePaymentIntentCallable.call({'paymentIntentId': paymentIntentId});

      Map<String, dynamic> response = Map<String, dynamic>.from(results.data);
      return response;
    } catch (error) {
      print('Error capturing payment intent: $error');
      rethrow;
    }
  }

  /*
   * This method is used to create a payment intent. It basically declares the intention
   * to make a payment and returns the payment intent (sort of).
   * @param amount - the amount to be paid
   * @param currency - the currency code for the payment
   * @return Future<String> - a future that resolves to the payment intent
   */
  static Future<Map<String, dynamic>> createPaymentIntent(int amount, String currency) async {
    try {
      final HttpsCallableResult result = await createPaymentIntentCallable.call(
        {
          'amount': amount,
          'currency': currency,
        }
      );
      return {'success': result.data['success'], 'response': result.data['response']};
    } catch (error) {
      return {'success': false, 'response': error};
    }
  }

  /*
   * This method is used to confirm a payment intent and basically attach a payment method to it.
   * @param clientSecret - the client secret of the payment intent
   */
  static Future<Map<String, bool>> confirmPayment(String clientSecret) async {
    try {
      // These are "okay" to be in the code because they are public keys,
      // but they should be stored in a more secure location like .env
      if (kDebugMode) {
        Stripe.publishableKey = "pk_test_Cn8XIP0a25tKPaf80s04Lo1m00dQhI8R0u";
      } else {
        Stripe.publishableKey = "pk_live_2bHAGSfue3vfL7ZKKBUisTjT001a503e1U";
      }
      // Prepare payment method details
      PaymentIntent _ = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret, 
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      // Payment confirmed
      return {'authorized': true};
    } catch (e) {
      print('Error confirming payment: $e');
      return {'authorized': false};
    }
  }

  

  /*
   * This method is used to show the payment sheet to make an intent.
   * I believe how this works is we create a payment intention in Stripe, which is set to manually be captured.
   * Then we show the payment sheet to the user, and when the user confirms, the payment intent is mapped to the payment method.
   * We can later capture the payment intent to actually charge the user.
   * @param label - the label for the payment
   * @param amount - the amount to be paid
   * @param currencyCode - the currency code for the payment
   * @param merchantCountryCode - the merchant country code
   */
  static Future<Map<String, dynamic>> showPaymentSheetToMakeIntent(String label, int amount, String currencyCode, String merchantCountryCode) async {
    Map<String, dynamic> result = await createPaymentIntent(amount, currencyCode);
    Map<String, dynamic> response = Map<String, dynamic>.from(result['response']);
    String clientSecret = response['client_secret'];
    String paymentIntentId = clientSecret.split('_secret_')[0];

    DocumentReference<Map<String, dynamic>> stripeCustomer = FirebaseFirestore.instance
        .collection('stripe_customers')
        .doc(_firebaseUser?.uid);

    var documentSnapshot = await stripeCustomer.get();
    var customerId = documentSnapshot.data()?['customer_id'];

    // Initialize the payment sheets for iOS and Andriod
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        customerId: customerId,
        customFlow: false,
        paymentIntentClientSecret: clientSecret,
        allowsDelayedPaymentMethods: false,
        removeSavedPaymentMethodMessage: 'Remove Payment Method',
        primaryButtonLabel: 'Confirm',
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
      return {
        "authorized": true,
        "paymentIntentId": paymentIntentId,
      };
    } catch (error) {
      return {
        "authorized": false,
        "paymentIntentId": paymentIntentId,
      };
    }
  }

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
    
    // Attach the payment method to the customer in the Stripe API
    HttpsCallableResult<dynamic> response = await attachPaymentMethodToCustomerCallable.call(
      {
        'paymentMethodId': paymentMethodId,
        'customerId': customerId,
      }
    );

    if (!response.data['success']) {
      print('Error attaching payment method to customer: ${response.data['response']}');
      return;
    }
    // Check to see if finger print already exists in users payment methods
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

      // Set the primary payment method to be the most recently added payment method (this is the most recently added payment method)
      setPrimaryPaymentMethod(false, false, true, paymentMethod.id);
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

        // If the payment method is the primary payment method, 
        // set the primary payment method to Apple/Google Pay
        if (primaryPaymentMethodStatic.paymentMethodId == paymentMethodId) {
          setPrimaryPaymentMethod(Platform.isIOS, Platform.isAndroid, false, '');
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
    final results = await getPaymentMethodDetailsCallable.call({'paymentMethodId': paymentMethodId});

    if (!results.data['success']) throw Exception('Error getting payment method details');

    Map<String, dynamic> response = Map<String, dynamic>.from(results.data['response']);
    response['id'] = paymentMethodId;
    return response;
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

  /*
   * Updates the payment methods cache with the new payment methods.
   * Note: Cache is stored using SharedPreferences
   * @param methods - the list of payment methods
   */
  static void setPaymentMethodsCache(List<Map<String, dynamic>?> methods) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('paymentMethods', json.encode(methods));
  }

  /*
   * Retrieves the payment methods from the cache
   * Note: Cache is stored using SharedPreferences
   * @return List<Map<String, dynamic>> - the list of payment methods
   */
  static Future<List<Map<String, dynamic>>> getPaymentMethodsCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cachedPaymentMethods = prefs.getString('paymentMethods') ?? '';
    if (cachedPaymentMethods == '') {
      return [];
    } else {
      // Decode the string to a list of dynamic objects
      List<dynamic> decodedList = json.decode(cachedPaymentMethods);
      // Convert each dynamic object to Map<String, dynamic>
      List<Map<String, dynamic>> paymentMethods = decodedList.map<Map<String, dynamic>>((dynamic item) {
        return Map<String, dynamic>.from(item);
      }).toList();
      return paymentMethods;
    }
  }
  

}

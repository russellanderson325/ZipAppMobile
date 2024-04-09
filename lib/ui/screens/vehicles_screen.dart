import "package:flutter/material.dart";
import "package:zipapp/business/ride.dart";
import "package:zipapp/business/user.dart";
import "package:zipapp/constants/tailwind_colors.dart";
import "package:zipapp/constants/zip_colors.dart";
import "package:zipapp/constants/zip_design.dart";
import "package:zipapp/models/user.dart";
import "package:zipapp/services/payment.dart";
import "package:zipapp/ui/screens/payment_methods_selection_screen.dart";
import "package:zipapp/ui/screens/vehicle_ride_status_confirmation_screen.dart";
import "package:zipapp/ui/widgets/message_overlay.dart";
import 'package:zipapp/utils.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VehiclesScreen extends StatefulWidget {
  final double distanceInMeters; // Distance from user to destination in meters
  final double lat; // Latitude of the destination
  final double long; // Longitude of the destination
  final Function resetMap;
  const VehiclesScreen({super.key, required this.distanceInMeters, required this.lat, required this.long, required this.resetMap});

  @override
  VehiclesScreenState createState() => VehiclesScreenState();
}

class VehiclesScreenState extends State<VehiclesScreen> {
  // UniqueKey uniqueKey = UniqueKey();
  int refreshCounter = 0;
  String label = "X Golf Cart";
  String model = "X";
  bool zipXL = false;
  double price = -1;
  String currencyCode = "USD";
  String merchantCountryCode = "US";
  double distanceInMiles = 0.0;
  DateTime lastAppleGooglePayButtonPress = DateTime(0);
  late Future<Map<String, dynamic>?> _paymentMethodDetailsFuture;
  Map<String, dynamic>? primaryPaymentMethodDetails;
  Function? reset;
  bool requestMade = false;
  RideService rideService = RideService();
  UserService userService = UserService();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initializeAsyncData());

    _paymentMethodDetailsFuture = Payment.getPrimaryPaymentMethodDetails();
  }


  Future<void> _initializeAsyncData() async {
  try {
    await setCartValues(label, model, zipXL);

    setState(() {
      loading = false;
    });
  } catch (error) {
    print("Error initializing data: $error");
    setState(() {
      loading = false;
    });
  }
}


  @override
  void dispose() {
    if (!requestMade) {
      Future.microtask(() => widget.resetMap());
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      print("Loading...");
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          title: const Text("Cart Request"),
        ),
        backgroundColor: Colors.white,
        body: Container(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // List of cart sizes
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          clipBehavior: Clip.none,
                          onPressed: () {
                            setCartValues("X Golf Cart", "X", false);
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                            backgroundColor: MaterialStateProperty.all(model == 'X' ? ZipColors.primaryBackground : Colors.white),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                            side: MaterialStateProperty.all(BorderSide(color: model == 'X' ? ZipColors.boxBorder : TailwindColors.gray500)),
                            fixedSize: MaterialStateProperty.all(const Size(160, 80)),
                          ),
                          child: const Image(
                            image: ResizeImage(
                              AssetImage("assets/XCart.png"),
                              height: 100,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setCartValues("XL Golf Cart", "XL", true);
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                            backgroundColor: MaterialStateProperty.all(model == 'XL' ? ZipColors.primaryBackground : Colors.white),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                            side: MaterialStateProperty.all(BorderSide(color: model == 'XL' ? ZipColors.boxBorder : Colors.grey)),
                            fixedSize: MaterialStateProperty.all(const Size(160, 80)),
                          ),
                          child: const Image(
                            image: ResizeImage(
                              AssetImage("assets/XLCart.png"),
                              height: 100,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Size: $model",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Trip Length: ${distanceInMiles.toStringAsFixed(2)} miles",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "\$${price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                ),
              ),

              const SizedBox(height: 8),
              const Text("Primary Payment Method"),
              const SizedBox(height: 8),
              FutureBuilder<Map<String, dynamic>?>(
                key: ValueKey<int>(refreshCounter),
                future: _paymentMethodDetailsFuture,
                builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    primaryPaymentMethodDetails = snapshot.data!;
                      
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      alignment: Alignment.centerLeft,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: TailwindColors.gray500),
                          bottom: BorderSide(color: TailwindColors.gray500),
                          left: BorderSide(color: TailwindColors.gray500),
                          right: BorderSide(color: TailwindColors.gray500),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Row(children: <Widget>[
                        // Expanded to ensure the button stretches to fill the row
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentMethodsSelectionScreen(
                                    refreshKey: refreshKey,
                                  )),
                              );
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                              foregroundColor: MaterialStateProperty.all(Colors.black),
                              textStyle: MaterialStateProperty.all(ZipDesign.labelText),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween, // Space between items
                              children: <Widget>[
                                // Row for the credit card icon and the text
                                Row(
                                  children: <Widget>[
                                    ( primaryPaymentMethodDetails?['brand'] == 'Apple Pay' ? const Image(image: AssetImage('assets/apple_pay_icon.png'), height: 18)
                                    : primaryPaymentMethodDetails?['brand'] == 'Google Pay' ? const Image(image: AssetImage('assets/google_pay_icon.png'), height: 18)
                                    : const Icon(LucideIcons.creditCard, size: 24, color: Colors.black)),
                                    const SizedBox(width: 8), // Space between icon and text
                                    Text('${capitalizeFirstLetter(primaryPaymentMethodDetails?['brand'])} ${(primaryPaymentMethodDetails?['last4'] ?? '') != "" ? "••••${primaryPaymentMethodDetails?['last4']}" : ""}'),
                                  ],
                                ),
                                // Chevron-right icon on the right side
                                const Icon(LucideIcons.chevronRight,
                                    size: 24, color: TailwindColors.gray500),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    );
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show loading state while waiting for the future to complete
                    return Container(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        height: 35,
                        width: 35,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        )
                      )
                    );
                  } else {
                    // Handle the null case or error state
                    return const Text('No payment method available.');
                  }
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  // Open a new screen to display the request status
                  requestMade = true;
                  if (primaryPaymentMethodDetails?['id'] == "apple_pay" || primaryPaymentMethodDetails?['id'] == "google_pay") {
                    await Payment.showPaymentSheetToMakeIntent(
                      label, 
                      (price * 100).toInt(), 
                      currencyCode, 
                      merchantCountryCode
                      ).then((result) async {
                        print("Showing payment sheet");
                        if (result['authorized']) {
                          if (mounted) MessageOverlay.happyMessage(context, "Payment intent successfully authorized. Please wait for a driver to accept the ride.");
                          Navigator.pop(context);
                          VehicleRideStatusConfirmationScreenState.showVehicleRequestAwaitingConfirmationScreen(context, rideService, widget.resetMap);
                          // Send the request to the nearest driver, and so on...
                          await rideService.startRide(widget.lat, widget.long, price, model);
                        } else {
                          // Cancel the ride
                          print(result['error']);
                          if (mounted) MessageOverlay.angryMessage(context, "Payment intent unable to authorize, please check your payment method and try again.");
                          rideService.cancelRide();
                        }
                      });
                  } else {
                      Payment.createPaymentIntent((price * 100).toInt(), currencyCode).then((result) {
                      Map<String, dynamic> response = Map<String, dynamic>.from(result['response']);
                      String clientSecret = response['client_secret'];                
                      Payment.confirmPayment(clientSecret).then((result) async {
                        if (result['authorized'] as bool) {
                          if (mounted) MessageOverlay.happyMessage(context, "Payment intent successfully authorized. Please wait for a driver to accept the ride.");
                          Navigator.pop(context);
                          print("Showing vehicle request awaiting confirmation screen");
                          VehicleRideStatusConfirmationScreenState.showVehicleRequestAwaitingConfirmationScreen(context, rideService, widget.resetMap);
                          // Send the request to the nearest driver, and so on...
                          await rideService.startRide(widget.lat, widget.long, price, model);

                          Map<String, dynamic> paymentDetails = {
                            "paymentMethod": primaryPaymentMethodDetails?['id'],
                            "amount": price,
                          };

                          print(primaryPaymentMethodDetails);
                          Payment.addPaymentDetailsToFirebase(paymentDetails, primaryPaymentMethodDetails?['last4']);
                          // Below is the code to capture the payment intent
                          // String paymentIntentId = clientSecret.split('_secret_')[0];
                          // Payment.capturePaymentIntent(paymentIntentId).then((result) {
                          //   print(result);
                          // }).catchError((error) {
                          //   ride?.cancelRide();
                          //   dispose();
                          // });
                        } else {
                          if (mounted) MessageOverlay.angryMessage(context, "Payment intent unable to authorize, please check your payment method and try again.");
                          rideService.cancelRide();
                        }
                      }).catchError((error) {
                        if (mounted) MessageOverlay.angryMessage(context, "Payment intent unable to authorize, please check your payment method and try again.");
                        rideService.cancelRide();
                        print(error.toString());
                      });
                    });
                  }
                  // Navigator.pop(context);
                },
                style: ZipDesign.yellowButtonStyle,
                child: const Text('Request Pickup'),
              ),
            ],
          ),
        )
      );
    }
  }

  // Refreshes the key to force the widget to rebuild
  void refreshKey() {
    setState(() {
      refreshCounter++;
      _paymentMethodDetailsFuture = Payment.getPrimaryPaymentMethodDetails();
    });
  }

  /*
   * Show the VehiclesScreen as a bottom sheet
   * @param context The context
   * @param distanceInMeters The distance from the user to the destination in meters
   * @return void
   */
  static void showVehiclesScreen(BuildContext context, double distanceInMeters, double lat, double long, Function resetMap) {
    // Show the bottom sheet
    showModalBottomSheet(
      clipBehavior: Clip.hardEdge,
      barrierColor: Colors.transparent,
      context: context,
      isScrollControlled: true, // Set to true if your content might not fit
      shape: const RoundedRectangleBorder( // Optional: to style the top corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        side: BorderSide(color: ZipColors.boxBorder, width: 1.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.5, // Adjust the height factor as needed, e.g., 0.9 for 90% of screen height
          child: VehiclesScreen(distanceInMeters: distanceInMeters, lat: lat, long: long, resetMap: resetMap),
        );
      },
    );
  }

  /*
   * Set the cart values
   * @param label The label of the cart
   * @param size The size of the cart
   * @param zipXL Whether the cart is a ZipXL
   * @return void
   */
  Future<void> setCartValues(String label, String size, bool zipXL) async {
    distanceInMiles = widget.distanceInMeters / 1609.34;
    double amount = await Payment.getAmount(zipXL, distanceInMiles, 1); // Assuming this is async
    // Round to 2 decimal places
    amount = double.parse((amount).toStringAsFixed(2));
    if (mounted) {
      setState(() {
        this.label = label;
        model = size;
        price = amount;
      });
    }
  }

}
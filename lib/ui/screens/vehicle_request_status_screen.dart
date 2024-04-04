import "package:flutter/material.dart";
import "package:zipapp/business/ride.dart";
import "package:zipapp/constants/zip_colors.dart";
import "package:zipapp/business/ride.dart";
import "package:zipapp/services/payment.dart";

class VehicleRequestStatusScreen extends StatefulWidget {
  final double lat;
  final double long;
  final String label;
  final double price;
  final String currencyCode;
  final String merchantCountryCode;
  final Map<String, dynamic>? primaryPaymentMethod;
  final Function resetMap;

  const VehicleRequestStatusScreen({
    Key? key, 
    required this.lat, 
    required this.long, 
    required this.label, 
    required this.price, 
    required this.currencyCode, 
    required this.merchantCountryCode, 
    required this.primaryPaymentMethod,
    required this.resetMap,
  }) : super(key: key);

  @override
  State<VehicleRequestStatusScreen> createState() => VehicleRequestStatusScreenState();
}

class VehicleRequestStatusScreenState extends State<VehicleRequestStatusScreen> {
  static double incrementKey = 0;
  static String rideStatus = "";
  static String statusMessage = "";
  static RideService? ride;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    // Proceed to request confirmation
    ride = RideService();
    _isMounted = true; 

    /* 
     * Start the ride.
     * Note that this sends a request out to the nearest driver and waits for
     * the driver to accept the request. The status of the ride is updated
     * via the statusUpdate callback.
    */
    ride?.startRide(widget.lat, widget.long, statusUpdate, widget.price);
  }

  @override
  void dispose() {
    _isMounted = false; // Set to false when the widget is about to be disposed
    ride?.cancelRide(); // Still unsure if this is correct -Jordyn (4/1/24)
    Future.microtask(() => widget.resetMap());
    print("Ride cancelled");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: ListView(
          children: <Widget>[
            Center(
              child: Text(statusMessage),
            ),
          ],
        ),
      )
    );
  }

  /*
   * Update the status of the ride
   * @param status The status of the ride
   * @return void
   */
  void statusUpdate(String status) {
    if (_isMounted) { // Check if the widget is still mounted
      setState(() {
        rideStatus = status;
        incrementKey++;

        switch (status) {
          case "SEARCHING":
            print("Searching");
            statusMessage = "Searching for a driver...";
            break;
          case "WAITING":
            print("Waiting");
            statusMessage = "Waiting for driver to accept...";
            break;
          case "IN_PROGRESS":
            print("In Progress");
            statusMessage = "Driver connected and en route...";
            // If the payment method is apple/google pay, then prompt the user to pay
            // If the user declines to pay, then cancel the ride
            // If the payment times out, then cancel the ride
            // If the user uses a card, then charge the card
            // If the payment fails, then cancel the ride
            // If the payment is successful, then the ride is not canceled and the driver will come to pick up the user
            if (widget.primaryPaymentMethod?['id'] == "apple_pay" || widget.primaryPaymentMethod?['id'] == "google_pay") {
              Payment.showPaymentSheetToMakeIntent(
                widget.label, 
                (widget.price * 100).toInt(), 
                widget.currencyCode, 
                widget.merchantCountryCode
                ).then((result) {
                  if (result['authorized']) {
                    print('Authorization successful, ride will not be cancelled');
                    print('Payment intent ID: ${result['paymentIntentId']}');
                    Payment.capturePaymentIntent(result['paymentIntentId']);
                  } else {
                    // Cancel the ride
                    print('Authorization failed, canceling ride');
                    ride?.cancelRide();
                    dispose();
                  }
                });
            } else {
              // Charge the card
              // If the payment fails, then cancel the ride
              // If the payment is successful, then the ride is not canceled and the driver will come to pick up the user
            }
              
            
            break;
          case "ENDED":
            print("Ended");
            statusMessage = "Ride has ended";
            widget.resetMap();
            break;
          case "CANCELLED":
            print("Cancelled");
            statusMessage = "Ride has been cancelled";
            widget.resetMap();
            break;
        }
      });
    }
  }
  

  /*
   * Show the VehicleRequestAwaitingConfirmationScreenState as a bottom sheet
   * @param context The context
   * @return void
   */
  static void showVehicleRequestAwaitingConfirmationScreen(
      BuildContext context, 
      double lat, 
      double long,
      String label,
      double price, 
      String currencyCode, 
      String merchantCountryCode, 
      Map<String, dynamic>? primaryPaymentMethod,
      Function resetMap,
    ) {
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
          heightFactor: 0.5,
          child: VehicleRequestStatusScreen(
            lat: lat, 
            long: long, 
            label: label, 
            price: price, 
            currencyCode: currencyCode, 
            merchantCountryCode: merchantCountryCode, 
            primaryPaymentMethod: primaryPaymentMethod,
            resetMap: resetMap,
          ),
        );
      },
    );
  }
}
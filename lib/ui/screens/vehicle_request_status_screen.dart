import "package:flutter/material.dart";
import "package:lucide_icons/lucide_icons.dart";
import "package:zipapp/business/ride.dart";
import "package:zipapp/constants/zip_colors.dart";
import "package:zipapp/business/ride.dart";
import "package:zipapp/constants/zip_design.dart";
import "package:zipapp/services/payment.dart";
import "package:zipapp/ui/widgets/message_overlay.dart";

class VehicleRequestStatusScreen extends StatefulWidget {
  final double lat;
  final double long;
  final String label;
  final double price;
  final String model;
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
    required this.model,
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
    statusMessage = "";

    if (widget.primaryPaymentMethod?['id'] == "apple_pay" || widget.primaryPaymentMethod?['id'] == "google_pay") {
      Payment.showPaymentSheetToMakeIntent(
        widget.label, 
        (widget.price * 100).toInt(), 
        widget.currencyCode, 
        widget.merchantCountryCode
        ).then((result) {
          if (result['authorized']) {
            if (mounted) MessageOverlay.happyMessage(context, "Payment intent successfully authorized. Please wait for a driver to accept the ride.");
            // Send the request to the nearest driver, and so on...
            ride?.startRide(widget.lat, widget.long, statusUpdate, widget.price, widget.model);

            // Below is the code to capture the payment intent
            // Payment.capturePaymentIntent(result['paymentIntentId']).then((result) {
            //   if (result['success']) {
            //   } else {
            //     ride?.cancelRide();
            //     dispose();
            //   }
            // });
          } else {
            // Cancel the ride
            if (mounted) MessageOverlay.angryMessage(context, "Payment intent unable to authorize, please check your payment method and try again.");
            ride?.cancelRide();
            Navigator.pop(context);
          }
        });
    } else {
        Payment.createPaymentIntent((widget.price * 100).toInt(), widget.currencyCode).then((result) {
        Map<String, dynamic> response = Map<String, dynamic>.from(result['response']);
        String clientSecret = response['client_secret'];                
        Payment.confirmPayment(clientSecret).then((result) {
          if (result['authorized'] as bool) {
          if (mounted) MessageOverlay.happyMessage(context, "Payment intent successfully authorized. Please wait for a driver to accept the ride.");
            // Send the request to the nearest driver, and so on...
            ride?.startRide(widget.lat, widget.long, statusUpdate, widget.price, widget.model);

            Map<String, dynamic> paymentDetails = {
              "paymentMethod": widget.primaryPaymentMethod?['id'],
              "amount": widget.price,
            };

            print(widget.primaryPaymentMethod);
            Payment.addPaymentDetailsToFirebase(paymentDetails, widget.primaryPaymentMethod?['last4']);
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
            ride?.cancelRide();
            Navigator.pop(context);
          }
        }).catchError((error) {
          if (mounted) MessageOverlay.angryMessage(context, "Payment intent unable to authorize, please check your payment method and try again.");
          ride?.cancelRide();
          Navigator.pop(context);
        });
      });
    }
  }

  @override
  void dispose() {
    _isMounted = false; // Set to false when the widget is about to be disposed
    // ride?.cancelRide(); // Still unsure if this is correct -Jordyn (4/1/24)
    Future.microtask(() => widget.resetMap());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Information"),
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: ListView(
          children: <Widget>[
            Center(
              child: Text(statusMessage),
            ),
            const SizedBox(height: 250),
            TextButton.icon(
              onPressed: () async {
                ride?.cancelRide();
                Navigator.pop(context);
              },
              icon: const Icon(LucideIcons.trash),
              style: ZipDesign.redButtonStyle,
              label: const Text('Cancel ride')
            ),
            const SizedBox(height: 5),
            const Center(
              child: Text(
              "If the ride is cancelled, no charge will be made",
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
            )
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
            break;
          case "ENDED":
            print("Ended");
            statusMessage = "Ride has ended, thank you for riding with us. Your payment has been processed.";
            widget.resetMap();
            break;
          case "CANCELLED":
            print("Cancelled");
            statusMessage = "Ride has been cancelled, no charge will be made.";
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
      String model,
      String currencyCode, 
      String merchantCountryCode, 
      Map<String, dynamic>? primaryPaymentMethod,
      Function resetMap,
    ) {
    // Show the bottom sheet
    showModalBottomSheet(
      clipBehavior: Clip.hardEdge,
      barrierColor: const Color.fromARGB(60, 0, 0, 0),
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
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
            model: model,
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
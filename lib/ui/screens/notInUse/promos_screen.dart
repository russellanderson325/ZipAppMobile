import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:zipapp/business/user.dart';
// import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:zipapp/models/user.dart';
// import 'package:zipapp/ui/widgets/custom_alert_dialog.dart';

class PromosScreen extends StatefulWidget {
  const PromosScreen({super.key});

  @override
  State<PromosScreen> createState() => _PromosScreenState();
}

class _PromosScreenState extends State<PromosScreen> {
  late VoidCallback onBackPress;
  UserService userService = UserService();
  // bool _isInAsyncCall = false;

  final HttpsCallable applyPromoFunction =
      FirebaseFunctions.instance.httpsCallable(
    'applyPromoCode',
  );

  final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
    'repeat',
  );

  @override
  void initState() {
    super.initState();
    onBackPress = () {
      Navigator.of(context).pop();
    };
  }

/*
  Allows customers to apply promotion codes.
  Uses Firebase Cloud Function to do computation.
*/
  // void _applyCode() async {
  //   setState(() {
  //     _isInAsyncCall = true;
  //   });
  //   try {
  //     HttpsCallableResult result = await applyPromoFunction
  //         .call(<String, dynamic>{
  //       'uid': userService.userID,
  //       'promo_code': _promoController.text
  //     });
  //     if (result.data['result'] == true) {
  //       _showAlert(
  //         title: "Success!",
  //         content: result.data['message'],
  //         onPressed: () {},
  //       );
  //     } else {
  //       _showAlert(
  //         title: "Error",
  //         content: result.data['message'],
  //         onPressed: () {},
  //       );
  //     }
  //   } catch (e) {
  //     print('An error has occured: $e');
  //   }
  //   setState(() {
  //     _isInAsyncCall = false;
  //   });
  // }

/*
  Main build function.
  Displays Customer promotion credit information.
  If a user has entered a promotion, UI will show loading screen
  while waiting for result.
*/
  // @override
  // Widget build(BuildContext context) {
  //   return ModalProgressHUD(
  //     inAsyncCall: _isInAsyncCall,
  //     progressIndicator: const CircularProgressIndicator(),
  //     opacity: 0.5,
  //     child: Scaffold(
  //       backgroundColor: Colors.black,
  //       body: ListView(
  //         children: <Widget>[
  //           Align(
  //             alignment: Alignment.topLeft,
  //             child: SafeArea(
  //               child: IconButton(
  //                 icon: const Icon(Icons.arrow_back, color: Colors.white),
  //                 onPressed: onBackPress,
  //               ),
  //             ),
  //           ),
  //           Center(
  //             child: Padding(
  //                 padding: EdgeInsets.only(
  //                     top: MediaQuery.of(context).size.height / 10),
  //                 child: _promos),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.only(
  //                 top: MediaQuery.of(context).size.height / 6,
  //                 right: MediaQuery.of(context).size.width / 4,
  //                 left: MediaQuery.of(context).size.width / 4),
  //             child: _fireIcon,
  //           ),
  //           Padding(
  //             padding: EdgeInsets.only(
  //                 top: 45.0,
  //                 right: MediaQuery.of(context).size.width / 6,
  //                 left: MediaQuery.of(context).size.width / 6),
  //             child: Container(
  //               decoration: ShapeDecoration(
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12.0),
  //                     side: const BorderSide(color: Colors.white)),
  //               ),
  //               height: MediaQuery.of(context).size.height / 17,
  //               child: _enterPromo,
  //             ),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.only(
  //                 top: 10.0,
  //                 right: MediaQuery.of(context).size.width / 4,
  //                 left: MediaQuery.of(context).size.width / 4),
  //             child: TextButton(
  //               onPressed: _applyCode,
  //               style: TextButton.styleFrom(
  //                   shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12.0)),
  //                   primary: Colors.white),
  //               child: const Text(
  //                 "Apply",
  //                 softWrap: true,
  //                 style: TextStyle(
  //                   color: ZipColors.zipYellow,
  //                   fontSize: 18.0,
  //                   fontWeight: FontWeight.w400,
  //                   fontFamily: "Bebas",
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Center(
  //             child: Padding(
  //                 padding: const EdgeInsets.only(top: 100.0),
  //                 child: _creditText),
  //           ),
  //           //progress bar attempt
  //           Padding(
  //               padding: EdgeInsets.only(
  //                   top: 10.0,
  //                   right: MediaQuery.of(context).size.width / 12,
  //                   left: MediaQuery.of(context).size.width / 12),
  //               child: buildProgressBar(context)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // final Text _promos = const Text(
  //   "Promos",
  //   softWrap: true,
  //   style: TextStyle(
  //     color: Color.fromRGBO(255, 242, 0, 1.0),
  //     fontSize: 42.0,
  //     fontWeight: FontWeight.w600,
  //     fontFamily: "Bebas",
  //   ),
  // );

  // final Icon _fireIcon = const Icon(CustomIcons.fire,
  //     size: 110.0, color: Color.fromRGBO(255, 242, 0, 1.0));

  // static final TextEditingController _promoController =
  //     new TextEditingController();
  // final TextField _enterPromo = TextField(
  //   controller: _promoController,
  //   textAlign: TextAlign.center,
  //   style: const TextStyle(
  //     color: Color.fromRGBO(255, 242, 0, 1.0),
  //     fontSize: 20.0,
  //     fontFamily: "Poppins",
  //     fontWeight: FontWeight.w300,
  //     decoration: TextDecoration.none,
  //   ),
  //   decoration: const InputDecoration(
  //     hintStyle: TextStyle(
  //       color: Color.fromRGBO(255, 242, 0, 1.0),
  //       fontSize: 20.0,
  //       fontFamily: "Poppins",
  //       fontWeight: FontWeight.w300,
  //       decoration: TextDecoration.none,
  //     ),
  //     hintText: "Promo Code",
  //     border: InputBorder.none,
  //   ),
  // );

  // final Text _creditText = const Text(
  //   "Credits",
  //   softWrap: true,
  //   style: TextStyle(
  //     color: Color.fromRGBO(255, 242, 0, 1.0),
  //     fontSize: 14.0,
  //     fontWeight: FontWeight.w400,
  //     fontFamily: "Bebas",
  //   ),
  // );

/*
  Builds Progress indicatior.
  Let's users know how many credits they currently have.
*/
  Widget buildProgressBar(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userService.userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User user = User.fromDocument(snapshot.data!);
            return LinearPercentIndicator(
              width: MediaQuery.of(context).size.width / 1.2,
              animation: false,
              lineHeight: 20.0,
              percent: (user.credits / 200),
              progressColor: const Color.fromRGBO(255, 242, 0, 1.0),
              backgroundColor: Colors.white,
              center: Text('${user.credits.toInt()}/200'),
            );
          } else {
            return const DrawerHeader(child: Column());
          }
        });
  }

  // void _showAlert(
  //     {required String title,
  //     required String content,
  //     required VoidCallback onPressed}) {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (context) {
  //       return CustomAlertDialog(
  //         content: content,
  //         title: title,
  //         onPressed: onPressed,
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

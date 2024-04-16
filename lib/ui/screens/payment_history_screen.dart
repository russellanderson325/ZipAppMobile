import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
// import 'package:stripe_payment/stripe_payment.dart';
import 'package:zipapp/business/payment.dart';
import 'package:flutter/material.dart';
import 'package:strings/strings.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  // final Payment payment;
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  var customerData = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final paymentService = Payment();
  final firebaseUser = auth.FirebaseAuth.instance.currentUser;
  //var paymentMethodList;
  @override
  initState() {
    super.initState();
    // StripePayment.setOptions(StripeOptions(
    //     publishableKey: "pk_test_Cn8XIP0a25tKPaf80s04Lo1m00dQhI8R0u"));
    //   paymentMethodList = [];
    paymentService.getPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[800],
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'History',
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: paymentService.getPaymentHistory(),
        builder: (context, snapshot) {
          /* Timer(Duration(seconds: 2), () {
                  print("Yeah, this line is printed after 2 seconds");
                });*/
          try {
            if (snapshot.hasData) {
              debugPrint("build widget: ${snapshot.data}");
              List<QueryDocumentSnapshot> paymentList = snapshot.data!.docs;
              List successfulPaymentsList = [];
              print("payment list: $paymentList");
              print("id of payment list[1]: ${paymentList[1].id}");
              for (var element in paymentList) {
                if (element["status"] == "succeeded") {
                  print("payment list element data: ${element.data()}");
                  successfulPaymentsList.add(element);
                  print(
                      "length of successful payments list: ${successfulPaymentsList.length}");
                  print("length of payment list: ${paymentList.length}");
                  //print("TEST: TSTET: TEST ${element["refund"]}");
                }
              }
              print("OK: ${successfulPaymentsList.length}");
              return ListView.builder(
                  itemCount: successfulPaymentsList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.place),
                            title: const Text("LOCATION"),
                            subtitle: Text((successfulPaymentsList[index]
                                            ["charges"]["data"][0]
                                        ["payment_method_details"]["card"]
                                    ["brand"]) +
                                " ****${successfulPaymentsList[index]["charges"]["data"][0]["payment_method_details"]["card"]["last4"]}"
                                    .toCapitalised()),
                            trailing: Text(
                                "Amount: \$${(successfulPaymentsList[index]["amount_received"] / 100).toStringAsFixed(2)} "),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                child: const Text('REQUEST REFUND',
                                    style: TextStyle(color: Colors.blue)),
                                //color: Colors.blue,
                                onPressed: () async {
                                  bool checkRefundStatus =
                                      await paymentService.getRefundStatus(
                                          successfulPaymentsList[index].id);
                                  if (checkRefundStatus) {
                                    _showRefundAlreadyInProgress();
                                  } else {
                                    await _showRefundAlertDialog(
                                        successfulPaymentsList[index].id);
                                  }
                                  // Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            } else {
              // We can show the loading view until the data comes back.
              debugPrint('TEST: TEROERERbuild loading widget');
              //print("No previous trips ");
              return const CircularProgressIndicator();
            }
          } catch (error) {
            //print("ERROR: afsdfas $error");
            //return ("No previous trips Found");
            return text(context);
          }
        },
      ),
    );
  }

  Widget text(BuildContext context) {
    //print ("No previous trips found");
    return const Center(child: Text("No previous trips found"));
  }

  _showRefundAlreadyInProgress() async {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
                "Your Refund Request has already been received! An email will be sent to ${firebaseUser?.email} once approved!"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> _showRefundAlertDialog(docID) async {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Request Refund?"),
          content: const Text("Are you sure?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("Yes"),
              onPressed: () async {
                try {
                  Navigator.of(context).pop();
                  //buildShowDialog(context);
                  await paymentService.sendRefundRequest(docID);
                  //Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title:
                            const Text('Your refund request has been received'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: const Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              //Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } catch (error) {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text('Error Occured'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: const Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            CupertinoDialogAction(
              child: const Text("No",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    //backgroundColor: Colors.black,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

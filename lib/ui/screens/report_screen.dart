import "package:flutter/material.dart";  
import "package:flutter/material.dart"; 
import 'package:zipapp/business/auth.dart'; 
import 'package:flutter/services.dart';  
import 'package:mailto/mailto.dart';  
   import 'package:url_launcher/url_launcher_string.dart';
import 'package:zipapp/constants/zip_colors.dart'; 
    // import 'package:geoflutterfire/geoflutterfire.dart';  


class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late VoidCallback onBackPress;

  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBackPress,
        ),
        title: Text(
          "Report an Issue",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "If you had an issue with your ride today and would like a refund, please contact info@zipgameday.com",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 20), // Added spacing
            ElevatedButton(
              onPressed: () {
                showReportDialog(context);
              },
              child: Text(
                'Email ZipApp',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showReportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Contact ZipApp"),
        content: Text("For a faster response, please email: info@zipgameday.com"),
        actions: <Widget>[
          TextButton(
            child: Text("Email Support"),
            onPressed: () async {
              final mailtoLink = Mailto(
                to: ['info@zipgameday.com'],
              );
              await launchUrlString('$mailtoLink');
            },
          ),
        ],
      );
    },
  );
}
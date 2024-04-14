
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zipapp/ui/widgets/driver_bank_account.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'driver_earnings_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DriverIncomeScreen extends StatefulWidget {
  const DriverIncomeScreen({super.key});

  @override
  State<DriverIncomeScreen> createState() => _DriverIncomeScreenState();

}

class _DriverIncomeScreenState extends State<DriverIncomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double totalEarnings = 0.0;


  @override
  void initState() {
    super.initState();
    loadDriverEarnings();
  }

  Future<void> loadDriverEarnings() async {
    // Replace with actual driver ID mechanism
    String driverId = "your_driver_id";

    try {
      DocumentSnapshot driverDoc = await _firestore.collection('drivers').doc(
          driverId).get();
      if (driverDoc.exists) {
        setState(() {
          totalEarnings = driverDoc.get('totalEarnings') ?? 0.0;
        });
      }
    } catch (e) {
      print("Error fetching driver earnings: $e");
    }
  }

  Future<void> updateDriverEarnings(double earnings) async {
    // Replace with actual driver ID
    String driverId = "your_driver_id";

    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'totalEarnings': earnings,
      });
      print("Earnings updated successfully.");
    } catch (e) {
      print("Error updating earnings: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = TextStyle(
      color: Colors.grey,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final TextStyle valueStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
    );

    final TextStyle detailStyle = TextStyle(
      color: Colors.grey,
      fontSize: 14,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Earnings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 16),
            _buildInfoSection(
              'April 1 - April 7',
              label: '\$${totalEarnings.toStringAsFixed(2)}',
              titleStyle: titleStyle,
              valueStyle: TextStyle(color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              showDetailButton: true,

            ),
            const Divider(),
            _buildInfoSection(
          '',
          label: 'Online',
          // Label on the left
          value: '10 h 23m',

          titleStyle: TextStyle(color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold),
              valueStyle: valueStyle,
              rightAlignedValueStyle: TextStyle(color: Colors.grey, fontSize: 16,
             ),

            isValueRightAligned: true,
            ),



            const Divider(),
            _buildInfoSection(
              '',
              label: 'Trips Completed',
              value: '25',

              titleStyle: TextStyle(color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              valueStyle: valueStyle,
              rightAlignedValueStyle: TextStyle(color: Colors.grey, fontSize: 16,
                ),

              isValueRightAligned: true,
            ),
            const Divider(),
            _buildInfoSection(
              '',
              label: 'Average Tip',
              value: '\$3.40',

              titleStyle: TextStyle(color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              valueStyle: valueStyle,
              rightAlignedValueStyle: TextStyle(color: Colors.grey, fontSize: 16,
               ),

              isValueRightAligned: true,
            ),

            const Divider(),

            _buildInfoSection(
              'Payment',
              label: '\nAccount Balance',
              // Label on the left
              value: '\n\$${totalEarnings.toStringAsFixed(2)}',

              titleStyle: TextStyle(color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              valueStyle: valueStyle,
              rightAlignedValueStyle: TextStyle(
                color: Colors.grey,
                fontSize: 16,

              ),
              detailText: 'Payment scheduled for April 7',
              detailTextStyle: detailStyle,
              isValueRightAligned: true,
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, {
    String label = '',
    String value = '',
    bool showDetailButton = false,
    String detailText = '',
    TextStyle? detailTextStyle,
    required TextStyle titleStyle,
    required TextStyle valueStyle,
    TextStyle? rightAlignedValueStyle,
    bool isValueRightAligned = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: valueStyle),
              Expanded(
                child: Text(
                  value,
                  style: isValueRightAligned ? (rightAlignedValueStyle ??
                      valueStyle) : valueStyle,
                  textAlign: isValueRightAligned ? TextAlign.right : TextAlign
                      .left,
                ),
              ),
              if (showDetailButton)
                ElevatedButton(
                  onPressed: () async {
                    final updatedTotalEarnings = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EarningsDetailsScreen(
                              totalEarnings: totalEarnings,
                            ),
                      ),
                    );

                    if (updatedTotalEarnings != null) {
                      setState(() {
                        totalEarnings =
                        updatedTotalEarnings as double;
                      });
                      //  update earnings in Firestore here
                    }
                  },
                  child: const Text('See details'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, // Text color
                    backgroundColor: ZipColors.zipYellow, // Background color
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (detailText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(detailText, style: detailTextStyle ?? valueStyle),
            ),
        ],
      ),
    );
  }
}

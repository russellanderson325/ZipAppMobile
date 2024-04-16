import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:zipapp/constants/zip_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EarningsDetailsScreen extends StatefulWidget {
  final double totalEarnings;
  const EarningsDetailsScreen({super.key, required this.totalEarnings});

  @override
  EarningsDetailsScreenState createState() => EarningsDetailsScreenState();
}

class EarningsDetailsScreenState extends State<EarningsDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Real amounts should be Implemented here when the app is ready.
  final List<double> dailyEarnings = [42.4, 36.0, 56.0, 65.0, 31.3, 74.0, 98.8];
  double get maxEarnings => dailyEarnings.reduce(math.max);
  double get totalEarnings => dailyEarnings.reduce((a, b) => a + b);

  // Assume fare is 70% of the earnings and tips are 30%
  double get fare => totalEarnings * 0.7;
  double get tips => totalEarnings * 0.3;

  @override
  void initState() {
    super.initState();
    loadDailyEarnings();
  }

  Future<void> loadDailyEarnings() async {
    // Ideally passed through the constructor or obtained from a user session
    String driverId = "your_driver_id";
    try {
      DocumentSnapshot driverDoc =
          await _firestore.collection('drivers').doc(driverId).get();
      if (driverDoc.exists && driverDoc.data() != null) {
        Map<String, dynamic> data = driverDoc.data() as Map<String, dynamic>;
        if (data.containsKey('earnings')) {
          setState(() {
            // this line should be used when Implementing real data from firestore.
            //   dailyEarnings = List<double>.from(data['earnings']);
          });
        }
      }
    } catch (e) {
      print("Error loading daily earnings: $e");
    }
  }

  void showEarningsDetails(BuildContext context, double earnings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Daily Earnings'),
          content: Text('\$${earnings.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings Details'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(totalEarnings);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      // TODO: Decrease week range
                    },
                  ),
                  Column(
                    children: [
                      const Text(
                        'April 1 - April 7',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(
                        '\$${totalEarnings.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      // TODO: Increase week range
                    },
                  ),
                ],
              ),
            ),
            BarChart(
              dailyEarnings: dailyEarnings,
              maxEarnings: maxEarnings,
            ),
            const Divider(),
            ListTile(
              title: const Text('\nFare', style: TextStyle(fontSize: 18)),
              trailing: Text('\n\$${fare.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            ListTile(
              title: const Text('Tip', style: TextStyle(fontSize: 18)),
              trailing: Text('\$${tips.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            ListTile(
              title:
                  const Text('Earnings Total', style: TextStyle(fontSize: 18)),
              trailing: Text('\$${totalEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class BarChart extends StatefulWidget {
  final List<double> dailyEarnings;
  final double maxEarnings;

  const BarChart({
    super.key,
    required this.dailyEarnings,
    required this.maxEarnings,
  });

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  int? selectedBarIndex;
  double? selectedBarEarnings;

  void selectBar(int index, double earnings) {
    setState(() {
      selectedBarIndex = index;
      selectedBarEarnings = earnings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.dailyEarnings.asMap().entries.map((entry) {
          double barHeight = (entry.value / widget.maxEarnings) * 160;
          bool isSelected = selectedBarIndex == entry.key;
          return Flexible(
            child: GestureDetector(
              onTap: () => selectBar(entry.key, entry.value),
              child: Bar(
                label: labels[entry.key],
                height: barHeight,
                color: isSelected ? Colors.yellowAccent : ZipColors.zipYellow,
                value: isSelected ? entry.value : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Bar extends StatelessWidget {
  final String label;
  final double height;
  final Color color;
  final double? value;

  const Bar({
    super.key,
    required this.label,
    required this.height,
    required this.color,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        value != null
            ? Text(
                '\$${value!.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              )
            : const SizedBox.shrink(),
        Container(
          width: 20,
          height: height,
          color: color,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(label),
        ),
      ],
    );
  }
}

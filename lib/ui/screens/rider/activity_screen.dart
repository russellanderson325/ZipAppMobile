import 'package:flutter/material.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/ride_activity_item.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Ride> rides = [];

  @override
  void initState() {
    super.initState();
    _populateRideActivityData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZipColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: ZipColors.primaryBackground,
        title: const Text(
          'Activity',
          style: ZipDesign.pageTitleText,
        ),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Past',
              textAlign: TextAlign.left,
              style: ZipDesign.sectionTitleText,
            ),
            rides.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: rides.length,
                      itemBuilder: (context, index) {
                        return RideActivityItem(
                          destination: rides[index].destination,
                          dateTime: rides[index].dateTime,
                          price: rides[index].price,
                        );
                      },
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  void _populateRideActivityData() {
    List<Ride> tempRides = [];
    tempRides = [
      Ride(
        destination: 'Jordan Hare Stadium',
        dateTime: DateTime(2024, 10, 12, 14, 30),
        price: 12.23,
      ),
      Ride(
        destination: 'Jordan Hare Stadium',
        dateTime: DateTime(2024, 10, 12, 14, 30),
        price: 12.23,
      ),
      Ride(
        destination: 'Jordan Hare Stadium',
        dateTime: DateTime(2024, 10, 12, 14, 30),
        price: 12.23,
      ),
      Ride(
        destination: 'Jordan Hare Stadium',
        dateTime: DateTime(2024, 10, 12, 14, 30),
        price: 12.23,
      ),
      Ride(
        destination: 'Jordan Hare Stadium',
        dateTime: DateTime(2024, 10, 12, 14, 30),
        price: 12.23,
      ),
      Ride(
        destination: 'Jordan Hare Stadium',
        dateTime: DateTime(2024, 10, 12, 14, 30),
        price: 12.23,
      ),
      Ride(
        destination: 'Jordan Hare Stadium',
        dateTime: DateTime(2024, 10, 12, 14, 30),
        price: 12.23,
      ),
      Ride(
        destination: 'Jordan Hare Stadium',
        dateTime: DateTime(2024, 10, 12, 14, 30),
        price: 12.23,
      ),
      Ride(
        destination: 'Jordan Hare Stadium',
        dateTime: DateTime(2024, 10, 12, 14, 30),
        price: 12.23,
      ),
      Ride(
        destination: 'Jordan Hare Stadium',
        dateTime: DateTime(2024, 10, 12, 14, 30),
        price: 12.23,
      ),
    ];
    setState(() {
      rides = tempRides;
    });
  }
}

class Ride {
  final String destination;
  final DateTime dateTime;
  final double price;
  Ride(
      {required this.destination, required this.dateTime, required this.price});
}

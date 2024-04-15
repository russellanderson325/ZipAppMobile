import 'package:flutter/material.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/screens/driver/driver_activity_item.dart';

class DriverActivityScreen extends StatefulWidget {
  const DriverActivityScreen({super.key});

  @override
  State<DriverActivityScreen> createState() => _DriverActivityScreenState();
}

class _DriverActivityScreenState extends State<DriverActivityScreen> {
  List<Ride> rides = [];
  double averageRating = 0;

  @override
  void initState() {
    super.initState();
    _populateRideActivityData();
  }

  void _populateRideActivityData() {
    List<Ride> tempRides = [];
    //calculate the average rating

    tempRides = [
      Ride(
          destination: 'Jordan Hare Stadium',
          dateTime: DateTime(2024, 10, 12, 14, 30),
          price: 12.23,
          rating: 5.0),
      Ride(
          destination: 'Jordan Hare Stadium',
          dateTime: DateTime(2024, 10, 12, 14, 30),
          price: 12.23,
          rating: 5.0),
      Ride(
          destination: 'Jordan Hare Stadium',
          dateTime: DateTime(2024, 10, 12, 14, 30),
          price: 12.23,
          rating: 5.0),
      Ride(
          destination: 'Jordan Hare Stadium',
          dateTime: DateTime(2024, 10, 12, 14, 30),
          price: 12.23,
          rating: 5.0),
      Ride(
          destination: 'Jordan Hare Stadium',
          dateTime: DateTime(2024, 10, 12, 14, 30),
          price: 12.23,
          rating: 5.0),
      Ride(
          destination: 'Jordan Hare Stadium',
          dateTime: DateTime(2024, 10, 12, 14, 30),
          price: 12.23,
          rating: 5.0),
      Ride(
          destination: 'Jordan Hare Stadium',
          dateTime: DateTime(2024, 10, 12, 14, 30),
          price: 12.23,
          rating: 5.0),
      Ride(
          destination: 'Jordan Hare Stadium',
          dateTime: DateTime(2024, 10, 12, 14, 30),
          price: 12.23,
          rating: 5.0),
      Ride(
          destination: 'Jordan Hare Stadium',
          dateTime: DateTime(2024, 10, 12, 14, 30),
          price: 12.23,
          rating: 5.0),
      Ride(
          destination: 'Jordan Hare Stadium',
          dateTime: DateTime(2024, 10, 12, 14, 30),
          price: 12.23,
          rating: 5.0),
    ];
    double sumRatings = tempRides.fold(0.0, (sum, item) => sum + item.rating);
    averageRating = sumRatings / tempRides.length;

    setState(() {
      rides = tempRides;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
              '\nYour Average Rating',
              style: ZipDesign.sectionTitleText,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 40),
                const SizedBox(width: 10),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: averageRating
                            .toStringAsFixed(1), // Average rating value
                        style:
                            const TextStyle(color: Colors.black, fontSize: 28),
                      ),
                      const TextSpan(
                        text: ' / 5.0',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
            ),
            const SizedBox(height: 16),
            const Text(
              'Completed Trips',
              style: ZipDesign.sectionTitleText,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  return DriverActivityItem(
                    destination: rides[index].destination,
                    dateTime: rides[index].dateTime,
                    price: rides[index].price,

                    // rating: rides[index].rating,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Ride {
  final String destination;
  final DateTime dateTime;
  final double price;
  final double rating;

  Ride({
    required this.destination,
    required this.dateTime,
    required this.price,
    this.rating = 5.0,
  });
}


// Ensure that your RideActivityItem widget can accept and properly display
// the destination, dateTime, and price properties.


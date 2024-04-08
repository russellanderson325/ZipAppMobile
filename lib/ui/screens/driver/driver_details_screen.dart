import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/constants/zip_formats.dart';

class DriverDetailsScreen extends StatefulWidget {
  final DateTime dateTime;
  final double price;
  const DriverDetailsScreen(
      {super.key, required this.dateTime, required this.price});

  @override
  State<DriverDetailsScreen> createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  final UserService userService = UserService();
  // Sample static comments
  List<String> comments = [
    "The driver was really friendly and the car was clean.",
    "Excellent service, would ride again!",
    "Driver arrived late but apologized and explained the delay.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details', style: ZipDesign.pageTitleText),
        backgroundColor: Colors.white,
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameDatePriceRow(),
              const Padding(
                padding: EdgeInsets.only(top: 32, bottom: 16),
                child: Text('Location', textAlign: TextAlign.left, style: ZipDesign.sectionTitleText),
              ),
              _buildStartLocation('250 W. Glenn Ave, Auburn, AL 36830', DateTime(2024, 10, 12, 14, 35)),
              const SizedBox(height: 16),
              _buildEndLocation('251 S. Donahue Dr, Auburn, AL 36849', DateTime(2024, 10, 12, 14, 49)),
              const Padding(
                padding: EdgeInsets.only(top: 32, bottom: 16),
                child: Text('Tip and Rating', textAlign: TextAlign.left, style: ZipDesign.sectionTitleText),
              ),
              _buildTipOrRatingRow(LucideIcons.coins, '\$3.40'),
              const SizedBox(height: 16),
              _buildTipOrRatingRow(LucideIcons.star, '4 stars'),
              const Padding(
                padding: EdgeInsets.only(top: 32, bottom: 16),
                child: Text('Comments/Concerns', style: ZipDesign.sectionTitleText),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: comments.map((comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(comment),
                    )).toList(),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom:16),
                child: Text('Trip ID: a2sg6h-24c7hjfd-565fgng-8jge34323', style: ZipDesign.tinyLightText),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildNameDatePriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ride with ${userService.user.firstName} ${userService.user
                  .lastName[0]}.',
              textAlign: TextAlign.left,
              style: ZipDesign.sectionTitleText,
            ),
            ZipFormats.activityDetailsDatePriceFormatter(
              widget.dateTime, widget.price,),
          ],
        ),
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: TailwindColors.gray300,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(LucideIcons.user,
              color: TailwindColors.gray500, size: 24),
        )
      ],
    );
  }

  Widget _buildStartLocation(String address, DateTime dateTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(LucideIcons.locate, size: 16, color: Colors.black),
            const SizedBox(width: 16),
            Text(address,
                style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          ],
        ),
        ZipFormats.activityDetailsTimeFormatter(dateTime),
      ],
    );
  }

  Widget _buildEndLocation(String address, DateTime dateTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(LucideIcons.mapPin, size: 16, color: Colors.black),
            const SizedBox(width: 16),
            Text(address,
                style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          ],
        ),
        ZipFormats.activityDetailsTimeFormatter(dateTime),
      ],
    );
  }

  Widget _buildTipOrRatingRow(IconData icon, String title) {
    return Row(
      children: [
        Row(
          children: <Widget>[
            Icon(icon, size: 16, color: Colors.black),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ],
    );
  }

}

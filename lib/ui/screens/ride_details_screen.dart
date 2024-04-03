import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/constants/zip_formats.dart';
import 'package:zipapp/ui/widgets/RatingDrawer.dart';

class RideDetailsScreen extends StatefulWidget {
  final DateTime dateTime;
  final double price;
  const RideDetailsScreen(
      {super.key, required this.dateTime, required this.price});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details', style: ZipDesign.pageTitleText),
        backgroundColor: ZipColors.primaryBackground,
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.all(0),
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: ZipColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildNameDatePriceRow(),
                const Padding(
                  padding: EdgeInsets.only(top: 32, bottom: 16),
                  child: Text(
                    'Location',
                    textAlign: TextAlign.left,
                    style: ZipDesign.sectionTitleText,
                  ),
                ),
                _buildStartLocation(
                  '250 W. Glenn Ave, Auburn, AL 36830',
                  DateTime(2024, 10, 12, 14, 35),
                ),
                const SizedBox(height: 16),
                _buildEndLocation(
                  '251 S. Donahue Dr, Auburn, AL 36849',
                  DateTime(2024, 10, 12, 14, 49),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 32, bottom: 16),
                  child: Text(
                    'Tip and Rating',
                    textAlign: TextAlign.left,
                    style: ZipDesign.sectionTitleText,
                  ),
                ),
                _buildTipOrRatingRow(
                  LucideIcons.coins,
                  'No tip added',
                  'Add tip',
                ),
                const SizedBox(height: 16),
                _buildTipOrRatingRow(
                  LucideIcons.star,
                  'No rating',
                  'Rate',
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 32, bottom: 16),
                  child: Text(
                    'Payment',
                    textAlign: TextAlign.left,
                    style: ZipDesign.sectionTitleText,
                  ),
                ),
                _buildPaymentRow(LucideIcons.creditCard, 'Mastercard ••••1234',
                    widget.price),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('Trip ID: a2sg6h-24c7hjfd-565fgng-8jge34323',
                  style: ZipDesign.tinyLightText),
            ),
          ],
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
              'Ride with ${userService.user.firstName} ${userService.user.lastName[0]}.',
              textAlign: TextAlign.left,
              style: ZipDesign.sectionTitleText,
            ),
            ZipFormats.activityDetailsDatePriceFormatter(
                widget.dateTime, widget.price),
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

  Widget _buildTipOrRatingRow(IconData icon, String title, String buttonTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: <Widget>[
          Icon(icon, size: 16, color: Colors.black),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ]),
        SizedBox(
          height: 23,
          width: 64,
          child: TextButton(
            onPressed: () {
              if (buttonTitle == 'Add tip' || buttonTitle == 'Rate') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RatingDrawer()),
                );
              } else {

              }
            },
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size(64, 23)),
              padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              backgroundColor:
              MaterialStateProperty.all(TailwindColors.gray200),
            ),
            child: Text(
              buttonTitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lexend',
                color: Colors.black,
              ),
            ),
          ),
        )
      ],
    );
  }



  Widget _buildPaymentRow(IconData icon, String cardName, double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon),
            const SizedBox(width: 16),
            Text(cardName, style: ZipDesign.bodyText),
          ],
        ),
        Text(
          '\$$price',
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lexend',
              color: TailwindColors.gray500),
        )
      ],
    );
  }
}
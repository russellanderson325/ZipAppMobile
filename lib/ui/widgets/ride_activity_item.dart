import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/constants/zip_formats.dart';
import 'package:zipapp/ui/screens/ride_details_screen.dart';

class RideActivityItem extends StatefulWidget {
  final String destination;
  final DateTime dateTime;
  final double price;
  const RideActivityItem(
      {super.key,
      required this.destination,
      required this.dateTime,
      required this.price});
  @override
  State<RideActivityItem> createState() => _RideActivityItemState();
}

class _RideActivityItemState extends State<RideActivityItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: TailwindColors.gray300)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideDetailsScreen(dateTime: widget.dateTime, price: widget.price),
                  ),
                );
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                textStyle: MaterialStateProperty.all(ZipDesign.labelText),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.destination),
                      ZipFormats.activityDateFormatter(widget.dateTime)
                    ],
                  ),
                  Row(children: <Widget>[
                    Text(
                      widget.price.toString(),
                      style: ZipDesign.disabledBodyText,
                    ),
                    const SizedBox(width: 16),
                    const Icon(LucideIcons.chevronRight,
                        size: 24, color: TailwindColors.gray500),
                  ])
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

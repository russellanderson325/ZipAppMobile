import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/constants/zip_formats.dart';
import 'package:zipapp/ui/screens/driver/driver_details_screen.dart';


class DriverActivityItem extends StatefulWidget {
  final String destination;
  final DateTime dateTime;
  final double price;
  final double rating;

  const DriverActivityItem({
    super.key,
    required this.destination,
    required this.dateTime,
    required this.price,
    this.rating = 5.0,});
  @override
  State<DriverActivityItem> createState() => _DriverActivityItemState();
}

class _DriverActivityItemState extends State<DriverActivityItem> {
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
                    builder: (context) => DriverDetailsScreen(dateTime: widget.dateTime, price: widget.price),
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

                  Row(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: '\$', // The dollar sign
                              style: ZipDesign.labelText.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            TextSpan(
                              text: widget.price.toStringAsFixed(2), // The price
                              style: ZipDesign.labelText.copyWith(color: Colors.grey),
                            ),
                            TextSpan(
                              text: '   • ', // The point separator
                              style: ZipDesign.labelText.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      const Icon(Icons.star, color: Colors.grey, size: 20), // Star icon

                      Text(
                        ' ${widget.rating.toStringAsFixed(1)}', // The rating number
                        style: ZipDesign.labelText.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      const Icon(LucideIcons.chevronRight, size: 24, color: TailwindColors.gray500),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_design.dart';

class ZipFormats {
  static const List<String> months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static Widget activityDateFormatter(DateTime dateTime) {
    String date = '${ZipFormats.months[dateTime.month]} ${dateTime.day} ';
    String hour = '${dateTime.hour % 12}';
    String suffix = dateTime.hour > 12 ? 'PM' : 'AM';
    String minute = '${dateTime.minute}';
    String time = ' $hour:$minute $suffix';
    return Row(children: <Widget>[
      Text(date, style: ZipDesign.disabledBodyText),
      const Icon(Icons.circle, size: 2, color: TailwindColors.gray500),
      Text(time, style: ZipDesign.disabledBodyText),
    ]);
  }

  static Widget activityDetailsDatePriceFormatter(
      DateTime dateTime, double price) {
    String date = '${ZipFormats.months[dateTime.month]} ${dateTime.day}';
    String hour = '${dateTime.hour % 12}';
    String suffix = dateTime.hour > 12 ? 'PM' : 'AM';
    String minute = '${dateTime.minute}';
    String time = '$hour:$minute $suffix';
    String formattedPrice = '  \$${price.toString()}';
    return Row(children: <Widget>[
      Text('$date $time  ', style: ZipDesign.disabledBodyText),
      const Icon(Icons.circle, size: 2, color: TailwindColors.gray500),
      Text(formattedPrice, style: ZipDesign.disabledBodyText)
    ]);
  }

  static Widget activityDetailsTimeFormatter(DateTime dateTime) {
    String hour = '${dateTime.hour % 12}';
    String suffix = dateTime.hour > 12 ? 'PM' : 'AM';
    String minute = '${dateTime.minute}';
    return Text('$hour:$minute $suffix', style: ZipDesign.tinyLightText);
  }
}

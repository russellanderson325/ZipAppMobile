import 'package:flutter/material.dart';
import 'package:zipapp/constants/tailwind_colors.dart';

class ZipDesign {
  /// TextStyles
  static const TextStyle pageTitleText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'Lexend',
  );
  static const TextStyle sectionTitleText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: 'Lexend',
  );
  static const TextStyle labelText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Lexend',
  );
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Lexend',
  );
  static const TextStyle disabledBodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Lexend',
    color: TailwindColors.gray500,
  );
  static const TextStyle tinyLightText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    fontFamily: 'Lexend',
  );
}

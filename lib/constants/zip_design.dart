import 'package:flutter/material.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_colors.dart';

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
  // ButtonStyles
  static final ButtonStyle yellowButtonStyle = ButtonStyle(
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
    foregroundColor: MaterialStateProperty.all(Colors.black),
    backgroundColor: MaterialStateProperty.all(Colors.yellow),
    textStyle: MaterialStateProperty.all(ZipDesign.labelText),
  );
}

import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String title;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onPressed;
  final Color? color;
  final Color splashColor;
  final Color borderColor;
  final double borderWidth;

  const CustomTextButton(
      {super.key,
      required this.title,
      required this.textColor,
      required this.fontSize,
      required this.fontWeight,
      required this.onPressed,
      this.color,
      required this.splashColor,
      required this.borderColor,
      required this.borderWidth});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        primary: splashColor,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          title,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            decoration: TextDecoration.none,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: "OpenSans",
          ),
        ),
      ),
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(30.0),
      //   side: BorderSide(
      //     color: borderColor,
      //     width: borderWidth,
      //   ),
      // ),
    );
  }
}

class CustomTextButtonWithUnderline extends StatelessWidget {
  final String title;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onPressed;
  final Color color;
  final Color splashColor;
  final Color borderColor;
  final double borderWidth;

  const CustomTextButtonWithUnderline(
      {super.key,
      required this.title,
      required this.textColor,
      required this.fontSize,
      required this.fontWeight,
      required this.onPressed,
      required this.color,
      required this.splashColor,
      required this.borderColor,
      required this.borderWidth});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
          primary: color,
          onSurface: splashColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            side: BorderSide(
              color: borderColor,
              width: borderWidth,
            ),
          )),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          title,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            decoration: TextDecoration.underline,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: "OpenSans",
          ),
        ),
      ),
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(30.0),
      //   side: BorderSide(
      //     color: borderColor,
      //     width: borderWidth,
      //   ),
      // ),
    );
  }
}

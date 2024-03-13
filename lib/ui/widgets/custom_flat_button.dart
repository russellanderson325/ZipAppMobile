import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String title;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onPressed;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;

  const CustomTextButton(
      {super.key,
      required this.title,
      this.textColor,
      required this.fontSize,
      required this.fontWeight,
      required this.onPressed,
      this.color,
      this.borderColor,
      this.borderWidth,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              borderRadius == null ? 30.0 : borderRadius!),
          side: BorderSide(
            color: borderColor == null ? Colors.transparent : borderColor!,
            width: borderWidth == null ? 0 : borderWidth!,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor == null ? Colors.black : textColor!,
            decoration: TextDecoration.none,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: "Lexend",
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
          backgroundColor: color,
          foregroundColor: splashColor,
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

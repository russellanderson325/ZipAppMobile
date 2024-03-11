import 'package:flutter/material.dart';
import 'package:zipapp/business/validator.dart';

import 'package:zipapp/constants/zip_colors.dart';

class AuthenticationDrawerWidgets {
  Widget promptTextLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 6),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget inputTextField(
      TextEditingController controller, bool obscureText, Function validator) {
    return TextField(
      obscureText: obscureText,
      controller: controller,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.only(left: 14, right: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: ZipColors.lightGray, width: 1.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: ZipColors.lightGray, width: 1.0)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: ZipColors.lightGray, width: 1.0)),
      ),
    );
  }

  Widget draggableIcon() {
    return Container(
        width: 96,
        height: 6,
        decoration: const BoxDecoration(
          color: ZipColors.draggableBackground,
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ));
  }
}

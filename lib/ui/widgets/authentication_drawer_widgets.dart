import 'package:flutter/material.dart';
import 'package:zipapp/constants/tailwind_colors.dart';

import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';

/// TODO: Handle validation

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
      {required TextEditingController controller,
      required bool obscureText,
      Function? validator,
      Function? onChanged}) {
    return TextField(
      obscureText: obscureText,
      controller: controller,
      onChanged: (value) {
        if (onChanged != null) {
          onChanged();
        }
      },
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

  Widget infoIconTextBubble(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: TailwindColors.gray500, size: 16.0),
        Flexible(
          child: Text(
            text,
            style: ZipDesign.disabledBodyText.copyWith(fontSize: 14),
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        )
      ],
    );
  }

  Widget infoTextBubble(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: Text(
            text,
            style: ZipDesign.disabledBodyText.copyWith(fontSize: 14),
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        )
      ],
    );
  }

  Widget commentsBox(String hintText) {
    return TextField(
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: ZipDesign.disabledBodyText.copyWith(fontSize: 14),
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: ZipColors.lightGray, width: 1.0)),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: ZipColors.lightGray, width: 1.0)),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: ZipColors.lightGray, width: 1.0)),
      ),
    );
  }
}

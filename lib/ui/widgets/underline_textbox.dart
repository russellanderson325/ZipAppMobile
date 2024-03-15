import 'package:flutter/material.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_design.dart';

class UnderlineTextbox {
  static Widget build({
    required String labelText,
    required String value,
    bool disabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: TailwindColors.gray300)),
      ),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              labelText,
              style: ZipDesign.labelText,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: disabled ? ZipDesign.disabledBodyText : ZipDesign.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}

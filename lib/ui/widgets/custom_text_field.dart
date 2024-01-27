import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final Color baseColor;
  final Color borderColor;
  final Color errorColor;
  final TextInputType inputType;
  final bool obscureText;
  final Function validator;
  final Function? onChanged;
  final Icon customTextIcon;
  const CustomTextField(
      {super.key,
      required this.hint,
      required this.controller,
      required this.baseColor,
      this.onChanged,
      required this.borderColor,
      required this.errorColor,
      this.inputType = TextInputType.text,
      this.obscureText = false,
      required this.validator,
      required this.customTextIcon});

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.borderColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          obscureText: widget.obscureText,
          onChanged: (text) {
            widget.onChanged!(text);
            setState(() {
              if (!widget.validator(text) || text.isEmpty) {
                currentColor = widget.errorColor;
              } else {
                currentColor = widget.baseColor;
              }
            });
          },
          //keyboardType: widget.inputType,
          controller: widget.controller,
          decoration: InputDecoration(
            hintStyle: TextStyle(
                color: widget.baseColor,
                fontFamily: "OpenSans",
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.none),
            hintText: widget.hint,
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: currentColor, width: 1.0)),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(),
              child: widget.customTextIcon,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField2 extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final Color baseColor;
  final Color borderColor;
  final Color errorColor;
  final TextInputType inputType;
  final bool obscureText;
  final Function validator;
  final Function? onChanged;
  final Icon customTextIcon;
  final bool isEditable;
  const CustomTextField2(
      {super.key,
      required this.hint,
      required this.controller,
      required this.baseColor,
      required this.onChanged,
      required this.borderColor,
      required this.errorColor,
      this.inputType = TextInputType.text,
      this.obscureText = false,
      required this.validator,
      required this.customTextIcon,
      required this.isEditable});

  @override
  _CustomTextFieldState2 createState() => _CustomTextFieldState2();
}

class _CustomTextFieldState2 extends State<CustomTextField2> {
  late Color currentColor;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 0.5,
        ),
      ),
      color: Colors.white,
      child: TextField(
        enabled: widget.isEditable,
        onChanged: (text) {},
        style: const TextStyle(
            color: Color.fromRGBO(255, 242, 0, 1.0),
            fontFamily: "OpenSans",
            fontWeight: FontWeight.w300,
            decoration: TextDecoration.none),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(),
            child: widget.customTextIcon,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

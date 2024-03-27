import 'package:flutter/material.dart';
import 'package:zipapp/ui/widgets/custom_flat_button.dart';

class CustomAlertDialog extends StatelessWidget {
  final String? title;
  final String? content;
  final VoidCallback? onPressed;

  const CustomAlertDialog(
      {super.key, this.title, this.content, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(5.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      title: Text(
        title ?? "Alert",
        softWrap: true,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          decoration: TextDecoration.none,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: "OpenSans",
        ),
      ),
      content: SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              content ?? "Alert content",
              softWrap: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                decoration: TextDecoration.none,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                fontFamily: "OpenSans",
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: CustomTextButton(
                title: "OK",
                fontSize: 16,
                fontWeight: FontWeight.w700,
                textColor: Colors.black54,
                onPressed: () {
                  onPressed!();
                  Navigator.of(context).pop();
                },
                borderColor: Colors.black12,
                borderWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

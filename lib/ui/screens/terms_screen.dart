import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Terms and Conditions Screen'),
          // go back text button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go Back'),
          )
        ],
      ),
    ));
  }
}

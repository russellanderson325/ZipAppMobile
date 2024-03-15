import 'package:flutter/material.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({Key? key}) : super(key: key);

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Safety Screen'),
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

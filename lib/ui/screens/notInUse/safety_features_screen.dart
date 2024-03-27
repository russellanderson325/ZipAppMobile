import "package:flutter/material.dart";
// import 'package:geoflutterfire/geoflutterfire.dart';

class SafetyFeaturesScreen extends StatefulWidget {
  const SafetyFeaturesScreen({super.key});

  @override
  State<SafetyFeaturesScreen> createState() => _SafetyFeaturesScreenState();
}

class _SafetyFeaturesScreenState extends State<SafetyFeaturesScreen> {
  late VoidCallback onBackPress;
  @override
  void initState() {
    onBackPress = () {
      Navigator.of(context).pop();
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 23.0,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //TopRectangle(
                Container(
                  color: Colors.black,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Color.fromRGBO(255, 242, 0, 1.0)),
                          onPressed: onBackPress,
                        ),
                      ),
                      const Text("   Rules & Safety",
                          style: TextStyle(
                              //backgroundColor: Colors.black,
                              color: Color.fromRGBO(255, 242, 0, 1.0),
                              fontSize: 36.0,
                              fontWeight: FontWeight.w300,
                              fontFamily: "Bebas"))
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
                ),
                const Text("  Rules & Safety for Mobile",
                    style: TextStyle(
                        color: Color.fromRGBO(255, 242, 0, 1.0),
                        fontSize: 28.0,
                        fontWeight: FontWeight.w300,
                        fontFamily: "Bebas")),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0),
                  child: Text(
                      "Riding Rules\n\n- One passenger per seat.\n- No open containers of alcohol.\n- Be courteous to those around you.\n- Wear your seatbelt.\n- Follow all local city rules.\n\nSafety\n\n- If you do not feel safe entering a Zip cart for any reason, do not enter and we will refund your money.\n- All Zip carts come equipped with standard safety equipment.\n- Our drivers are trained & vetted thoroughly.",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300,
                          fontFamily: "Poppins")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopRectangle extends StatelessWidget {
  final Color? color;
  final double height;
  final double width;
  final Widget child;
  final posi;
  const TopRectangle(
      {super.key,
      this.posi,
      required this.child,
      this.color,
      this.height = 100.0,
      this.width = 500.0});

  @override
  build(context) {
    return Container(
      width: width,
      height: height,
      color: const Color.fromRGBO(76, 86, 96, 1.0),
      child: child,
    );
  }
}

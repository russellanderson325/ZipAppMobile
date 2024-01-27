class Validator {
  static bool validateName(String text) {
    return text.contains(RegExp(r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$"));
  }

  static bool validateNumber(String text) {
    Pattern pattern = r'^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$';
    RegExp regex = RegExp(pattern.toString());
    return regex.hasMatch(text);
  }

  static bool validateEmail(String text) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    return regex.hasMatch(text);
  }

  static bool validatePassword(String text) {
    return text.toString().length >= 6;
  }

  // static Future<bool> validateStreetAddress(String text) async {
  //   bool isValid = false;
  //   try{
  //      List<Placemark> placemark = await Geolocator()
  //       .placemarkFromAddress(text);
  //       placemark.forEach((f){ print(f.toString() );});
  //     if (placemark.isEmpty){
  //       return false;
  //     }
  //     else{
  //       return true;
  //     }
  //   }
  //   catch(e){
  //   }
  //   return isValid;
  // }
}

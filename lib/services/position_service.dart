import 'package:geolocator/geolocator.dart';

class PositionService {
  Stream<Position> get positionStream => Geolocator.getPositionStream();

  PositionService() {
    LocationPermission permission;
    Geolocator.checkPermission().then((value) {
      permission = value;
      if (permission == LocationPermission.denied) {
        Geolocator.requestPermission().then((value) {
          permission = value;
          if (permission == LocationPermission.denied) {
            throw Exception('Location permissions are denied');
          }
        });
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
    });
  }

  Future<Position> getPosition() async {
    Position userPosition = await Geolocator.getCurrentPosition();
    return userPosition;
  }
}

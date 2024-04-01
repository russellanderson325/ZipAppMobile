import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';

class Request {
  final String id;
  final GeoFirePoint? destinationAddress;
  final GeoFirePoint? pickupAddress;
  final String price;
  final String name;
  final String photoURL;
  final Timestamp timeout;

  Request(
      {required this.id,
      this.destinationAddress,
      this.pickupAddress,
      required this.price,
      required this.name,
      required this.photoURL,
      required this.timeout});

  Map<String, Object> toJson() {
    return {
      'id': id,
      'destinationAddress': destinationAddress as Object,
      'pickupAddress': pickupAddress as Object,
      'price': price,
      'name': name,
      'photoURL': photoURL,
      'timeout': timeout
    };
  }

  factory Request.fromJson(Map<String, Object> doc) {
    Request ride = Request(
        id: doc['id'] as String,
        destinationAddress: extractGeoFirePoint(doc['destinationAddress'] as Map<String, dynamic>),
        pickupAddress: extractGeoFirePoint(doc['pickupAddress'] as Map<String, dynamic>),
        price: doc['price'] as String,
        name: doc['name'] as String,
        photoURL: doc['photoURL'] as String,
        timeout: doc['timeout'] as Timestamp);
    return ride;
  }

  factory Request.fromDocument(DocumentSnapshot doc) {
    return Request.fromJson(doc.data() as Map<String, Object>);
  }

  static GeoFirePoint extractGeoFirePoint(Map<String, dynamic> pointMap) {
    GeoPoint point = pointMap['geopoint'];
    return GeoFirePoint(point.latitude, point.longitude);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class Request {
  final String id;
  final dynamic destinationAddress;
  final dynamic pickupAddress;
  final String price;
  final String name;
  final String photoURL;
  final String model;
  final Timestamp timeout;

  Request({
    required this.id,
    this.destinationAddress,
    this.pickupAddress,
    required this.price,
    required this.name,
    required this.photoURL,
    required this.model,
    required this.timeout,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinationAddress': destinationAddress,
      'pickupAddress': pickupAddress,
      'price': price,
      'name': name,
      'photoURL': photoURL,
      'model': model,
      'timeout': timeout,
    };
  }

  factory Request.fromJson(Map<String, dynamic> doc) {
    return Request(
      id: doc['id'] as String,
      destinationAddress: extractGeoFirePoint(doc['destinationAddress']),
      pickupAddress: extractGeoFirePoint(doc['pickupAddress']),
      price: doc['price'] as String,
      name: doc['name'] as String,
      photoURL: doc['photoURL'] as String,
      model: doc['model'] as String,
      timeout: doc['timeout'] as Timestamp,
    );
  }

  factory Request.fromDocument(DocumentSnapshot doc) {
    // Ensure that doc.data() is a Map<String, dynamic>, providing a fallback if necessary
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Request.fromJson(data);
  }

  static GeoFirePoint extractGeoFirePoint(Map<String, dynamic> pointMap) {
    GeoPoint point = pointMap['geopoint'];
    return GeoFirePoint(point.latitude, point.longitude);
  }
}

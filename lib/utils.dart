import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime convertStamp(Timestamp stamp) {
  if (Platform.isIOS) {
    return stamp.toDate();
  } else {
    return Timestamp(stamp.seconds, stamp.nanoseconds).toDate();
  }
}

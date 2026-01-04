import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrent() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception("Konum servisi kapalı");
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied) {
      throw Exception("Konum izni verilmedi");
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception("Konum izni ayarlardan açılmalı");
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

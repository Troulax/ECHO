import 'dart:math';
import '../models/shelter.dart';

class GeoService {
  double _km(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  List<ShelterWithDistance> nearest({
    required double userLat,
    required double userLng,
    required List<Shelter> shelters,
    int limit = 5,
  }) {
    final list = shelters
        .map((s) => ShelterWithDistance(
              s,
              _km(userLat, userLng, s.lat, s.lng),
            ))
        .toList();

    list.sort((a, b) => a.km.compareTo(b.km));
    return list.take(limit).toList();
  }
}

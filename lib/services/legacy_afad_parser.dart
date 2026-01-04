import '../models/shelter.dart';

class LegacyAfadParser {
  /// Tüm illerden flat Shelter listesi üretir
  static List<Shelter> parse(Map<String, dynamic> json) {
    final List<Shelter> result = [];

    for (final ilEntry in json.entries) {
      final ilData = ilEntry.value;
      final ilceler = ilData["ilceler"] as Map<String, dynamic>?;

      if (ilceler == null) continue;

      for (final ilceEntry in ilceler.entries) {
        final ilceData = ilceEntry.value;
        final mahalleler =
            ilceData["mahalleler"] as Map<String, dynamic>?;

        if (mahalleler == null) continue;

        for (final mahalleEntry in mahalleler.entries) {
          final mahalleData = mahalleEntry.value;
          final alanlar =
              mahalleData["toplanmaAlanlari"] as Map<String, dynamic>?;

          if (alanlar == null) continue;

          for (final alanEntry in alanlar.entries) {
            final a = alanEntry.value;

            result.add(
              Shelter(
                id: a["id"].toString(),
                name: a["tesis_adi"] ?? "Toplanma Alanı",
                address: a["acik_adres"] ?? "",
                // DİKKAT: x = boylam, y = enlem
                lat: (a["y"] as num).toDouble(),
                lng: (a["x"] as num).toDouble(),
              ),
            );
          }
        }
      }
    }

    return result;
  }
}

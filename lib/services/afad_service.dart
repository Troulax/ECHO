import 'dart:convert';
import 'package:http/http.dart' as http;

class AfadService {
  static const String url =
      "https://api.orhanaydogdu.com.tr/deprem/kandilli/live";

  static Future<List<Map<String, dynamic>>> fetchLast10() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Deprem verisi alınamadı");
    }

    final data = json.decode(response.body);
    final List list = data["result"];

    return list.take(10).map<Map<String, dynamic>>((item) {
      return {
        'title': item['title'],
        'mag': item['mag'],
        'date': item['date_time'] ?? item['created_at'],
        'lat': item['lat'],
        'lng': item['lng'],
      };
    }).toList();
  }
}

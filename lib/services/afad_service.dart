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
    final list = List<Map<String, dynamic>>.from(data["result"]);

    // Her zaman 10 deprem döndürelim
    return list.take(10).toList();
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shelter.dart';

class ShelterCache {
  static const _key = "cached_shelters";

  Future<void> save(List<Shelter> shelters) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = shelters.map((s) => s.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<List<Shelter>?> load() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_key);
  print("CACHE RAW: $raw");
  if (raw == null) return null;

  final list = (jsonDecode(raw) as List)
      .cast<Map<String, dynamic>>();

  return list.map(Shelter.fromJson).toList();
}

}

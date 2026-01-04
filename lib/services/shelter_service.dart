import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/shelter.dart';

class ShelterService {
  Future<List<Shelter>> loadLocalShelters() async {
    final raw = await rootBundle.loadString(
      "assets/data/shelters_sample.json",
    );

    final list = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>();

    return list.map(Shelter.fromJson).toList();
  }
}

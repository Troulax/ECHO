import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class NearestSheltersPage extends StatefulWidget {
  const NearestSheltersPage({super.key});

  @override
  State<NearestSheltersPage> createState() => _NearestSheltersPageState();
}

class _NearestSheltersPageState extends State<NearestSheltersPage> {
  Position? _me;
  bool _loading = true;
  String? _error;

  List<_ShelterItem> _items = [];

  static const String _apiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final me = await _getCurrentPosition();
      final shelters = await _loadShelters();
      final items = shelters.map((s) {
        final d = Geolocator.distanceBetween(
          me.latitude,
          me.longitude,
          s.lat,
          s.lng,
        );
        return _ShelterItem.fromShelter(s, d);
      }).toList()
        ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      setState(() {
        _me = me;
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<Position> _getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Konum servisleri kapalı';
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw 'Konum izni verilmedi';
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<List<_Shelter>> _loadShelters() async {
    final jsonStr =
        await rootBundle.loadString('assets/data/shelters_sample.json');
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => _Shelter.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('En Yakın Sığınma Alanları')),
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final s = _items[i];
          return ListTile(
            leading: const Icon(Icons.place),
            title: Text(s.name),
            subtitle: Text('${s.address} • ${s.kmText}'),
            trailing: const Icon(Icons.directions),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _RoutePage(
                    origin: LatLng(_me!.latitude, _me!.longitude),
                    shelter: s,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/* ---------------- ROUTE PAGE ---------------- */

class _RoutePage extends StatelessWidget {
  final LatLng origin;
  final _ShelterItem shelter;

  const _RoutePage({
    required this.origin,
    required this.shelter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yol Tarifi')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(shelter.lat, shelter.lng),
          zoom: 14,
        ),
        myLocationEnabled: true,
        trafficEnabled: true,
        markers: {
          Marker(
            markerId: const MarkerId('shelter'),
            position: LatLng(shelter.lat, shelter.lng),
          ),
        },
      ),
    );
  }
}

/* ---------------- MODELS ---------------- */

class _Shelter {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;

  _Shelter.fromJson(Map<String, dynamic> j)
      : id = j['id'].toString(),
        name = j['name'],
        address = j['address'],
        lat = (j['lat'] as num).toDouble(),
        lng = (j['lng'] as num).toDouble();
}

class _ShelterItem extends _Shelter {
  final double distanceMeters;

  _ShelterItem.fromShelter(_Shelter s, this.distanceMeters)
      : super.fromJson({
          'id': s.id,
          'name': s.name,
          'address': s.address,
          'lat': s.lat,
          'lng': s.lng,
        });

  String get kmText =>
      distanceMeters < 1000 ? '${distanceMeters.toInt()} m' : '${(distanceMeters / 1000).toStringAsFixed(2)} km';
}

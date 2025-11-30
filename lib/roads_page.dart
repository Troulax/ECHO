import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoadsPage extends StatefulWidget {
  const RoadsPage({super.key});

  @override
  State<RoadsPage> createState() => _RoadsPageState();
}

class _RoadsPageState extends State<RoadsPage> {
  GoogleMapController? _mapController;
  LatLng? _userLatLng;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    // Konum servisi açık mı?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // İstersen burada kullanıcıya uyarı gösterebilirsin.
      return;
    }

    // İzin kontrolü
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      // İzin verilmediyse haritayı konumsuz da gösterebilirsin.
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _userLatLng = LatLng(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yol Durumu")),
      body: _userLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLatLng!,
                zoom: 14,
              ),
              myLocationEnabled: true,        // mavi nokta
              myLocationButtonEnabled: true,  // köşedeki buton
              trafficEnabled: true,           // trafik yoğunluğu (yeşil/sarı/kırmızı)
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
    );
  }
}

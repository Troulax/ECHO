import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'services/location_service.dart';

class RoadsPage extends StatefulWidget {
  final String? targetName;
  final double? targetLat;
  final double? targetLng;

  const RoadsPage({
    super.key,
    this.targetName,
    this.targetLat,
    this.targetLng,
  });

  bool get hasTarget => targetLat != null && targetLng != null;

  @override
  State<RoadsPage> createState() => _RoadsPageState();
}

class _RoadsPageState extends State<RoadsPage> {
  final _loc = LocationService();
  LatLng? _userPos;

  // ✅ Trafik modu toggle
  bool _trafficEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final pos = await _loc.getCurrent();
    setState(() {
      _userPos = LatLng(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userPos == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId("user"),
        position: _userPos!,
        infoWindow: const InfoWindow(title: "Konumum"),
      ),
    };

    if (widget.hasTarget) {
      markers.add(
        Marker(
          markerId: const MarkerId("target"),
          position: LatLng(widget.targetLat!, widget.targetLng!),
          infoWindow: InfoWindow(
            title: widget.targetName ?? "Hedef",
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Yol"),
        actions: [
          IconButton(
            tooltip: _trafficEnabled ? "Trafiği Kapat" : "Trafiği Aç",
            icon: Icon(
              _trafficEnabled ? Icons.traffic : Icons.traffic_outlined,
            ),
            onPressed: () {
              setState(() {
                _trafficEnabled = !_trafficEnabled;
              });
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _userPos!,
          zoom: 14,
        ),
        myLocationEnabled: true,
        markers: markers,

        // ✅ Trafik yoğunluğu katmanı
        trafficEnabled: _trafficEnabled,
      ),
    );
  }
}

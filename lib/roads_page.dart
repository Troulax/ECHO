import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  final _polylinePoints = PolylinePoints();

  LatLng? _userPos;
  GoogleMapController? _controller;

  final Set<Polyline> _polylines = {};
  bool _trafficEnabled = false;

  static const String _apiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final pos = await _loc.getCurrent();
    _userPos = LatLng(pos.latitude, pos.longitude);

    if (widget.hasTarget) {
      await _drawRoute();
    }

    setState(() {});
  }

  Future<void> _drawRoute() async {
    final result = await _polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: _apiKey,
      request: PolylineRequest(
        origin: PointLatLng(
          _userPos!.latitude,
          _userPos!.longitude,
        ),
        destination: PointLatLng(
          widget.targetLat!,
          widget.targetLng!,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          width: 6,
          points: result.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
        ),
      );
    }
  }

  void _fitBounds() {
    if (!widget.hasTarget || _controller == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _userPos!.latitude < widget.targetLat!
            ? _userPos!.latitude
            : widget.targetLat!,
        _userPos!.longitude < widget.targetLng!
            ? _userPos!.longitude
            : widget.targetLng!,
      ),
      northeast: LatLng(
        _userPos!.latitude > widget.targetLat!
            ? _userPos!.latitude
            : widget.targetLat!,
        _userPos!.longitude > widget.targetLng!
            ? _userPos!.longitude
            : widget.targetLng!,
      ),
    );

    _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60),
    );
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
        onMapCreated: (c) {
          _controller = c;
          _fitBounds();
        },
        myLocationEnabled: true,
        trafficEnabled: _trafficEnabled,
        markers: markers,
        polylines: _polylines, // 🔴 YOL BURADA
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/shelter.dart';
import '../services/location_service.dart';
import '../services/shelter_repo.dart';
import '../services/shelter_service.dart';
import '../services/geo_service.dart';
import '../services/directions_service.dart';
import 'package:echo_app/roads_page.dart';



class NearestSheltersPage extends StatefulWidget {
  const NearestSheltersPage({super.key});

  @override
  State<NearestSheltersPage> createState() => _NearestSheltersPageState();
}

class _NearestSheltersPageState extends State<NearestSheltersPage> {
  final _loc = LocationService();
  final _repo = ShelterRepo();
  final _service = ShelterService();
  final _geo = GeoService();
  final _dir = DirectionsService();

  bool _loading = true;
  String? _error;
  List<ShelterWithDistance> _nearest = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final pos = await _loc.getCurrent();

      final all = await _repo.getShelters(
        remoteFetch: () => _service.loadLocalShelters(),
      );

      final nearest = _geo.nearest(
        userLat: pos.latitude,
        userLng: pos.longitude,
        shelters: all,
        limit: 5,
      );

      setState(() {
        _nearest = nearest;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("En Yakın Sığınma Alanları")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text("Tekrar Dene"),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _nearest.length,
                  itemBuilder: (c, i) {
                    final item = _nearest[i];
                    final s = item.shelter;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(s.name),
                        subtitle: Text(
                          "${s.address}\n${item.km.toStringAsFixed(2)} km",
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.directions),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RoadsPage(
                                  targetName: s.name,
                                  targetLat: s.lat,
                                  targetLng: s.lng,
                                ),
                              ),
                            );
                          },

                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

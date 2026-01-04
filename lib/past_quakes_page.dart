import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/afad_service.dart';
import 'services/echo_card.dart';
import 'services/app_text.dart';

class PastQuakesPage extends StatelessWidget {
  const PastQuakesPage({super.key});

  String formatDate(dynamic raw) {
    if (raw == null) return 'Tarih yok';
    final dt = DateTime.parse(raw.toString());
    return '${dt.day.toString().padLeft(2, '0')}.'
           '${dt.month.toString().padLeft(2, '0')}.'
           '${dt.year} '
           '${dt.hour.toString().padLeft(2, '0')}:'
           '${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> openMap(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş Depremler')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: AfadService.fetchLast10(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final d = data[i];

              final mag = (d['mag'] ?? 0).toDouble();
              final title = d['title'] ?? 'Bilinmeyen konum';
              final date = formatDate(d['date']);

              final lat = d['lat'];
              final lng = d['lng'];

              final color = mag < 3
                  ? Colors.green
                  : mag < 5
                      ? Colors.orange
                      : Colors.red;

              return EchoCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: color,
                      child: Text(
                        mag.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// SOL METİN
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            title,
                            maxLines: 2,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// SAĞ HARİTA İKONU
                    if (lat != null && lng != null)
                      IconButton(
                        icon: const Icon(Icons.location_on),
                        color: Colors.blueGrey,
                        tooltip: 'Haritada Göster',
                        onPressed: () =>
                            openMap(lat.toDouble(), lng.toDouble()),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

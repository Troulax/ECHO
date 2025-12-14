import 'package:flutter/material.dart';
import 'services/afad_service.dart';
import 'services/echo_card.dart';
import 'services/app_text.dart';

class PastQuakesPage extends StatelessWidget {
  const PastQuakesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş Depremler'),
      ),
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
              final date = d['date'] ?? 'Tarih yok';

              final color = mag < 3
                  ? Colors.green
                  : mag < 5
                  ? Colors.orange
                  : Colors.red;

              return EchoCard(
                child: Row(
                  children: [
                    CircleAvatar(
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

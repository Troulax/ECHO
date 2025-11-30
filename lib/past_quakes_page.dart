import 'package:flutter/material.dart';
import 'services/afad_service.dart';

class PastQuakesPage extends StatefulWidget {
  const PastQuakesPage({super.key});

  @override
  State<PastQuakesPage> createState() => _PastQuakesPageState();
}

class _PastQuakesPageState extends State<PastQuakesPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    // İstersen 50 geçmiş deprem alabiliriz:
    _future = AfadService.fetchLast10();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geçmiş Depremler")),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const Center(child: Text("Deprem kaydı bulunamadı."));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final d = data[i];

              final mag = (d["mag"] ?? 0).toDouble();
              final title = d["title"]?.toString() ?? "Bilinmeyen konum";
              final date = d["date"]?.toString() ?? "Tarih yok";

              // Renk belirleme (0-3 yeşil, 3-5 turuncu, 5+ kırmızı)
              Color color = mag < 3
                  ? Colors.green
                  : mag < 5
                      ? Colors.orange
                      : Colors.red;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  child: Text(mag.toStringAsFixed(1)),
                ),
                title: Text(title),
                subtitle: Text(date),
              );
            },
          );
        },
      ),
    );
  }
}

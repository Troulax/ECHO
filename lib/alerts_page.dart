import 'package:flutter/material.dart';

import 'services/base_page.dart';
import 'services/app_text.dart';
import 'services/echo_card.dart';

// ✅ AfadService importu
// Eğer afad_service.dart dosyan lib/ klasöründeyse:
import 'services/afad_service.dart';

// Eğer afad_service.dart dosyan lib/services/ içindeyse yukarıdaki importu kapatıp bunu aç:
// import 'services/afad_service.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late Future<List<Map<String, dynamic>>> _future;

  // Ankara ve “Ankara’yı etkileyebilecek” çevre iller
  static const List<String> _ankaraImpactProvincesUpper = [
    'ANKARA',
    'ÇANKIRI',
    'KIRIKKALE',
    'KIRŞEHİR',
    'BOLU',
    'ESKİŞEHİR',
    'KONYA',
    'AKSARAY',
    'YOZGAT',
    'KARABÜK',
  ];

  @override
  void initState() {
    super.initState();
    _future = AfadService.fetchLast10();
  }

  void _refresh() {
    setState(() {
      _future = AfadService.fetchLast10();
    });
  }

  bool _isRelatedToAnkara(String title) {
    final t = title.toUpperCase();
    for (final p in _ankaraImpactProvincesUpper) {
      if (t.contains(p)) return true;
    }
    return false;
  }

  String _magText(dynamic mag) => mag?.toString() ?? '-';

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: AppText(
                  'Uyarılar',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Yenile',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 16),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const EchoCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Expanded(child: AppText('Deprem verileri yükleniyor...')),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return EchoCard(
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppText(
                          'Veri alınamadı: ${snapshot.error}',
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _refresh,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                );
              }

              final all = snapshot.data ?? [];
              final filtered = all.where((e) {
                final title = (e['title'] ?? '').toString();
                return _isRelatedToAnkara(title);
              }).toList();

              if (filtered.isEmpty) {
                return const EchoCard(
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 12),
                      Expanded(
                        child: AppText(
                          'Ankara’yı etkileyen illerde son kayıtlarda deprem uyarısı bulunmamaktadır.',
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = filtered[i];

                    final title = (item['title'] ?? '').toString();
                    final mag = _magText(item['mag']);
                    final date = (item['date'] ?? '').toString();

                    return EchoCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notifications_active, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  title,
                                  maxLines: 3,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                AppText(
                                  'Büyüklük: $mag   •   Tarih: $date',
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

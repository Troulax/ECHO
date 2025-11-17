import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _lastStatus; // 'safe' | 'injured' | 'trapped'
  String? _lastNote;

  Future<void> _openReport(BuildContext context, {String? preset}) async {
    final result = await Navigator.pushNamed(
      context,
      '/report',
      arguments: preset, // 'safe'|'injured'|'trapped'|null
    );

    if (result is Map && result['status'] is String) {
      setState(() {
        _lastStatus = result['status'] as String;
        _lastNote = (result['note'] as String?)?.trim();
      });
      final human = switch (_lastStatus) {
        'safe' => 'Güvendesin',
        'injured' => 'Yaralı bildirildi',
        _ => 'Enkaz altındayım',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Durum güncellendi: $human')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('ECHO')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openReport(context),
        icon: const Icon(Icons.sos_rounded),
        label: const Text('Durum Bildir'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // === Son Durumum alanı ===
          _statusBanner(),

          const SizedBox(height: 16),

          // Durum bildirimi kartı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Durumunuzu Bildirin',
                      style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: [
                      _statusChip(context, 'Güvendeyim', Icons.verified_user, Colors.green, 'safe'),
                      _statusChip(context, 'Yaralıyım', Icons.medical_information, Colors.orange, 'injured'),
                      _statusChip(context, 'Enkaz Altındayım', Icons.report_gmailerrorred, Colors.red, 'trapped'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Kısayollar
          Row(
            children: [
              Expanded(child: _quickAction(context, 'Uyarılar', Icons.notifications_active_outlined, '/alerts')),
              const SizedBox(width: 12),
              Expanded(child: _quickAction(context, 'Kaynaklar', Icons.volunteer_activism_outlined, '/resources')),
              const SizedBox(width: 12),
              Expanded(child: _quickAction(context, 'Tanıdıklar', Icons.contacts_outlined, '/contacts')),
              const SizedBox(width: 12),
              Expanded(child: _quickAction(context, 'Yol Durumu', Icons.alt_route_rounded, '/roads')),
            ],
          ),

          const SizedBox(height: 16),
          Text('Son Uyarılar', style: t.titleMedium),
          const SizedBox(height: 8),
          const _AlertTile(title: 'M5.1 - 12 km Doğu, Düzce', timeText: '2 dk önce', severity: _Severity.high),
          const _AlertTile(title: 'AFAD: Artçı sarsıntılar bekleniyor', timeText: '15 dk önce', severity: _Severity.medium),
          const _AlertTile(title: 'Toplanma alanları bilgilendirmesi', timeText: '1 saat önce', severity: _Severity.low),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _statusBanner() {
    if (_lastStatus == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(.35)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Son Durumum: Henüz bildirilmedi.\n'
                '➡ Durum Bildir ekranından gönderince burada görünecek.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    // Renk/ikon statüye göre
    final (text, icon, color) = switch (_lastStatus) {
      'safe' => ('Güvendedir', Icons.verified, Colors.green),
      'injured' => ('Yaralı bildirildi', Icons.medical_services_rounded, Colors.orange),
      _ => ('Enkaz altındayım bildirildi', Icons.emergency_share_rounded, Colors.red),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _lastNote == null || _lastNote!.isEmpty
                  ? 'Son durumunuz: $text'
                  : 'Son durumunuz: $text — Not: $_lastNote',
              style: TextStyle(fontWeight: FontWeight.w600, color: color.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, String label, IconData icon, Color color, String preset) {
    return ActionChip(
      avatar: Icon(icon, color: color),
      label: Text(label),
      onPressed: () => _openReport(context, preset: preset),
    );
  }

  Widget _quickAction(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

enum _Severity { low, medium, high }

class _AlertTile extends StatelessWidget {
  final String title;
  final String timeText;
  final _Severity severity;
  const _AlertTile({required this.title, required this.timeText, required this.severity});

  @override
  Widget build(BuildContext context) {
    final Color bar = switch (severity) {
      _Severity.high => Colors.red,
      _Severity.medium => Colors.orange,
      _Severity.low => Theme.of(context).colorScheme.primary,
    };

    return Card(
      child: Row(
        children: [
          Container(width: 6, height: 72, color: bar),
          Expanded(
            child: ListTile(
              title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(timeText),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

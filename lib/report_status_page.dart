import 'package:flutter/material.dart';

class StatusReport {
  final String status; // 'safe' | 'injured' | 'trapped'
  final String note;
  const StatusReport({required this.status, required this.note});
}

class ReportStatusPage extends StatefulWidget {
  const ReportStatusPage({super.key});

  @override
  State<ReportStatusPage> createState() => _ReportStatusPageState();
}

class _ReportStatusPageState extends State<ReportStatusPage> {
  String? _status; // 'safe'|'injured'|'trapped'
  final _noteCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && (arg == 'safe' || arg == 'injured' || arg == 'trapped')) {
      _status = arg; // anasayfadaki chip'ten ön-seçim
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Durum Bildir')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Durumun', style: t.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _status,
            hint: const Text('Seçiniz'),
            items: const [
              DropdownMenuItem(value: 'safe', child: Text('Güvendeyim')),
              DropdownMenuItem(value: 'injured', child: Text('Yaralıyım')),
              DropdownMenuItem(value: 'trapped', child: Text('Enkaz Altındayım')),
            ],
            onChanged: (v) => setState(() => _status = v),
          ),
          const SizedBox(height: 16),
          Text('Not / Konum', style: t.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Örn. 3. kat, sol daire. Telefon: ...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.send_rounded),
            onPressed: _status == null
                ? null
                : () {
                    Navigator.pop(context, {
                      'status': _status,                  // 'safe' | 'injured' | 'trapped'
                      'note': _noteCtrl.text.trim(),     // opsiyonel not
                    });
                  },
            label: const Text('Bildir'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/social_repository.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with SingleTickerProviderStateMixin {
  final SocialRepository _repo = SocialRepository();

  TabController? _tabController;
  String? _me;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMe();
  }

  Future<void> _loadMe() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString('current_username');
    setState(() => _me = u);
    if (u != null) {
      try {
        await _repo.ensureUserDoc(u);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _openAddDialog() async {
    if (_me == null) return;

    final ctrl = TextEditingController();
    final to = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tanıdık Ekle'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Kullanıcı adı (örn. testuser2)',
            prefixIcon: Icon(Icons.person_add_alt_1),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('İstek Gönder'),
          ),
        ],
      ),
    );

    if (to == null || to.isEmpty) return;

    try {
      await _repo.sendFriendRequest(fromUsername: _me!, toUsername: to);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$to kullanıcısına istek gönderildi')),
      );
      _tabController?.animateTo(2);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = _me;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanıdıklar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tanıdıklar'),
            Tab(text: 'Gelen'),
            Tab(text: 'Giden'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tanıdık ekle',
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: me == null ? null : _openAddDialog,
          ),
        ],
      ),
      body: me == null
          ? const Center(child: Text('Kullanıcı bulunamadı. Lütfen tekrar giriş yapın.'))
          : TabBarView(
              controller: _tabController,
              children: [
                _FriendsTab(me: me, repo: _repo),
                _IncomingTab(me: me, repo: _repo),
                _OutgoingTab(me: me, repo: _repo),
              ],
            ),
      floatingActionButton: me == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAddDialog,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Ekle'),
            ),
    );
  }
}

class _FriendsTab extends StatelessWidget {
  final String me;
  final SocialRepository repo;

  const _FriendsTab({required this.me, required this.repo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: repo.friendsStream(me),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final friends = snap.data ?? [];
        if (friends.isEmpty) {
          return const Center(child: Text('Henüz tanıdığınız yok.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: friends.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final friendUsername = friends[i];
            return _FriendStatusTile(
              username: friendUsername,
              repo: repo,
            );
          },
        );
      },
    );
  }
}

class _FriendStatusTile extends StatelessWidget {
  final String username;
  final SocialRepository repo;

  const _FriendStatusTile({
    required this.username,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: repo.userProfileStream(username),
      builder: (context, snap) {
        final profile = snap.data;

        final statusCode = profile?.status ?? 'unknown';
        final ui = _StatusUi.fromCode(statusCode);

        final subtitle = profile?.statusUpdatedAt == null
            ? 'Son durum zamanı yok'
            : 'Güncellendi: ${profile!.statusUpdatedAt!.toLocal().toString().substring(0, 16)}';

        return Card(
          elevation: 0,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?'),
            ),
            title: Text(username),
            subtitle: Text(subtitle),
            trailing: Chip(
              avatar: Icon(ui.icon, color: ui.color, size: 18),
              label: Text(ui.label),
            ),
          ),
        );
      },
    );
  }
}

class _IncomingTab extends StatelessWidget {
  final String me;
  final SocialRepository repo;

  const _IncomingTab({required this.me, required this.repo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendRequest>>(
      stream: repo.incomingRequestsStream(me),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reqs = snap.data ?? [];
        if (reqs.isEmpty) {
          return const Center(child: Text('Gelen istek yok.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: reqs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final r = reqs[i];
            return Card(
              elevation: 0,
              child: ListTile(
                leading: CircleAvatar(child: Text(r.from.isNotEmpty ? r.from[0].toUpperCase() : '?')),
                title: Text(r.from),
                subtitle: const Text('Size tanıdık isteği gönderdi'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        await repo.rejectRequest(r);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('İstek reddedildi')),
                        );
                      },
                      child: const Text('Red'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await repo.acceptRequest(r);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('İstek kabul edildi')),
                        );
                      },
                      child: const Text('Kabul'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _OutgoingTab extends StatelessWidget {
  final String me;
  final SocialRepository repo;

  const _OutgoingTab({required this.me, required this.repo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FriendRequest>>(
      stream: repo.outgoingRequestsStream(me),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reqs = snap.data ?? [];
        if (reqs.isEmpty) {
          return const Center(child: Text('Gönderilmiş bekleyen istek yok.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: reqs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final r = reqs[i];
            return Card(
              elevation: 0,
              child: ListTile(
                leading: CircleAvatar(child: Text(r.to.isNotEmpty ? r.to[0].toUpperCase() : '?')),
                title: Text(r.to),
                subtitle: const Text('Beklemede'),
                trailing: TextButton(
                  onPressed: () async {
                    await repo.cancelOutgoingRequest(r.from, r.to);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('İstek iptal edildi')),
                    );
                  },
                  child: const Text('İptal'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusUi {
  final String label;
  final IconData icon;
  final Color color;

  _StatusUi(this.label, this.icon, this.color);

  static _StatusUi fromCode(String code) {
    switch (code) {
      case 'safe':
        return _StatusUi('Güvende', Icons.verified_user, Colors.green);
      case 'injured':
        return _StatusUi('Yaralı', Icons.medical_information, Colors.orange);
      case 'trapped':
        return _StatusUi('Enkaz', Icons.report_gmailerrorred, Colors.red);
      case 'unknown':
      default:
        return _StatusUi('Bilinmiyor', Icons.help_outline, Colors.grey);
    }
  }
}

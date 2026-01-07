import 'package:cloud_firestore/cloud_firestore.dart';

class SocialRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Login sonrası çağır: users/{username} dokümanı yoksa oluştur.
  Future<void> ensureUserDoc(String username) async {
    final ref = _db.collection('users').doc(username);
    await ref.set({
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
      'status': 'unknown',
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> userExists(String username) async {
    final snap = await _db.collection('users').doc(username).get();
    return snap.exists;
  }

  Future<bool> isFriend(String me, String other) async {
    final ref = _db.collection('friends').doc(me).collection('items').doc(other);
    final snap = await ref.get();
    return snap.exists;
  }

  /// ✅ Status güncelle (HomePage burayı çağıracak)
  Future<void> setMyStatus({
    required String username,
    required String status, // safe / injured / trapped / unknown
  }) async {
    final ref = _db.collection('users').doc(username);
    await ref.set({
      'status': status,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ✅ Kullanıcıyı stream'le (Tanıdıkların statusunu canlı göstermek için)
  Stream<UserProfile?> userProfileStream(String username) {
    return _db.collection('users').doc(username).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data() as Map<String, dynamic>;
      return UserProfile.fromMap(username, data);
    });
  }

  /// Friend request: send
  Future<void> sendFriendRequest({
    required String fromUsername,
    required String toUsername,
  }) async {
    if (fromUsername == toUsername) {
      throw 'Kendinizi ekleyemezsiniz.';
    }

    final exists = await userExists(toUsername);
    if (!exists) throw 'Bu kullanıcı bulunamadı.';

    final alreadyFriend = await isFriend(fromUsername, toUsername);
    if (alreadyFriend) throw 'Zaten tanıdıksınız.';

    final docId = _requestDocId(fromUsername, toUsername);
    final ref = _db.collection('friend_requests').doc(docId);

    final snap = await ref.get();
    if (snap.exists) {
      final status = (snap.data()?['status'] ?? '') as String;
      if (status == 'pending') throw 'Zaten bekleyen bir istek var.';
    }

    await ref.set({
      'from': fromUsername,
      'to': toUsername,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<FriendRequest>> incomingRequestsStream(String me) {
    return _db
        .collection('friend_requests')
        .where('to', isEqualTo: me)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((q) => q.docs.map(FriendRequest.fromDoc).toList());
  }

  Stream<List<FriendRequest>> outgoingRequestsStream(String me) {
    return _db
        .collection('friend_requests')
        .where('from', isEqualTo: me)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((q) => q.docs.map(FriendRequest.fromDoc).toList());
  }

  Stream<List<String>> friendsStream(String me) {
    return _db
        .collection('friends')
        .doc(me)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map((d) => d.id).toList());
  }

  Future<void> acceptRequest(FriendRequest req) async {
    final batch = _db.batch();

    final reqRef = _db.collection('friend_requests').doc(req.id);

    final meFriendsRef =
        _db.collection('friends').doc(req.to).collection('items').doc(req.from);
    final otherFriendsRef =
        _db.collection('friends').doc(req.from).collection('items').doc(req.to);

    batch.set(meFriendsRef, {
      'friendUsername': req.from,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(otherFriendsRef, {
      'friendUsername': req.to,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(reqRef, {'status': 'accepted'});

    await batch.commit();
  }

  Future<void> rejectRequest(FriendRequest req) async {
    final ref = _db.collection('friend_requests').doc(req.id);
    await ref.update({'status': 'rejected'});
  }

  Future<void> cancelOutgoingRequest(String from, String to) async {
    final ref = _db.collection('friend_requests').doc(_requestDocId(from, to));
    await ref.update({'status': 'cancelled'});
  }

  static String _requestDocId(String from, String to) => '${from}__${to}';
}

class FriendRequest {
  final String id;
  final String from;
  final String to;
  final String status;

  FriendRequest({
    required this.id,
    required this.from,
    required this.to,
    required this.status,
  });

  static FriendRequest fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return FriendRequest(
      id: doc.id,
      from: (data['from'] ?? '') as String,
      to: (data['to'] ?? '') as String,
      status: (data['status'] ?? '') as String,
    );
  }
}

class UserProfile {
  final String username;
  final String status; // safe/injured/trapped/unknown
  final DateTime? statusUpdatedAt;

  UserProfile({
    required this.username,
    required this.status,
    required this.statusUpdatedAt,
  });

  static UserProfile fromMap(String username, Map<String, dynamic> data) {
    final ts = data['statusUpdatedAt'];
    DateTime? dt;
    if (ts is Timestamp) dt = ts.toDate();

    return UserProfile(
      username: username,
      status: (data['status'] ?? 'unknown') as String,
      statusUpdatedAt: dt,
    );
  }
}

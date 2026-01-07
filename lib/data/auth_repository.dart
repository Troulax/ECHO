import 'app_db.dart';
import 'password_hasher.dart';

class AuthRepository {
  final AppDb db;
  AuthRepository(this.db);

  Future<void> seedAdminIfNeeded() async {
    final existing = await (db.select(db.users)
          ..where((u) => u.username.equals('admin')))
        .getSingleOrNull();

    if (existing != null) return;

    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash('123', salt);

    await db.into(db.users).insert(
          UsersCompanion.insert(
            username: 'admin',
            passwordHash: hash,
            salt: salt,
          ),
        );
  }

  Future<bool> login(String username, String password) async {
    final user = await (db.select(db.users)
          ..where((u) => u.username.equals(username)))
        .getSingleOrNull();

    if (user == null) return false;

    final hash = PasswordHasher.hash(password, user.salt);
    return hash == user.passwordHash;
  }

  Future<bool> register(String username, String password) async {
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(password, salt);

    try {
      await db.into(db.users).insert(
            UsersCompanion.insert(
              username: username,
              passwordHash: hash,
              salt: salt,
            ),
          );
      return true;
    } catch (_) {
      return false; // username unique çakışması vb
    }
  }
}

import 'app_db.dart';
import 'auth_repository.dart';

final appDb = AppDb();
final authRepo = AuthRepository(appDb);

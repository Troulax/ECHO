import '../models/shelter.dart';
import 'shelter_cache.dart';

class ShelterRepo {
  final ShelterCache _cache = ShelterCache();

Future<List<Shelter>> getShelters({
  required Future<List<Shelter>> Function() remoteFetch,
}) async {
  try {
    final remote = await remoteFetch();
    print("CACHE: remote data fetched = ${remote.length}");
    await _cache.save(remote);
    print("CACHE: saved");
    return remote;
  } catch (e) {
    print("CACHE: remote failed -> $e");
    final cached = await _cache.load();
    print("CACHE: loaded = ${cached?.length}");
    if (cached != null) return cached;
    rethrow;
  }
}

}

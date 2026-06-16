import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the active farm id for the signed-in user. Populated right after
/// login (via /farms/index.php) and persisted so it survives app restarts.
class FarmContext {
  static const _farmIdKey = 'active_farm_id';

  final FlutterSecureStorage _storage;

  FarmContext({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  String? _farmId;

  String? get farmId => _farmId;

  Future<void> setFarmId(String? farmId) async {
    _farmId = farmId;
    if (farmId == null) {
      await _storage.delete(key: _farmIdKey);
    } else {
      await _storage.write(key: _farmIdKey, value: farmId);
    }
  }

  Future<String?> loadPersisted() async {
    _farmId ??= await _storage.read(key: _farmIdKey);
    return _farmId;
  }

  Future<void> clear() => setFarmId(null);
}

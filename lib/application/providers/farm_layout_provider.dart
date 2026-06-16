import 'package:flutter/material.dart';
import '../../core/services/local_cache_service.dart';
import '../../domain/entities/farm.dart';

class FarmLayoutProvider extends ChangeNotifier {
  final LocalCacheService cacheService;

  FarmLayoutProvider({required this.cacheService});

  Farm farm = const Farm(
    id: 'f1',
    name: 'Green Valley Farm',
    location: 'Coimbatore, Tamil Nadu',
    sizeAcres: 12.5,
    ownerName: 'Frank Farmer',
  );

  Future<void> load() async {
    final cached = await cacheService.readJson(cacheService.farmKey);
    if (cached != null) {
      farm = Farm(
        id: cached['id'] as String,
        name: cached['name'] as String,
        location: cached['location'] as String,
        sizeAcres: (cached['sizeAcres'] as num).toDouble(),
        ownerName: cached['ownerName'] as String,
      );
      notifyListeners();
    }
  }

  Future<void> updateFarm(Farm updated) async {
    farm = updated;
    notifyListeners();
    await cacheService.cacheJson(cacheService.farmKey, {
      'id': farm.id,
      'name': farm.name,
      'location': farm.location,
      'sizeAcres': farm.sizeAcres,
      'ownerName': farm.ownerName,
    });
  }
}

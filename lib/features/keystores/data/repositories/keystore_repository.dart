import 'package:hive/hive.dart';
import '../models/keystore_model.dart';

class KeystoreRepository {
  final Box<KeystoreModel> _box;

  KeystoreRepository(this._box);

  List<KeystoreModel> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  KeystoreModel? getById(String id) {
    try {
      return _box.values.firstWhere((k) => k.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(KeystoreModel keystore) async {
    await _box.put(keystore.id, keystore);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> update(KeystoreModel keystore) async {
    await keystore.save();
  }

  List<KeystoreModel> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((k) =>
            k.fileName.toLowerCase().contains(lowerQuery) ||
            k.alias.toLowerCase().contains(lowerQuery) ||
            k.commonName?.toLowerCase().contains(lowerQuery) == true)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<KeystoreModel> sortByDate({bool ascending = false}) {
    final list = _box.values.toList();
    list.sort((a, b) =>
        ascending ? a.createdAt.compareTo(b.createdAt) : b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<KeystoreModel> sortByName({bool ascending = true}) {
    final list = _box.values.toList();
    list.sort((a, b) =>
        ascending ? a.fileName.compareTo(b.fileName) : b.fileName.compareTo(a.fileName));
    return list;
  }
}

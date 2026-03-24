import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dev_vault/models/vault_item.dart';
import 'package:uuid/uuid.dart';

class VaultNotifier extends Notifier<List<VaultItem>> {
  @override
  List<VaultItem> build() {
    final box = Hive.box('vault');
    final List<dynamic> rawItems = box.values.toList();
    return rawItems
        .map((item) => VaultItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  late final _box = Hive.box('vault');

  Future<void> addItem(VaultItem item) async {
    await _box.put(item.id, item.toMap());
    state = [...state, item];
  }

  Future<void> updateItem(VaultItem item) async {
    await _box.put(item.id, item.toMap());
    state = [
      for (final i in state)
        if (i.id == item.id) item else i
    ];
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
    state = state.where((item) => item.id != id).toList();
  }
}

final vaultProvider = NotifierProvider<VaultNotifier, List<VaultItem>>(() {
  return VaultNotifier();
});

const _uuid = Uuid();
String generateVaultId() => _uuid.v4();

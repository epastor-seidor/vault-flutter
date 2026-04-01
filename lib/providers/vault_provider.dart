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
        if (i.id == item.id) item else i,
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

class VaultFilterState {
  final String selectedCategory;
  final String sortMode;
  final bool showFavoritesOnly;
  final String passwordStrengthFilter;
  final String passwordAgeFilter;
  final bool showDuplicatesOnly;

  const VaultFilterState({
    this.selectedCategory = 'Todas',
    this.sortMode = 'Fecha',
    this.showFavoritesOnly = false,
    this.passwordStrengthFilter = 'Todas',
    this.passwordAgeFilter = 'Todas',
    this.showDuplicatesOnly = false,
  });

  VaultFilterState copyWith({
    String? selectedCategory,
    String? sortMode,
    bool? showFavoritesOnly,
    String? passwordStrengthFilter,
    String? passwordAgeFilter,
    bool? showDuplicatesOnly,
  }) {
    return VaultFilterState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortMode: sortMode ?? this.sortMode,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
      passwordStrengthFilter:
          passwordStrengthFilter ?? this.passwordStrengthFilter,
      passwordAgeFilter: passwordAgeFilter ?? this.passwordAgeFilter,
      showDuplicatesOnly: showDuplicatesOnly ?? this.showDuplicatesOnly,
    );
  }

  int get activeFilterCount {
    int count = 0;
    if (selectedCategory != 'Todas') count++;
    if (showFavoritesOnly) count++;
    if (passwordStrengthFilter != 'Todas') count++;
    if (passwordAgeFilter != 'Todas') count++;
    if (showDuplicatesOnly) count++;
    return count;
  }

  VaultFilterState clearAll() {
    return const VaultFilterState();
  }
}

class VaultFilterNotifier extends Notifier<VaultFilterState> {
  @override
  VaultFilterState build() => const VaultFilterState();

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSortMode(String mode) {
    state = state.copyWith(sortMode: mode);
  }

  void toggleFavorites() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
  }

  void setPasswordStrength(String strength) {
    state = state.copyWith(passwordStrengthFilter: strength);
  }

  void setPasswordAge(String age) {
    state = state.copyWith(passwordAgeFilter: age);
  }

  void toggleDuplicates() {
    state = state.copyWith(showDuplicatesOnly: !state.showDuplicatesOnly);
  }

  void clearAll() {
    state = state.clearAll();
  }
}

final vaultFilterProvider =
    NotifierProvider<VaultFilterNotifier, VaultFilterState>(() {
      return VaultFilterNotifier();
    });

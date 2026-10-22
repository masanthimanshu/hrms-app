import "package:flutter_riverpod/flutter_riverpod.dart";

import "/models/store_model.dart";
import "/services/store_service.dart";

class StoreState {
  final List<StoreModel> stores;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String searchQuery;
  final StoreModel? selectedStore;

  const StoreState({
    required this.stores,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.searchQuery = "",
    this.selectedStore,
  });

  factory StoreState.initial() {
    return const StoreState(
      stores: [],
      isLoading: false,
    );
  }

  List<StoreModel> get filteredStores {
    if (searchQuery.trim().isEmpty) return stores;
    final query = searchQuery.toLowerCase().trim();
    return stores.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.address.toLowerCase().contains(query);
    }).toList();
  }

  StoreState copyWith({
    List<StoreModel>? stores,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    StoreModel? selectedStore,
    bool clearSelected = false,
  }) {
    return StoreState(
      stores: stores ?? this.stores,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStore: clearSelected ? null : (selectedStore ?? this.selectedStore),
    );
  }
}

class StoreNotifier extends Notifier<StoreState> {
  @override
  StoreState build() {
    Future.microtask(() => loadStores());
    return StoreState.initial();
  }

  StoreService get _service => ref.read(storeServiceProvider);

  Future<void> loadStores() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final res = await _service.fetchStores();

    if (res.isSuccess && res.data != null) {
      state = state.copyWith(
        stores: res.data!,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: res.message ?? "Could not load store catalog",
      );
    }
  }

  Future<bool> createStore({
    required String name,
    required String address,
    required String latitude,
    required String longitude,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final res = await _service.createStore(
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );

    if (res.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        successMessage: "Branch '$name' created successfully",
      );
      await loadStores();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: res.message ?? "Failed to create store",
      );
      return false;
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectStore(StoreModel? store) {
    state = state.copyWith(
      selectedStore: store,
      clearSelected: store == null,
    );
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final storeServiceProvider = Provider<StoreService>((ref) => StoreService());

final storeProvider = NotifierProvider<StoreNotifier, StoreState>(StoreNotifier.new);

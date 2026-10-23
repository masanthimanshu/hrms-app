import "package:flutter_riverpod/flutter_riverpod.dart";

import "/models/store_model.dart";
import "/services/store_service.dart";

class StoreState {
  final List<StoreModel> stores;
  final bool isLoading;
  final String? errorMessage;

  const StoreState({
    required this.stores,
    this.isLoading = false,
    this.errorMessage,
  });

  factory StoreState.initial() {
    return const StoreState(stores: [], isLoading: false);
  }

  StoreState copyWith({
    List<StoreModel>? stores,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StoreState(
      stores: stores ?? this.stores,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
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
      state = state.copyWith(stores: res.data!, isLoading: false);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: res.message ?? "Could not load store catalog",
      );
    }
  }
}

final storeServiceProvider = Provider<StoreService>((ref) => StoreService());

final storeProvider = NotifierProvider<StoreNotifier, StoreState>(
  StoreNotifier.new,
);

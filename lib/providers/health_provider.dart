import "package:flutter_riverpod/flutter_riverpod.dart";

import "/services/health_service.dart";

class HealthState {
  final HealthStatus status;
  final bool isChecking;

  const HealthState({
    required this.status,
    this.isChecking = false,
  });

  HealthState copyWith({
    HealthStatus? status,
    bool? isChecking,
  }) {
    return HealthState(
      status: status ?? this.status,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

class HealthNotifier extends Notifier<HealthState> {
  @override
  HealthState build() {
    Future.microtask(() => checkHealth());
    return HealthState(
      status: HealthStatus.initial(),
      isChecking: false,
    );
  }

  HealthService get _service => ref.read(healthServiceProvider);

  Future<void> checkHealth() async {
    state = state.copyWith(isChecking: true);
    final status = await _service.checkAllHealth();
    state = state.copyWith(
      status: status,
      isChecking: false,
    );
  }
}

final healthServiceProvider = Provider<HealthService>((ref) => HealthService());

final healthProvider =
    NotifierProvider<HealthNotifier, HealthState>(HealthNotifier.new);

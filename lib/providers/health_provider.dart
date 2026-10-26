import "package:flutter_riverpod/flutter_riverpod.dart";

import "/services/health_service.dart";

class HealthState {
  final HealthStatus status;
  const HealthState({this.status = const HealthStatus()});
}

class HealthNotifier extends Notifier<HealthState> {
  @override
  HealthState build() {
    Future.microtask(checkHealth);
    return const HealthState();
  }

  Future<void> checkHealth() async {
    final status = await ref.read(healthServiceProvider).checkHealth();
    state = HealthState(status: status);
  }
}

final healthServiceProvider = Provider<HealthService>((ref) => HealthService());

final healthProvider = NotifierProvider<HealthNotifier, HealthState>(
  HealthNotifier.new,
);

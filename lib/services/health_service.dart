import "/network/endpoints.dart";
import "/network/requests.dart";

class HealthStatus {
  final bool isOnline;
  final bool isJwtOnline;
  final String? appMessage;
  final String? jwtMessage;
  final int latencyMs;
  final DateTime lastChecked;

  const HealthStatus({
    required this.isOnline,
    required this.isJwtOnline,
    this.appMessage,
    this.jwtMessage,
    this.latencyMs = 0,
    required this.lastChecked,
  });

  factory HealthStatus.initial() {
    return HealthStatus(
      isOnline: false,
      isJwtOnline: false,
      lastChecked: DateTime.now(),
    );
  }
}

class HealthService with HTTPRequests {
  Future<HealthStatus> checkAllHealth() async {
    final stopwatch = Stopwatch()..start();
    Map<String, dynamic>? appRes;
    Map<String, dynamic>? jwtRes;

    try {
      appRes = await getRequest(apiEndpoint(ApiEndpoints.health));
    } catch (_) {}

    try {
      jwtRes = await getRequest(apiEndpoint(ApiEndpoints.jwtHealth));
    } catch (_) {}

    stopwatch.stop();

    final isOnline = appRes != null && appRes["message"] == "Server running";
    final isJwtOnline = jwtRes != null;

    return HealthStatus(
      isOnline: isOnline,
      isJwtOnline: isJwtOnline,
      appMessage: appRes?["message"]?.toString() ?? "Offline",
      jwtMessage:
          jwtRes?["message"]?.toString() ??
          (isJwtOnline ? "Active" : "Unavailable"),
      latencyMs: stopwatch.elapsedMilliseconds,
      lastChecked: DateTime.now(),
    );
  }
}

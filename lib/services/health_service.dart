import "/network/endpoints.dart";
import "/network/requests.dart";

class HealthStatus {
  final bool isOnline;
  const HealthStatus({this.isOnline = false});
}

class HealthService with HTTPRequests {
  Future<HealthStatus> checkHealth() async {
    try {
      final res = await getRequest(Endpoints.health);
      return HealthStatus(
        isOnline: res != null && res["message"] == "Server running",
      );
    } catch (_) {
      return const HealthStatus(isOnline: false);
    }
  }
}

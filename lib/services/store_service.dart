import "/models/store_model.dart";
import "/network/api_response.dart";
import "/network/endpoints.dart";
import "/network/requests.dart";

class StoreService with HTTPRequests {
  /// Fetch registered store branches from GET /account/store/get
  Future<ApiResponse<List<StoreModel>>> fetchStores() async {
    final res = await getRequest(apiEndpoint(ApiEndpoints.storeGet));

    if (res != null) {
      final dynamic rawList = res["data"] ?? res["stores"];
      if (rawList is List) {
        final List<StoreModel> stores = rawList
            .map((item) => StoreModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        return ApiResponse.success(stores);
      }
      return ApiResponse.success([]);
    }

    return ApiResponse.error("Failed to load stores from server");
  }
}

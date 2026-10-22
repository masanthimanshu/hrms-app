import "/models/store_model.dart";
import "/network/api_response.dart";
import "/network/endpoints.dart";
import "/network/requests.dart";

class StoreService with HTTPRequests {
  /// Fetch all registered stores from GET /account/store/get
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

  /// Create a new physical store branch via POST /account/store/create
  Future<ApiResponse<Map<String, dynamic>>> createStore({
    required String name,
    required String address,
    required String latitude,
    required String longitude,
  }) async {
    final payload = {
      "name": name.trim(),
      "address": address.trim(),
      "latitude": latitude.trim(),
      "longitude": longitude.trim(),
    };

    final res = await postRequest(
      url: apiEndpoint(ApiEndpoints.storeCreate),
      payload: payload,
    );

    if (res != null &&
        (res["status"] == "Store created successfully" ||
            res["status"] == "Success" ||
            res["message"] == "Store created successfully")) {
      return ApiResponse.success(res, message: "Store created successfully");
    }

    final errorMessage = res?["message"]?.toString() ??
        res?["error"]?.toString() ??
        "Failed to create store. Please check fields.";
    return ApiResponse.error(errorMessage);
  }
}

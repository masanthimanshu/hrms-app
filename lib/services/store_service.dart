import "/models/store_model.dart";
import "/network/api_response.dart";
import "/network/endpoints.dart";
import "/network/requests.dart";

class StoreService with HTTPRequests {
  Future<ApiResponse<List<StoreModel>>> fetchStores() async {
    final res = await getRequest(Endpoints.storeGet);
    final raw = res?["data"] ?? res?["stores"];
    if (raw is List) {
      final stores = raw
          .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return ApiResponse.success(stores);
    }
    return ApiResponse.error("Failed to load stores");
  }
}

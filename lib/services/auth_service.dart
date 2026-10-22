import "package:hive_flutter/hive_flutter.dart";

import "/models/user_model.dart";
import "/network/api_response.dart";
import "/network/endpoints.dart";
import "/network/requests.dart";

class AuthService with HTTPRequests {
  Box? get _box => Hive.isBoxOpen("myBox") ? Hive.box("myBox") : null;

  /// Check whether valid auth token exists in local storage
  bool get hasSavedToken {
    final token = _box?.get("authToken");
    return token != null && token.toString().isNotEmpty;
  }

  /// Get currently active auth token
  String? get currentAuthToken => _box?.get("authToken")?.toString();

  /// Get currently active refresh token
  String? get currentRefreshToken => _box?.get("refreshToken")?.toString();

  /// Get saved user email
  String? get currentEmail => _box?.get("userEmail")?.toString();

  /// Get saved user name
  String? get currentUserName => _box?.get("userName")?.toString();

  /// Get saved store ID
  String? get currentStoreId => _box?.get("userStoreId")?.toString();

  /// Authenticate employee via POST /account/auth/login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final payload = {
      "email": email.trim(),
      "password": password.trim(),
    };

    final res = await postRequest(
      url: apiEndpoint(ApiEndpoints.authLogin),
      payload: payload,
    );

    if (res != null && res["status"] == "Success" && res["authToken"] != null) {
      await _box?.put("authToken", res["authToken"].toString());
      await _box?.put("refreshToken", res["refreshToken"].toString());
      await _box?.put("userEmail", email.trim());
      await _box?.put("loginTimestamp", DateTime.now().toIso8601String());

      return ApiResponse.success(res, message: "Authentication successful");
    }

    final errorMessage = res?["message"]?.toString() ??
        res?["error"]?.toString() ??
        "Invalid email or password";
    return ApiResponse.error(errorMessage);
  }

  /// Verify session validity via GET /secure/verify
  Future<bool> verifyToken() async {
    try {
      final res = await getRequest(apiEndpoint(ApiEndpoints.verifyToken));
      return res != null &&
          (res["message"] == "User is valid" || res["status"] == "Success");
    } catch (_) {
      return false;
    }
  }

  /// Refresh token pair via GET /jwt/refresh
  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    final res = await getRequest(apiEndpoint(ApiEndpoints.refreshToken));
    if (res != null && res["authToken"] != null) {
      await _box?.put("authToken", res["authToken"].toString());
      if (res["refreshToken"] != null) {
        await _box?.put("refreshToken", res["refreshToken"].toString());
      }
      return ApiResponse.success(res, message: "Tokens refreshed successfully");
    }
    return ApiResponse.error(res?["message"]?.toString() ?? "Failed to refresh token");
  }

  /// Sign out and clear stored session tokens
  Future<void> logout() async {
    await _box?.delete("authToken");
    await _box?.delete("refreshToken");
    await _box?.delete("userEmail");
    await _box?.delete("userName");
    await _box?.delete("userStoreId");
  }

  /// Retrieve current user info model
  UserModel? getCurrentUser() {
    final email = currentEmail;
    if (email == null || email.isEmpty) return null;
    return UserModel(
      id: _box?.get("userId")?.toString() ?? "u-${email.hashCode.abs()}",
      name: currentUserName ?? email.split("@").first.replaceAll(".", " ").toUpperCase(),
      email: email,
      storeId: currentStoreId ?? "",
      isValid: true,
    );
  }
}

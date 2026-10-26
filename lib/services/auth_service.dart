import "dart:convert";

import "package:hive_flutter/hive_flutter.dart";

import "/models/user_model.dart";
import "/network/api_response.dart";
import "/network/endpoints.dart";
import "/network/requests.dart";

class AuthService with HTTPRequests {
  Box? get _box => Hive.isBoxOpen("myBox") ? Hive.box("myBox") : null;

  bool get hasSavedToken =>
      _box?.get("authToken")?.toString().isNotEmpty ?? false;

  String? get currentAuthToken => _box?.get("authToken")?.toString();
  String? get currentRefreshToken => _box?.get("refreshToken")?.toString();
  String? get currentEmail => _box?.get("userEmail")?.toString();
  String? get currentUserName => _box?.get("userName")?.toString();
  String? get currentUserId => _box?.get("userId")?.toString();
  String? get currentStoreId => _box?.get("userStoreId")?.toString();

  /// Authenticate employee via POST /account/auth/login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final res = await postRequest(
      url: apiEndpoint(ApiEndpoints.authLogin),
      payload: {"email": email.trim(), "password": password.trim()},
    );

    if (res != null && res["authToken"] != null) {
      final token = res["authToken"].toString();
      await _box?.put("authToken", token);
      await _box?.put("refreshToken", res["refreshToken"]?.toString() ?? "");
      await _box?.put("userEmail", email.trim());

      _extractJwtClaims(token);
      await _resolveUserProfile(email.trim());

      return ApiResponse.success(res, message: "Authentication successful");
    }

    return ApiResponse.error(
      res?["message"]?.toString() ?? "Invalid email or password",
    );
  }

  void _extractJwtClaims(String token) {
    try {
      final parts = token.split(".");
      if (parts.length == 3) {
        final decoded = utf8.decode(
          base64Url.decode(base64Url.normalize(parts[1])),
        );
        final data = jsonDecode(decoded);
        if (data is Map) {
          final id = data["_id"] ?? data["id"] ?? data["userId"];
          if (id != null) {
            _box?.put("userId", id.toString());
          }
          if (data["storeId"] != null) {
            _box?.put("userStoreId", data["storeId"].toString());
          }
          if (data["name"] != null) {
            _box?.put("userName", data["name"].toString());
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _resolveUserProfile(String email) async {
    try {
      final res = await getRequest(apiEndpoint(ApiEndpoints.authUsers));
      final list = res?["data"];
      if (list is List) {
        final match = list.firstWhere(
          (u) =>
              u is Map &&
              u["email"]?.toString().toLowerCase() == email.toLowerCase(),
          orElse: () => null,
        );
        if (match is Map) {
          if (match["_id"] != null) {
            await _box?.put("userId", match["_id"].toString());
          }
          if (match["name"] != null) {
            await _box?.put("userName", match["name"].toString());
          }
          if (match["storeId"] != null) {
            await _box?.put("userStoreId", match["storeId"].toString());
          }
        }
      }
    } catch (_) {}
  }

  /// Verify session validity via GET /secure/verify
  Future<bool> verifyToken() async {
    try {
      final res = await getRequest(apiEndpoint(ApiEndpoints.verifyToken));
      return res != null &&
          (res["status"] == "Success" ||
              res["valid"] == true ||
              res["message"] == "User is valid");
    } catch (_) {
      return false;
    }
  }

  /// Refresh token pair via GET /jwt/refresh
  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    final res = await getRequest(apiEndpoint(ApiEndpoints.refreshToken));
    if (res != null && res["authToken"] != null) {
      final token = res["authToken"].toString();
      await _box?.put("authToken", token);
      if (res["refreshToken"] != null) {
        await _box?.put("refreshToken", res["refreshToken"].toString());
      }
      _extractJwtClaims(token);
      return ApiResponse.success(res);
    }
    return ApiResponse.error(
      res?["message"]?.toString() ?? "Failed to refresh token",
    );
  }

  /// Sign out and clear stored session tokens
  Future<void> logout() async {
    await _box?.delete("authToken");
    await _box?.delete("refreshToken");
    await _box?.delete("userEmail");
    await _box?.delete("userName");
    await _box?.delete("userId");
    await _box?.delete("userStoreId");
  }

  /// Retrieve current user model
  UserModel? getCurrentUser() {
    final email = currentEmail;
    if (email == null || email.isEmpty) return null;
    return UserModel(
      id: currentUserId ?? "u-${email.hashCode.abs()}",
      name:
          currentUserName ??
          email.split("@").first.replaceAll(".", " ").toUpperCase(),
      email: email,
      storeId: currentStoreId ?? "",
      isValid: true,
    );
  }
}

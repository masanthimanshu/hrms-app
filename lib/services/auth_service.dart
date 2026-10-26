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

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final res = await postRequest(
      url: Endpoints.authLogin,
      payload: {"email": email.trim(), "password": password.trim()},
    );

    if (res != null && res["authToken"] != null) {
      final token = res["authToken"].toString();
      final refresh = (res["refreshToken"] ?? res["refresh"] ?? token)
          .toString();
      await _box?.put("authToken", token);
      await _box?.put("refreshToken", refresh);
      await _box?.put("accountId", kDefaultAccountId);
      await _box?.put("userEmail", email.trim());

      _extractJwtClaims(token);
      await fetchUserProfile(email: email.trim());

      return ApiResponse.success(res, message: "Authentication successful");
    }

    return ApiResponse.error(
      res?["error"]?.toString() ??
          res?["message"]?.toString() ??
          "Invalid email or password",
    );
  }

  void _extractJwtClaims(String token) {
    try {
      final parts = token.split(".");
      if (parts.length == 3) {
        final decoded = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        );
        if (decoded is Map) {
          final payloadData = decoded["data"] is Map
              ? decoded["data"] as Map
              : null;
          final id =
              decoded["_id"] ??
              decoded["id"] ??
              decoded["userId"] ??
              payloadData?["uid"] ??
              payloadData?["_id"] ??
              payloadData?["id"] ??
              payloadData?["userId"];
          if (id != null) _box?.put("userId", id.toString());

          final storeId = decoded["storeId"] ?? payloadData?["storeId"];
          if (storeId != null) {
            _box?.put("userStoreId", storeId.toString());
          }

          final name = decoded["name"] ?? payloadData?["name"];
          if (name != null) {
            _box?.put("userName", name.toString());
          }
        }
      }
    } catch (_) {}
  }

  Future<UserModel?> fetchUserProfile({String? email, String? userId}) async {
    try {
      final res = await getRequest(Endpoints.authUsers);
      final list = res?["data"];
      if (list is List) {
        final targetEmail = (email ?? currentEmail)?.trim().toLowerCase();
        final targetId = (userId ?? currentUserId)?.trim();

        final match = list.firstWhere((u) {
          if (u is! Map) return false;
          final uEmail = u["email"]?.toString().trim().toLowerCase();
          final uId = u["_id"]?.toString().trim() ?? u["id"]?.toString().trim();
          if (targetEmail != null &&
              targetEmail.isNotEmpty &&
              uEmail == targetEmail) {
            return true;
          }
          if (targetId != null && targetId.isNotEmpty && uId == targetId) {
            return true;
          }
          return false;
        }, orElse: () => null);

        if (match is Map) {
          final user = UserModel.fromJson(Map<String, dynamic>.from(match));
          if (user.id.isNotEmpty) await _box?.put("userId", user.id);
          if (user.name.isNotEmpty) await _box?.put("userName", user.name);
          if (user.email.isNotEmpty) await _box?.put("userEmail", user.email);
          if (user.storeId.isNotEmpty) {
            await _box?.put("userStoreId", user.storeId);
          }
          return user;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<bool> verifyToken() async {
    try {
      final res = await getRequest(Endpoints.verifyToken);
      return res != null &&
          (res["status"] == "Success" ||
              res["valid"] == true ||
              res["message"] == "User is valid");
    } catch (_) {
      return false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    final res = await getRequest(Endpoints.refreshToken);
    if (res != null && res["authToken"] != null) {
      final token = res["authToken"].toString();
      final refresh = (res["refreshToken"] ?? res["refresh"] ?? token)
          .toString();
      await _box?.put("authToken", token);
      await _box?.put("refreshToken", refresh);
      await _box?.put("accountId", kDefaultAccountId);
      _extractJwtClaims(token);
      await fetchUserProfile();
      return ApiResponse.success(res);
    }
    return ApiResponse.error(
      res?["error"]?.toString() ??
          res?["message"]?.toString() ??
          "Failed to refresh token",
    );
  }

  Future<void> logout() async {
    await _box?.delete("authToken");
    await _box?.delete("refreshToken");
    await _box?.delete("userEmail");
    await _box?.delete("userName");
    await _box?.delete("userId");
    await _box?.delete("userStoreId");
  }

  UserModel? getCurrentUser() {
    final email = currentEmail;
    if (email == null || email.isEmpty) return null;
    return UserModel(
      id: currentUserId ?? "",
      name: currentUserName ?? "",
      email: email,
      storeId: currentStoreId ?? "",
    );
  }
}

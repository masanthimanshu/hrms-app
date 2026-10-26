import "dart:convert";
import "dart:io";

import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";

import "endpoints.dart";
import "interceptor.dart";

const String kDefaultAccountId = "iZnfZHVLwN8XvFKKuq56UvNdDbX83rhq";

mixin HTTPRequests {
  static Map<String, dynamic> getAuthHeaders() {
    String accountId = kDefaultAccountId;
    String authToken = "";
    String refreshToken = "";

    try {
      if (Hive.isBoxOpen("myBox")) {
        final box = Hive.box("myBox");
        final saved = box.get("accountId")?.toString().trim();
        if (saved != null && saved.isNotEmpty) accountId = saved;
        authToken = box.get("authToken")?.toString().trim() ?? "";
        refreshToken = box.get("refreshToken")?.toString().trim() ?? "";
        if (refreshToken.isEmpty && authToken.isNotEmpty) {
          refreshToken = authToken;
        }
      }
    } catch (_) {}

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "account": accountId,
      "authorization": authToken,
      "refresh": refreshToken,
    };
  }

  Dio get _dioHandler {
    final dio = Dio(
      BaseOptions(
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        baseUrl: Endpoints.baseUrl,
      ),
    );
    dio.interceptors.add(DioInterceptor(dioHandler: dio));
    return dio;
  }

  Map<String, dynamic>? _formatData(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        if (decoded is List) return {"data": decoded};
        return {"message": data};
      } catch (_) {
        return {"message": data};
      }
    }
    if (data is List) return {"data": data};
    return null;
  }

  @protected
  Future<Map<String, dynamic>?> getRequest(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await _dioHandler.get(url, queryParameters: queryParameters);
      debugPrint("[GET $url] (${res.statusCode}) - ${res.data}");
      return _formatData(res.data);
    } on DioException catch (e) {
      debugPrint(
        "[GET error $url] (${e.response?.statusCode}) - ${e.response?.data}",
      );
      return _formatData(e.response?.data);
    } catch (e) {
      debugPrint("[GET exception $url] $e");
      return null;
    }
  }

  @protected
  Future<Map<String, dynamic>?> postRequest({
    required Map<String, dynamic> payload,
    required String url,
  }) async {
    try {
      debugPrint("[POST $url] - payload: $payload");
      final res = await _dioHandler.post(url, data: payload);
      debugPrint("[POST $url] (${res.statusCode}) - ${res.data}");
      return _formatData(res.data);
    } on DioException catch (e) {
      debugPrint(
        "[POST error $url] (${e.response?.statusCode}) - ${e.response?.data}",
      );
      return _formatData(e.response?.data);
    } catch (e) {
      debugPrint("[POST exception $url] $e");
      return null;
    }
  }

  @protected
  Future<bool> uploadBinaryToUrl({
    required String url,
    required List<int> bytes,
    String contentType = "image/webp",
  }) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 30);
      final uri = Uri.parse(url);

      var request = await client.putUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, contentType);
      request.contentLength = bytes.length;
      request.add(bytes);

      var response = await request.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      // If 403, retry without Content-Type header in case presigned URL signed host only
      if (response.statusCode == 403) {
        request = await client.putUrl(uri);
        request.contentLength = bytes.length;
        request.add(bytes);
        response = await request.close();
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        }
      }

      final errorBody = await response.transform(utf8.decoder).join();
      debugPrint(
        "[PUT S3] Failed with status ${response.statusCode}: $errorBody",
      );
      return false;
    } catch (e) {
      debugPrint("[PUT S3] Exception during upload: $e");
      return false;
    }
  }
}

import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";

import "endpoints.dart";
import "interceptor.dart";

const String kDefaultAccountId = "iZnfZHVLwN8XvFKKuq56UvNdDbX83rhq";

mixin HTTPRequests {
  BaseOptions get _baseOptions {
    String accountId = kDefaultAccountId;
    try {
      if (Hive.isBoxOpen("myBox")) {
        final saved = Hive.box("myBox").get("accountId");
        if (saved != null && saved.toString().isNotEmpty) {
          accountId = saved.toString();
        }
      }
    } catch (_) {}

    return BaseOptions(
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      baseUrl: apiEndpoint(ApiEndpoints.baseUrl),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "account": accountId,
      },
    );
  }

  Dio get _dioHandler {
    final dio = Dio(_baseOptions);
    dio.interceptors.add(DioInterceptor(dioHandler: dio));
    return dio;
  }

  @protected
  Future<Map<String, dynamic>?> getRequest(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    debugPrint("[GET] $url");
    try {
      final res = await _dioHandler.get(
        url,
        queryParameters: queryParameters,
      );
      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! <= 208) {
        if (res.data is Map<String, dynamic>) {
          return res.data as Map<String, dynamic>;
        } else if (res.data is List) {
          return {"data": res.data};
        }
        return {"data": res.data};
      } else {
        debugPrint("GET failed: ${res.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      debugPrint("Dio GET error: ${e.response?.statusCode} - ${e.response?.data}");
      if (e.response?.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("Error during GET request: $e");
      return null;
    }
  }

  @protected
  Future<Map<String, dynamic>?> postRequest({
    required Map<String, dynamic> payload,
    required String url,
  }) async {
    debugPrint("[POST] $url - data: $payload");
    try {
      final res = await _dioHandler.post(url, data: payload);
      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! <= 208) {
        if (res.data is Map<String, dynamic>) {
          return res.data as Map<String, dynamic>;
        }
        return {"data": res.data};
      } else {
        debugPrint("POST failed: ${res.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      debugPrint("Dio POST error: ${e.response?.statusCode} - ${e.response?.data}");
      if (e.response?.data is Map<String, dynamic>) {
        return e.response!.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("Error during POST request: $e");
      return null;
    }
  }
}

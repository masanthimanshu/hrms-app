import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";

import "endpoints.dart";
import "requests.dart";

Box? get _hive => Hive.isBoxOpen("myBox") ? Hive.box("myBox") : null;

class DioInterceptor extends Interceptor {
  const DioInterceptor({required this.dioHandler});

  final Dio dioHandler;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final dynamic authToken = _hive?.get("authToken");
    final dynamic refreshToken = _hive?.get("refreshToken");
    final dynamic customAccount = _hive?.get("accountId");

    if (authToken != null && authToken.toString().isNotEmpty) {
      options.headers["authorization"] = authToken.toString();
    }
    if (refreshToken != null && refreshToken.toString().isNotEmpty) {
      options.headers["refresh"] = refreshToken.toString();
    }
    if (customAccount != null && customAccount.toString().isNotEmpty) {
      options.headers["account"] = customAccount.toString();
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final res = err.response?.data;
    final code = err.response?.statusCode;
    final isRefreshEndpoint = err.requestOptions.path.contains(
      apiEndpoint(ApiEndpoints.refreshToken),
    );

    if (code == 401 &&
        !isRefreshEndpoint &&
        res is Map &&
        (res["message"] == "Invalid token" ||
            res["message"] == "Token expired")) {
      try {
        final newAuthToken = await _InterceptorMethods().refreshToken();
        if (newAuthToken != null) {
          err.requestOptions.headers["authorization"] = newAuthToken;
          final response = await _InterceptorMethods().retryRequest(
            err.requestOptions,
            dioHandler,
          );
          return handler.resolve(response);
        }
      } catch (e) {
        debugPrint("Error occurred with Interceptor token refresh: $e");
      }
    }

    super.onError(err, handler);
  }
}

class _InterceptorMethods with HTTPRequests {
  Future<String?> refreshToken() async {
    final data = await getRequest(apiEndpoint(ApiEndpoints.refreshToken));
    if (data != null && data["authToken"] != null) {
      final token = data["authToken"].toString();
      await _hive?.put("authToken", token);
      if (data["refreshToken"] != null) {
        await _hive?.put("refreshToken", data["refreshToken"].toString());
      }
      return token;
    }
    return null;
  }

  Future<Response<dynamic>> retryRequest(
    RequestOptions requestOptions,
    Dio dioHandler,
  ) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return dioHandler.request(
      requestOptions.path,
      options: options,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }
}

import "package:dio/dio.dart";
import "package:hive_flutter/hive_flutter.dart";

import "endpoints.dart";
import "requests.dart";

Box? get _hive => Hive.isBoxOpen("myBox") ? Hive.box("myBox") : null;

class DioInterceptor extends Interceptor {
  const DioInterceptor({required this.dioHandler});

  final Dio dioHandler;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final auth = _hive?.get("authToken")?.toString();
    final refresh = _hive?.get("refreshToken")?.toString();
    final account = _hive?.get("accountId")?.toString();

    if (auth != null && auth.isNotEmpty) {
      options.headers["authorization"] = auth;
    }
    if (refresh != null && refresh.isNotEmpty) {
      options.headers["refresh"] = refresh;
    }
    if (account != null && account.isNotEmpty) {
      options.headers["account"] = account;
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isRefresh = err.requestOptions.path.contains(
      apiEndpoint(ApiEndpoints.refreshToken),
    );

    if (err.response?.statusCode == 401 && !isRefresh) {
      try {
        final newToken = await _InterceptorMethods().refreshToken();
        if (newToken != null) {
          err.requestOptions.headers["authorization"] = newToken;
          final response = await dioHandler.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          return handler.resolve(response);
        }
      } catch (_) {}
    }

    super.onError(err, handler);
  }
}

class _InterceptorMethods with HTTPRequests {
  Future<String?> refreshToken() async {
    final res = await getRequest(apiEndpoint(ApiEndpoints.refreshToken));
    final token = res?["authToken"]?.toString();
    if (token != null) {
      await _hive?.put("authToken", token);
      if (res?["refreshToken"] != null) {
        await _hive?.put("refreshToken", res!["refreshToken"].toString());
      }
      return token;
    }
    return null;
  }
}

import "package:dio/dio.dart";
import "package:hive_flutter/hive_flutter.dart";

import "endpoints.dart";
import "requests.dart";

class DioInterceptor extends Interceptor {
  final Dio dioHandler;
  const DioInterceptor({required this.dioHandler});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll(HTTPRequests.getAuthHeaders());
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isRefresh = err.requestOptions.path.contains(Endpoints.refreshToken);

    if (err.response?.statusCode == 401 && !isRefresh) {
      try {
        final res = await dioHandler.get(Endpoints.refreshToken);
        final token = res.data?["authToken"]?.toString();
        if (token != null) {
          final box = Hive.isBoxOpen("myBox") ? Hive.box("myBox") : null;
          final refresh =
              (res.data?["refreshToken"] ?? res.data?["refresh"] ?? token)
                  .toString();
          await box?.put("authToken", token);
          await box?.put("refreshToken", refresh);
          await box?.put("accountId", kDefaultAccountId);

          err.requestOptions.headers.addAll(HTTPRequests.getAuthHeaders());
          final retryResponse = await dioHandler.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          return handler.resolve(retryResponse);
        }
      } catch (_) {}
    }

    super.onError(err, handler);
  }
}

/// Standardized API response wrapper
class ApiResponse<T> {
  final bool isSuccess;
  final int? statusCode;
  final T? data;
  final String? message;

  const ApiResponse({
    required this.isSuccess,
    this.statusCode,
    this.data,
    this.message,
  });

  factory ApiResponse.success(T? data, {int? statusCode, String? message}) {
    return ApiResponse(
      isSuccess: true,
      statusCode: statusCode ?? 200,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode, T? data}) {
    return ApiResponse(
      isSuccess: false,
      statusCode: statusCode ?? 400,
      data: data,
      message: message,
    );
  }
}

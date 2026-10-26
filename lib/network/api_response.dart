class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;

  const ApiResponse({required this.isSuccess, this.data, this.message});

  factory ApiResponse.success(T? data, {String? message}) =>
      ApiResponse(isSuccess: true, data: data, message: message);

  factory ApiResponse.error(String message, {T? data}) =>
      ApiResponse(isSuccess: false, data: data, message: message);
}

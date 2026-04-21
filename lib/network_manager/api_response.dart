final class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorMessage;

  ApiResponse.success({this.data})
      : errorMessage = null,
        success = true;

  ApiResponse.failure(this.errorMessage)
      : data = null,
        success = false;
}

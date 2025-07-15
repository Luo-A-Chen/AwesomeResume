import 'package:dio/dio.dart';

class NetRequester {
  static final _dio = Dio();

  static void cleanOptions() => _dio.options = BaseOptions();

  static Future<Response?> get(
    String? url, {
    Map<String, dynamic>? queryParams,
    Map<String, String> headers = const {},
  }) async {
    if (url == null) return null;
    final response = await _dio.get(url,
        queryParameters: queryParams, options: Options(headers: headers));
    return response;
  }

  static void setBaseUrl(String baseUrl) => _dio.options.baseUrl = baseUrl;

  static void setOptions(BaseOptions options) => _dio.options = options;
}

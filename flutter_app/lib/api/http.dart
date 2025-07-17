import 'package:dio/dio.dart';

class Http {
  static final _dio = Dio();

  static void cleanOptions() => _dio.options = BaseOptions();

  static Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    final response = await _dio.get(url,
        queryParameters: queryParams, options: Options(headers: headers));
    return response;
  }

  static void setBaseUrl(String baseUrl) => _dio.options.baseUrl = baseUrl;

  static void setOptions(BaseOptions options) => _dio.options = options;
}

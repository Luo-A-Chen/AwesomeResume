import 'package:dio/dio.dart';

class Http {
  static final dio = Dio();

  static void cleanOptions() => dio.options = BaseOptions();

  static Future<Response> get(
    String url, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) async {
    final response = await dio.get(url,
        queryParameters: params, options: Options(headers: headers));
    return response;
  }

  static void setBaseUrl(String baseUrl) => dio.options.baseUrl = baseUrl;

  static void setOptions(BaseOptions options) => dio.options = options;
}

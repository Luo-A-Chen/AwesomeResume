import 'package:dio/dio.dart';

import '../api/http.dart';
import 'comment.dart';

class CommentRequest {
  Future<CommentResponse> comments({
    required num oid,
    num type = 1,
    num mode = 2,
    required String nextOffset,
  }) async {
    Map<String, dynamic> params = {
      'oid': oid,
      'type': type,
      'pagination_str': '{"offset":"${nextOffset.replaceAll('"', '\\"')}"}',
      'mode': mode,
    };
    final res = await Http.dio.get(
      'https://api.bilibili.com/x/v2/reply/main',
      queryParameters: params,
      options: Options(headers: {'cookie': "buvid3= ; b_nut= ; sid= "}),
    );
    print('请求:');
    print(res.realUri);
    print(res.headers);
    print('请求游标:');
    print(res.data['data']['cursor']);
    return CommentResponse.fromJson(res.data);
  }
}

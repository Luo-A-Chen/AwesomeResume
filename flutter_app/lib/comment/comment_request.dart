import 'package:dio/dio.dart';

import '../api/http.dart';
import '../user/auth_provider.dart';
import 'comment.dart';

enum CommentRequestMode {
  hot(name: '按热度', title: '热门评论'),
  hotAndTime(name: '默认排序', title: '评论'),
  time(name: '按时间', title: '最新评论');

  final String name;
  final String title;
  const CommentRequestMode({
    required this.name,
    required this.title,
  });
}

class CommentRequest {
  Future<CommentResponse> comments({
    required num oid,
    num type = 1,
    CommentRequestMode mode = CommentRequestMode.hot,
    required String nextOffset,
  }) async {
    Map<String, dynamic> params = {
      'oid': oid,
      'type': type,
      'pagination_str': '{"offset":"${nextOffset.replaceAll('"', '\\"')}"}',
      'mode': mode.index,
    };
    final headers = AuthProvider().getAuthHeaders();
    final res = await Http.dio.get(
      'https://api.bilibili.com/x/v2/reply/main',
      queryParameters: params,
      options: Options(headers: headers),
    );
    return CommentResponse.fromJson(res.data);
  }
}

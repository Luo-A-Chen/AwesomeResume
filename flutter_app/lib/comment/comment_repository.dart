import 'package:dio/dio.dart';
import 'package:loading_more_list/loading_more_list.dart';

import 'comment.dart';
import 'comment_request.dart';

class CommmentRepository extends LoadingMoreBase<Reply> {
  String nextOffset = '';
  bool _hasMore = false;
  final num oid;
  CommentRequestMode mode = CommentRequestMode.hot;

  CommmentRepository({required this.oid});

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    var success = false;
    var replyRequest = CommentRequest();
    try {
      final commentRes = await replyRequest.comments(
        oid: oid,
        nextOffset: nextOffset,
        mode: mode,
      );
      nextOffset = commentRes.data.cursor.paginationReply.nextOffset ?? '';
      _hasMore = !commentRes.data.cursor.isEnd;
      addAll(commentRes.data.replies);
      success = true;
    } on DioException catch (e) {
      print('评论加载失败: $e');
      print(e.response?.data);
      _hasMore = true;
    } catch (e) {
      print('评论加载失败: $e');
      _hasMore = true;
    }
    return success;
  }

  @override
  bool get hasMore => _hasMore;

  @override
  Future<bool> refresh([notifyStateChanged = true]) async {
    _hasMore = true;
    nextOffset = '';
    return await super.refresh(notifyStateChanged);
  }
}

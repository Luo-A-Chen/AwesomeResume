import 'package:loading_more_list/loading_more_list.dart';

import 'comment.dart';
import 'comment_request.dart';

class CommmentRepository extends LoadingMoreBase<Reply> {
  String nextOffset = '';
  bool _hasMore = false;
  final num oid;

  CommmentRepository({required this.oid});

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    var success = false;
    print('加载第 页评论');
    var replyRequest = CommentRequest();
    final commentRes =
        await replyRequest.comments(oid: oid, nextOffset: nextOffset);
    nextOffset = commentRes.data.cursor.paginationReply.nextOffset ?? '';
    print('评论请求测试');
    print(commentRes.data.cursor.toJson());
    _hasMore = !commentRes.data.cursor.isEnd;
    addAll(commentRes.data.replies);
    success = true;
    return success;
  }

  @override
  bool get hasMore => _hasMore;

  @override
  Future<bool> refresh([notifyStateChanged = true]) async {
    _hasMore = true;
    return await super.refresh(notifyStateChanged);
  }
}

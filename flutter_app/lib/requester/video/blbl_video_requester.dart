part of '../requester.dart';

class _BlblVideoRequester extends VideoRequester {
  @override
  Future<List<Video>> getRcmdVideos(
      {required int pageIdx, int count = 18}) async {
    var res = await Http.get(
      '/web-interface/wbi/index/top/feed/rcmd',
      queryParams: {
        'fresh_idx': pageIdx,
        'ps': count,
      },
    );
    final rcmdVideosRes = RcmdVideosResponse.fromJson(res.data);
    // TODO 处理请求错误
    return rcmdVideosRes.data.items;
  }
}
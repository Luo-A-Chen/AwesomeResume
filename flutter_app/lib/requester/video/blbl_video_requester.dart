part of '../requester.dart';

class BlblVideoRequester extends VideoRequester {
  Future<Map<String, dynamic>> getVideoInfo(String bvid) async {
    final res = await Http.get('/web-interface/view', params: {'bvid': bvid});
    return res.data['data'];
  }

  @override
  Future<List<Video>> getRcmdVideos(
      {required int pageIdx, int count = 18}) async {
    var res = await Http.get(
      '/web-interface/wbi/index/top/feed/rcmd',
      params: {
        'fresh_idx': pageIdx,
        'ps': count,
      },
    );
    final rcmdVideosRes = RcmdVideosResponse.fromJson(res.data);
    // TODO 处理请求错误
    return rcmdVideosRes.data.items;
  }
}

import '../../api/http.dart';
import '../../user/auth_provider.dart';
import '../video_response.dart';
import '../video_provider.dart';

class BlblVideoProvider extends VideoProvider {
  Future<Map<String, dynamic>> getVideoInfo(String bvid) async {
    final res = await Http.get('/web-interface/view', params: {'bvid': bvid});
    return res.data['data'];
  }

  @override
  Future<List<Video>> getRcmdVideos(
      {required int pageIdx, int count = 18}) async {
    var res = await Http.get(
      '/web-interface/wbi/index/top/feed/rcmd',
      params: {'fresh_idx': pageIdx, 'ps': count},
      headers: AuthProvider().getAuthHeaders(),
    );
    final rcmdVideosRes = RcmdVideoRes.fromJson(res.data);
    // TODO 处理请求错误
    return rcmdVideosRes.data.items;
  }
}

import 'package:loading_more_list/loading_more_list.dart';

import '../../api/net_request.dart';
import '../settings/settings.dart';
import '../video/video_response.dart';

class VideoRepository extends LoadingMoreBase<Video> {
  int freshIdx = 1;
  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    var server = Settings.instance.server;
    print('加载第$freshIdx页视频');
    var res = await NetRequest.get(server!.videoUrl.homeRcmd,
        queryParams: {'fresh_idx': freshIdx++});
    final rcmdVideosRes = RcmdVideosResponse.fromJson(res?.data);
    // TODO 处理请求错误
    addAll(rcmdVideosRes.data.items);
    print('加载了${rcmdVideosRes.data.items.length}条视频');
    return true;
  }

  @override
  Future<bool> refresh([notifyStateChanged = true]) {
    freshIdx = 1;
    return super.refresh(notifyStateChanged);
  }
}

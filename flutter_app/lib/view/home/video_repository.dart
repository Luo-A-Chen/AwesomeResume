import 'package:loading_more_list/loading_more_list.dart';

import '../../api/toast.dart';
import '../settings/settings.dart';
import '../video/video_response.dart';

class VideoRepository extends LoadingMoreBase<Video> {
  final _settings = Settings.instance;
  int pageIdx = 1;
  bool _hasMore = false;

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    print('加载第$pageIdx页视频');
    final count = 10;
    var videos = <Video>[];
    var success = false;
    try {
      var videoRequester = _settings.dataProvider!.videoProvider;
      if (videoRequester == null) return await Toast.serverUnimplemented();
      videos = await videoRequester.getRcmdVideos(
        pageIdx: pageIdx++,
        count: count,
      );
      addAll(videos);
      print('加载了${videos.length}条视频');
      success = true;
    } catch (e) {
      success = false;
    }
    _hasMore = videos.length == count;
    return success;
  }

  @override
  bool get hasMore => _hasMore;

  @override
  Future<bool> refresh([notifyStateChanged = true]) async {
    pageIdx = 1;
    _hasMore = true;
    return await super.refresh(notifyStateChanged);
  }
}

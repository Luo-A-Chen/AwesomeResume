import 'package:dio/dio.dart';

import '../../api/http.dart';

class SearchService {
  static Future<Response?> searchAll(String keyword) async {
    final res = await Http.get(
      'https://api.bilibili.com/x/web-interface/wbi/search/all/v2',
      queryParams: {'keyword': keyword},
    );
    return res;
  }

  static Future<Response?> searchType(
    String keyword, {
    int page = 1,
    int pageSize = 20,
    String order = 'totalrank',
    String duration = '0',
    String tids = '0',
    required String searchType,
  }) async {
    final res = await Http.get(
      'https://api.bilibili.com/x/web-interface/wbi/search/type',
      queryParams: {
        'keyword': keyword,
        'page': page,
        'pagesize': pageSize,
        'order':
            order, // 排序方式：totalrank(综合), click(播放多), pubdate(新发布), dm(弹幕多), review(评论多), stow(收藏多)
        'duration':
            duration, // 时长：0(全部), 1(10分钟以下), 2(10-30分钟), 3(30-60分钟), 4(60分钟以上)
        'tids': tids, // 分区id
        'search_type':
            searchType, // 搜索类型：video(视频), media_bangumi(番剧), media_ft(影视), live(直播), article(专栏), topic(话题), user(用户)
      },
    );
    return res;
  }
}

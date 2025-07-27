
import '../../../api/toast.dart';
import '../../../api/http.dart';
import '../search_model.dart';
import '../../../data_provider/blbl_provider.dart';
import '../search_provider.dart';

class BlblSearchProvider extends SearchProvider {
  @override
  Future<List<SearchResult>> getTypeSearchResults(
    String keyword, {
    num page = 1,
    String? order,
    num? duration,
    String? tids,
    required String searchType,
  }) async {
    Map<String, dynamic> params = {
      // 搜索类型：video(视频), media_bangumi(番剧), media_ft(影视), live(直播), article(专栏), topic(话题), user(用户)
      'search_type': searchType,
      'keyword': keyword,
      'page': page,
      // 排序方式：totalrank(综合), click(播放多), pubdate(新发布), dm(弹幕多), review(评论多), stow(收藏多)
      'order': order ?? '',
      // 时长：0(全部), 1(10分钟以下), 2(10-30分钟), 3(30-60分钟), 4(60分钟以上)
      if (duration != null) 'duration': duration,
    };
    // 加密参数
    params.addAll(await BlblProvider.makSign(params));
    print('搜索参数:\n $params');
    final res = await Http.get(
      '/web-interface/wbi/search/type',
      params: params,
    );
    final searchRes = SearchResponse.fromJson(res.data);
    print('搜索到${searchRes.data.result.length}个结果');
    return searchRes.data.result;
  }

  @override
  Future<List<SearchResult>> getAllSearchResults() async {
    Toast.serverUnimplemented();
    return [];
  }
}

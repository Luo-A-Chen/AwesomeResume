part of 'requester.dart';

class _BlblRequester extends Requester {
  _BlblRequester()
      : super(
          serverName: '哔哩哔哩',
          videoRequester: _BlblVideoRequester(),
        );

  @override
  Future<void> initHttpCinfig() async {
    Http.cleanOptions();
    final res = await Http.get('https://www.bilibili.com/');
    final cookie = res?.headers['set-cookie']?.join(';');
    // 设置baseUrl和cookie
    Http.setOptions(BaseOptions(
      baseUrl: 'https://api.bilibili.com/x',
      headers: {'cookie': cookie},
    ));
  }
}

class _BlblVideoRequester extends VideoRequester {
  @override
  Future<List<Video>> getRcmdVideos({required int pageIdx, int count = 18}) async {
    var res = await Http.get(
      '/web-interface/wbi/index/top/feed/rcmd',
      queryParams: {
        'fresh_idx': pageIdx,
        'ps': count,
      },
    );
    final rcmdVideosRes = RcmdVideosResponse.fromJson(res?.data);
    // TODO 处理请求错误
    return rcmdVideosRes.data.items;
  }
}

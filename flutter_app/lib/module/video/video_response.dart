import 'dart:convert';

class RcmdVideosResponse {
  /// 状态码
  final int code;
  /// 消息
  final String message;
  /// ttl
  final int ttl;
  /// 数据
  final VideoData data;

  RcmdVideosResponse({
    required this.code,
    required this.message,
    required this.ttl,
    required this.data,
  });

  factory RcmdVideosResponse.fromJson(Map<String, dynamic> json) {
    return RcmdVideosResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      ttl: json['ttl'] ?? 0,
      data: VideoData.fromJson(json['data'] ?? {}),
    );
  }

  static RcmdVideosResponse fromJsonString(String jsonString) {
    return RcmdVideosResponse.fromJson(json.decode(jsonString));
  }
}

class VideoData {
  /// 视频列表
  final List<Video> items;

  VideoData({required this.items});

  factory VideoData.fromJson(Map<String, dynamic> json) {
    final itemList = json['item'] as List<dynamic>? ?? [];
    return VideoData(
      items: itemList.map((item) => Video.fromJson(item)).toList(),
    );
  }
}

class RelatedVideosResponse {
  /// 状态码
  final int code;
  /// 消息
  final String message;
  /// ttl
  final int ttl;
  /// 数据
  final List<Video> data;

  RelatedVideosResponse({
    required this.code,
    required this.message,
    required this.ttl,
    required this.data,
  });

  factory RelatedVideosResponse.fromJson(Map<String, dynamic> json) {
    return RelatedVideosResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      ttl: json['ttl'] ?? 0,
      data: (json['data'] as List<dynamic>?)?.map((e) => Video.fromJson(e)).toList() ?? [],
    );
  }

  static RelatedVideosResponse fromJsonString(String jsonString) {
    return RelatedVideosResponse.fromJson(json.decode(jsonString));
  }
}

class Video {
  /// 视频avid/直播间id
  final int avid;
  /// 视频bvid
  final String bvid;
  /// 稿件id
  final int cid;
  /// 跳转类型
  final String? goto;
  /// 视频链接
  final String? uri;
  /// 封面Url
  final String pic;
  /// 4:3 封面Url
  final String? pic43;
  /// 视频标题
  final String title;
  /// 视频描述
  final String? description;
  /// 视频时长 (秒)
  final int duration;
  /// 发布日期 (时间戳)
  final String pubdate;
  /// UP主信息
  final Owner owner;
  /// 视频统计数据
  final VideoStat stat;

  Video({
    required this.avid,
    required this.bvid,
    required this.cid,
    this.goto,
    this.uri,
    required this.pic,
    this.pic43,
    required this.title,
    this.description,
    required this.duration,
    required this.pubdate,
    required this.owner,
    required this.stat,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      avid: json['aid'] ?? json['id'] ?? 0,
      bvid: json['bvid'] ?? '',
      cid: json['cid'] ?? 0,
      goto: json['goto'],
      uri: json['uri'],
      pic: json['pic'] ?? '',
      pic43: json['pic_4_3'],
      title: json['title'] ?? '',
      description: json['desc'],
      duration: json['duration'] ?? 0,
      pubdate: (json['pubdate'] ?? 0).toString(),
      owner: Owner.fromJson(json['owner'] ?? {}),
      stat: VideoStat.fromJson(json['stat'] ?? {}),
    );
  }
}

class Owner {
  /// UP主mid
  final int mid;
  /// UP主昵称
  final String name;
  /// UP主头像Url
  final String face;

  Owner({
    required this.mid,
    required this.name,
    required this.face,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      mid: json['mid'] ?? 0,
      name: json['name'] ?? '',
      face: json['face'] ?? '',
    );
  }
}

class VideoStat {
  /// 播放量
  final int view;
  /// 弹幕数
  final int danmaku;
  /// 回复数
  final int reply;
  /// 收藏数
  final int favorite;
  /// 硬币数
  final int coin;
  /// 分享数
  final int share;
  /// 点赞数
  final int like;

  VideoStat({
    required this.view,
    required this.danmaku,
    required this.reply,
    required this.favorite,
    required this.coin,
    required this.share,
    required this.like,
  });

  factory VideoStat.fromJson(Map<String, dynamic> json) {
    return VideoStat(
      view: json['view'] ?? 0,
      danmaku: json['danmaku'] ?? 0,
      reply: json['reply'] ?? 0,
      favorite: json['favorite'] ?? 0,
      coin: json['coin'] ?? 0,
      share: json['share'] ?? 0,
      like: json['like'] ?? 0,
    );
  }
}
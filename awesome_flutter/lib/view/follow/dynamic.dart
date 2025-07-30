import 'dart:convert';

/// 动态列表响应模型
class DynamicsResponse {
  /// 响应代码，0 表示成功
  final int code;

  /// 响应消息，通常为 "0" 表示成功
  final String message;

  /// TTL (Time To Live)，数据有效期
  final int ttl;

  /// 动态数据内容
  final DynamicData data;

  DynamicsResponse({
    required this.code,
    required this.message,
    required this.ttl,
    required this.data,
  });

  factory DynamicsResponse.fromJson(Map<String, dynamic> json) {
    return DynamicsResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      ttl: json['ttl'] ?? 0,
      data: DynamicData.fromJson(json['data'] ?? {}),
    );
  }

  static DynamicsResponse fromJsonString(String jsonString) {
    return DynamicsResponse.fromJson(json.decode(jsonString));
  }
}

/// 动态数据内容模型
class DynamicData {
  /// 是否还有更多数据
  final bool hasMore;

  /// 偏移量，用于分页加载
  final String? offset;

  /// 动态列表
  final List<Dynamic> items;

  DynamicData({
    required this.hasMore,
    this.offset,
    required this.items,
  });

  factory DynamicData.fromJson(Map<String, dynamic> json) {
    final itemList = json['items'] as List<dynamic>? ?? [];
    return DynamicData(
      hasMore: json['has_more'] ?? false,
      offset: json['offset'],
      items: itemList.map((item) => Dynamic.fromJson(item)).toList(),
    );
  }
}

/// 单个动态项模型
class Dynamic {
  /// 动态ID字符串
  final String idStr;

  /// 动态模块信息
  final DynamicModules modules;

  /// 动态类型
  final DynamicType type;

  /// 动态基础信息
  final DynamicBasic basic;

  /// 转发动态的原始动态信息
  final DynamicOriginal? orig;

  Dynamic({
    required this.idStr,
    required this.modules,
    required this.type,
    required this.basic,
    this.orig,
  });

  factory Dynamic.fromJson(Map<String, dynamic> json) {
    return Dynamic(
      idStr: json['id_str'] ?? '',
      modules: DynamicModules.fromJson(json['modules'] ?? {}),
      type: _parseDynamicType(json['type'] ?? ''),
      basic: DynamicBasic.fromJson(json['basic'] ?? {}),
      orig:
          json['orig'] != null ? DynamicOriginal.fromJson(json['orig']) : null,
    );
  }

  static DynamicType _parseDynamicType(String type) {
    switch (type) {
      case 'DYNAMIC_TYPE_FORWARD':
        return DynamicType.forward;
      case 'DYNAMIC_TYPE_DRAW':
        return DynamicType.draw;
      case 'DYNAMIC_TYPE_WORD':
        return DynamicType.word;
      case 'DYNAMIC_TYPE_AV':
        return DynamicType.video;
      case 'DYNAMIC_TYPE_LIVE':
        return DynamicType.live;
      case 'DYNAMIC_TYPE_ARTICLE':
        return DynamicType.article;
      default:
        return DynamicType.unknown;
    }
  }

  // Helper getter to determine the dynamic type
  DynamicType get dynamicType {
    if (modules.moduleDynamic?.major?.archive != null) {
      return DynamicType.archive;
    } else if (modules.moduleDynamic?.major?.draw != null) {
      return DynamicType.draw;
    } else if (modules.moduleDynamic?.major?.live != null) {
      return DynamicType.live;
    } else if (modules.moduleDynamic?.major?.article != null) {
      return DynamicType.article;
    } else if (modules.moduleDynamic?.major?.forward != null) {
      return DynamicType.forward;
    } else if (modules.moduleDynamic?.major?.text != null) {
      return DynamicType.text;
    } else {
      return DynamicType.unknown;
    }
  }
}

/// 动态类型枚举
enum DynamicType {
  /// 转发动态
  forward,

  /// 图文动态
  draw,

  /// 纯文字动态
  word,

  /// 视频动态 (旧版)
  video,

  /// 直播动态
  live,

  /// 文章动态
  article,

  /// 未知类型
  unknown,

  /// 纯文字动态 (新版)
  text,

  /// 视频动态 (新版)
  archive,
}

/// 动态基础信息模型
class DynamicBasic {
  /// 评论ID字符串
  final String commentIdStr;

  /// 评论类型
  final int commentType;

  /// 资源ID字符串
  final String ridStr;

  DynamicBasic({
    required this.commentIdStr,
    required this.commentType,
    required this.ridStr,
  });

  factory DynamicBasic.fromJson(Map<String, dynamic> json) {
    return DynamicBasic(
      commentIdStr: json['comment_id_str'] ?? '',
      commentType: json['comment_type'] ?? 0,
      ridStr: json['rid_str'] ?? '',
    );
  }
}

/// 原始动态信息模型 (用于转发动态)
class DynamicOriginal {
  /// 原始动态的基础信息
  final DynamicBasic basic;

  /// 原始动态的模块信息
  final DynamicModules modules;

  DynamicOriginal({
    required this.basic,
    required this.modules,
  });

  factory DynamicOriginal.fromJson(Map<String, dynamic> json) {
    return DynamicOriginal(
      basic: DynamicBasic.fromJson(json['basic'] ?? {}),
      modules: DynamicModules.fromJson(json['modules'] ?? {}),
    );
  }
}

/// 动态模块信息模型
class DynamicModules {
  /// 作者信息模块
  final ModuleAuthor moduleAuthor;

  /// 动态主要内容模块 (可能为空)
  final ModuleDynamic? moduleDynamic;

  /// 统计信息模块
  final ModuleStat moduleStat;

  /// 图片信息模块 (可能为空)
  final ModulePic? modulePic;

  DynamicModules({
    required this.moduleAuthor,
    this.moduleDynamic,
    required this.moduleStat,
    this.modulePic,
  });

  factory DynamicModules.fromJson(Map<String, dynamic> json) {
    return DynamicModules(
      moduleAuthor: ModuleAuthor.fromJson(json['module_author'] ?? {}),
      moduleDynamic: json['module_dynamic'] != null
          ? ModuleDynamic.fromJson(
              json['module_dynamic']) // ModuleDynamic contains major
          : null,
      moduleStat: ModuleStat.fromJson(json['module_stat'] ?? {}),
      modulePic: json['module_dynamic']?['major']?['draw'] != null
          ? ModulePic.fromJson(json['module_dynamic']['major']['draw'])
          : null,
    );
  }
}

/// 作者信息模型
class ModuleAuthor {
  /// 用户头像URL
  final String face;

  final String pubTime;

  /// 是否为NFT头像
  final bool faceNft;

  /// 用户ID
  final int mid;

  /// 用户昵称
  final String name;

  /// 跳转链接
  final String jumpUrl;

  /// 官方认证信息 (可能为空)
  final OfficialVerify? officialVerify;

  ModuleAuthor({
    required this.pubTime,
    required this.face,
    required this.faceNft,
    required this.mid,
    required this.name,
    required this.jumpUrl,
    this.officialVerify,
  });

  factory ModuleAuthor.fromJson(Map<String, dynamic> json) {
    return ModuleAuthor(
      pubTime: json['pub_time'] ?? '未知时间',
      face: json['face'] ?? '',
      faceNft: json['face_nft'] ?? false,
      mid: json['mid'] ?? 0,
      name: json['name'] ?? '',
      jumpUrl: json['jump_url'] ?? '',
      officialVerify: json['official_verify'] != null
          ? OfficialVerify.fromJson(json['official_verify'])
          : null,
    );
  }
}

/// 官方认证信息模型
class OfficialVerify {
  /// 认证描述
  final String desc;

  /// 认证类型
  final int type;

  OfficialVerify({
    required this.desc,
    required this.type,
  });

  factory OfficialVerify.fromJson(Map<String, dynamic> json) {
    return OfficialVerify(
      desc: json['desc'] ?? '',
      type: json['type'] ?? -1,
    );
  }
}

/// 动态主要内容模型
class ModuleDynamic {
  /// 主要内容，根据动态类型包含不同信息
  final DynamicMajor? major;

  /// 文字内容
  final DynamicDesc? desc;

  ModuleDynamic({
    this.major,
    this.desc,
  });

  factory ModuleDynamic.fromJson(Map<String, dynamic> json) {
    return ModuleDynamic(
      major:
          json['major'] != null ? DynamicMajor.fromJson(json['major']) : null,
      desc: json['desc'] != null ? DynamicDesc.fromJson(json['desc']) : null,
    );
  }
}

/// 转发动态文字内容
class DynamicDesc {
  /// 动态的文字内容
  final String text;

  DynamicDesc({required this.text});

  factory DynamicDesc.fromJson(Map<String, dynamic> json) {
    return DynamicDesc(
      text: json['text'] ?? '',
    );
  }
}

/// 动态主要内容类型模型
class DynamicMajor {
  /// 视频动态内容 (archive)
  final DynamicArchive? archive;

  /// 图文动态内容 (draw)
  final DynamicDraw? draw;

  /// 直播动态内容 (live)
  final DynamicLive? live;

  /// 文章动态内容 (article)
  final DynamicArticle? article;

  /// 纯文字动态内容 (text)
  final DynamicText? text;

  /// 转发动态内容 (forward)
  final DynamicForward? forward;

  DynamicMajor({
    this.archive,
    this.draw,
    this.live,
    this.article,
    this.text,
    this.forward,
  });

  factory DynamicMajor.fromJson(Map<String, dynamic> json) {
    return DynamicMajor(
      archive: json['archive'] != null
          ? DynamicArchive.fromJson(json['archive'])
          : null,
      draw: json['draw'] != null ? DynamicDraw.fromJson(json['draw']) : null,
      live: json['live'] != null ? DynamicLive.fromJson(json['live']) : null,
      article: json['article'] != null
          ? DynamicArticle.fromJson(json['article'])
          : null,
      text: json['text'] != null
          ? DynamicText.fromJson(json['text'])
          : null, // Assuming text dynamic has a major structure
      forward: json['forward'] != null
          ? DynamicForward.fromJson(json['forward'])
          : null, // Assuming forward dynamic has a major structure
    );
  }
}

/// 视频动态内容模型
class DynamicArchive {
  /// 视频AID
  final String aid;

  /// 视频BV号
  final String bvid;

  /// 视频标题
  final String title;

  /// 视频描述
  final String desc;

  /// 视频封面URL
  final String cover;

  /// 视频时长 (秒)
  final int duration;

  /// 跳转链接
  final String jumpUrl;

  DynamicArchive({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.desc,
    required this.cover,
    required this.duration,
    required this.jumpUrl,
  });

  factory DynamicArchive.fromJson(Map<String, dynamic> json) {
    return DynamicArchive(
      aid: json['aid'] ?? '',
      bvid: json['bvid'] ?? '',
      title: json['title'] ?? '',
      desc: json['desc'] ?? '',
      cover: json['cover'] ?? '',
      duration: json['duration'] ?? 0,
      jumpUrl: json['jump_url'] ?? '',
    );
  }
}

/// 图文动态内容模型
class DynamicDraw {
  /// 图文列表
  final List<DynamicDrawItem> items;

  DynamicDraw({
    required this.items,
  });

  factory DynamicDraw.fromJson(Map<String, dynamic> json) {
    final itemList = json['items'] as List<dynamic>? ?? [];
    return DynamicDraw(
      items: itemList.map((item) => DynamicDrawItem.fromJson(item)).toList(),
    );
  }
}

/// 图文动态中的图片项模型
class DynamicDrawItem {
  /// 图片URL
  final String src;

  /// 图片宽度
  final int width;

  /// 图片高度
  final int height;

  /// 图片标签
  final List<String> tags;

  DynamicDrawItem({
    required this.src,
    required this.width,
    required this.height,
    required this.tags,
  });

  factory DynamicDrawItem.fromJson(Map<String, dynamic> json) {
    final tagsList = json['tags'] as List<dynamic>? ?? [];
    return DynamicDrawItem(
      src: json['src'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      tags: tagsList.map((e) => e.toString()).toList(),
    );
  }
}

/// 直播动态内容模型
class DynamicLive {
  /// 直播标题
  final String title;

  /// 直播封面URL
  final String cover;

  /// 直播状态 (1: 直播中, 0: 未直播)
  final int liveState;

  /// 主播信息
  final ModuleAuthor author;

  DynamicLive({
    required this.title,
    required this.cover,
    required this.liveState,
    required this.author,
  });

  factory DynamicLive.fromJson(Map<String, dynamic> json) {
    return DynamicLive(
      title: json['title'] ?? '',
      cover: json['cover'] ?? '',
      liveState: json['live_state'] ?? 0,
      author: ModuleAuthor.fromJson(json['author'] ?? {}),
    );
  }
}

/// 文章动态内容模型
class DynamicArticle {
  /// 文章标题
  final String title;

  /// 文章描述
  final String desc;

  /// 文章封面URL列表
  final List<String> covers;

  /// 跳转链接
  final String jumpUrl;

  DynamicArticle({
    required this.title,
    required this.desc,
    required this.covers,
    required this.jumpUrl,
  });

  factory DynamicArticle.fromJson(Map<String, dynamic> json) {
    final coversList = json['covers'] as List<dynamic>? ?? [];
    return DynamicArticle(
      title: json['title'] ?? '',
      desc: json['desc'] ?? '',
      covers: coversList.map((e) => e.toString()).toList(),
      jumpUrl: json['jump_url'] ?? '',
    );
  }
}

/// 纯文字动态内容模型
class DynamicText {
  /// 文字内容
  final String content;

  DynamicText({
    required this.content,
  });

  factory DynamicText.fromJson(Map<String, dynamic> json) {
    return DynamicText(
      content: json['content'] ?? '',
    );
  }
}

/// 转发动态内容模型
/// 转发动态本身可能没有特定的主要字段，主要依赖于 DynamicItem 中的 `orig` 字段。
class DynamicForward {
  DynamicForward();

  factory DynamicForward.fromJson(Map<String, dynamic> json) {
    return DynamicForward();
  }
}

/// 动态统计信息模型
class ModuleStat {
  /// 评论统计
  final DynamicStat comment;

  /// 点赞统计
  final DynamicStat like;

  /// 分享统计
  final DynamicStat share;

  ModuleStat({
    required this.comment,
    required this.like,
    required this.share,
  });

  factory ModuleStat.fromJson(Map<String, dynamic> json) {
    return ModuleStat(
      comment: DynamicStat.fromJson(json['comment'] ?? {}),
      like: DynamicStat.fromJson(json['like'] ?? {}),
      share: DynamicStat.fromJson(json['forward'] ?? {}),
    );
  }
}

/// 单个统计项模型
class DynamicStat {
  /// 数量
  final int count;

  /// 状态 (例如，是否已点赞)
  final bool status;

  DynamicStat({
    required this.count,
    required this.status,
  });

  factory DynamicStat.fromJson(Map<String, dynamic> json) {
    return DynamicStat(
      count: json['count'] ?? 0,
      status: json['status'] ?? false,
    );
  }
}

/// 图片信息模块 (用于图文动态)
class ModulePic {
  /// 图片列表
  final List<DynamicDrawItem> items;

  ModulePic({
    required this.items,
  });

  factory ModulePic.fromJson(Map<String, dynamic> json) {
    final itemList = json['items'] as List<dynamic>? ?? [];
    return ModulePic(
      items: itemList.map((item) => DynamicDrawItem.fromJson(item)).toList(),
    );
  }
}

/// 常用用户信息模型
class FrequentUser {
  /// 用户ID
  final int mid;

  /// 用户头像URL
  final String face;

  /// 用户昵称
  final String name;

  FrequentUser({
    required this.mid,
    required this.face,
    required this.name,
  });

  factory FrequentUser.fromJson(Map<String, dynamic> json) {
    return FrequentUser(
      mid: json['mid'] ?? 0,
      face: json['face'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

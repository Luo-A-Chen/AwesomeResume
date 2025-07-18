class ReplyResponse {
  final int code;
  final String message;
  final ReplyData? data;

  ReplyResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory ReplyResponse.fromJson(Map<String, dynamic> json) {
    return ReplyResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? ReplyData.fromJson(json['data']) : null,
    );
  }
}

class ReplyData {
  final PageInfo page;
  final List<Reply> replies;
  final List<Reply>? hots; // 热评可能为空

  ReplyData({
    required this.page,
    required this.replies,
    this.hots,
  });

  factory ReplyData.fromJson(Map<String, dynamic> json) {
    var repliesList = json['replies'] as List?;
    List<Reply> replies = repliesList != null
        ? repliesList.map((i) => Reply.fromJson(i)).toList()
        : [];

    var hotsList = json['hots'] as List?;
    List<Reply>? hots = hotsList?.map((i) => Reply.fromJson(i)).toList();

    return ReplyData(
      page: PageInfo.fromJson(json['page']),
      replies: replies,
      hots: hots,
    );
  }
}

class PageInfo {
  final int num;
  final int size;
  final int count;
  final int acount;

  PageInfo({
    required this.num,
    required this.size,
    required this.count,
    required this.acount,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      num: json['num'],
      size: json['size'],
      count: json['count'],
      acount: json['acount'],
    );
  }
}

class Reply {
  final int rpid;
  final int oid;
  final int type;
  final int mid;
  final int root;
  final int parent;
  final int count; // 二级评论数
  final int rcount; // 回复数
  final int like;
  final int ctime; // 评论发送时间戳
  final Member member;
  final Content content;
  final List<Reply>? replies; // 子评论

  Reply({
    required this.rpid,
    required this.oid,
    required this.type,
    required this.mid,
    required this.root,
    required this.parent,
    required this.count,
    required this.rcount,
    required this.like,
    required this.ctime,
    required this.member,
    required this.content,
    this.replies,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    var repliesList = json['replies'] as List?;
    List<Reply>? replies = repliesList?.map((i) => Reply.fromJson(i)).toList();

    return Reply(
      rpid: json['rpid'],
      oid: json['oid'],
      type: json['type'],
      mid: json['mid'],
      root: json['root'],
      parent: json['parent'],
      count: json['count'] ?? 0,
      rcount: json['rcount'] ?? 0,
      like: json['like'] ?? 0,
      ctime: json['ctime'],
      member: Member.fromJson(json['member']),
      content: Content.fromJson(json['content']),
      replies: replies,
    );
  }
}

class Member {
  final String mid;
  final String uname;
  final String sex;
  final String sign;
  final String avatar;
  final LevelInfo levelInfo;
  final Pendant? pendant; // 可能为空
  final Nameplate? nameplate; // 可能为空
  final OfficialVerify? officialVerify; // 可能为空
  final Vip? vip; // 可能为空

  Member({
    required this.mid,
    required this.uname,
    required this.sex,
    required this.sign,
    required this.avatar,
    required this.levelInfo,
    this.pendant,
    this.nameplate,
    this.officialVerify,
    this.vip,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      mid: json['mid'].toString(), // mid可能是数字或字符串
      uname: json['uname'],
      sex: json['sex'],
      sign: json['sign'],
      avatar: json['avatar'],
      levelInfo: LevelInfo.fromJson(json['level_info']),
      pendant: json['pendant'] != null ? Pendant.fromJson(json['pendant']) : null,
      nameplate: json['nameplate'] != null ? Nameplate.fromJson(json['nameplate']) : null,
      officialVerify: json['official_verify'] != null ? OfficialVerify.fromJson(json['official_verify']) : null,
      vip: json['vip'] != null ? Vip.fromJson(json['vip']) : null,
    );
  }
}

class LevelInfo {
  final int currentLevel;

  LevelInfo({required this.currentLevel});

  factory LevelInfo.fromJson(Map<String, dynamic> json) {
    return LevelInfo(currentLevel: json['current_level']);
  }
}

class Pendant {
  final int pid;
  final String name;
  final String image;

  Pendant({required this.pid, required this.name, required this.image});

  factory Pendant.fromJson(Map<String, dynamic> json) {
    return Pendant(
      pid: json['pid'],
      name: json['name'],
      image: json['image'],
    );
  }
}

class Nameplate {
  final int nid;
  final String name;
  final String image;
  final String level;
  final String condition;

  Nameplate({
    required this.nid,
    required this.name,
    required this.image,
    required this.level,
    required this.condition,
  });

  factory Nameplate.fromJson(Map<String, dynamic> json) {
    return Nameplate(
      nid: json['nid'],
      name: json['name'],
      image: json['image'],
      level: json['level'],
      condition: json['condition'],
    );
  }
}

class OfficialVerify {
  final int type;
  final String desc;

  OfficialVerify({required this.type, required this.desc});

  factory OfficialVerify.fromJson(Map<String, dynamic> json) {
    return OfficialVerify(
      type: json['type'],
      desc: json['desc'] ?? '',
    );
  }
}

class Vip {
  final int vipType;
  final int vipStatus;
  final VipLabel label;

  Vip({required this.vipType, required this.vipStatus, required this.label});

  factory Vip.fromJson(Map<String, dynamic> json) {
    return Vip(
      vipType: json['vipType'],
      vipStatus: json['vipStatus'],
      label: VipLabel.fromJson(json['label']),
    );
  }
}

class VipLabel {
  final String path;
  final String text;
  final String labelTheme;

  VipLabel({required this.path, required this.text, required this.labelTheme});

  factory VipLabel.fromJson(Map<String, dynamic> json) {
    return VipLabel(
      path: json['path'] ?? '',
      text: json['text'],
      labelTheme: json['label_theme'],
    );
  }
}

class Content {
  final String message;
  // 可以根据需要添加其他字段，如图片、艾特等

  Content({required this.message});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(message: json['message']);
  }
}
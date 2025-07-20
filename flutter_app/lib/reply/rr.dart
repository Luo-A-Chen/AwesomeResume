/// 动态列表响应模型
class ReplyResponse {
  /// 响应代码，0 表示成功
  final int code;

  /// 响应消息，通常为 "0" 表示成功
  final String message;

  /// TTL (Time To Live)，数据有效期
  final int ttl;

  /// 动态数据内容
  final ReplyData data;

  ReplyResponse({
    required this.code,
    required this.message,
    required this.ttl,
    required this.data,
  });

  factory ReplyResponse.fromJson(Map<String, dynamic> json) {
    return ReplyResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      ttl: json['ttl'] ?? 0,
      data: ReplyData.fromJson(json['data'] ?? {}),
    );
  }
}

class ReplyData {
  ReplyData({
    this.cursor,
    this.config,
    this.replies,
    this.topReplies,
    this.upper,
  });

  ReplyCursor? cursor;
  ReplyConfig? config;
  late List<Reply>? replies;
  late List<Reply>? topReplies;
  ReplyUpper? upper;

  ReplyData.fromJson(Map<String, dynamic> json) {
    cursor = ReplyCursor.fromJson(json['cursor']);
    config = ReplyConfig.fromJson(json['config']);
    replies = json['replies'] != null
        ? List<Reply>.from(json['replies']
            .map<Reply>(
                (item) => Reply.fromJson(item, json['upper']['mid'])))
        : <Reply>[];
    topReplies = json['top_replies'] != null
        ? List<Reply>.from(json['top_replies']
            .map<Reply>((item) => Reply.fromJson(
                item, json['upper']['mid'],
                isTopStatus: true)))
        : <Reply>[];
    upper = ReplyUpper.fromJson(json['upper']);
  }
}

class ReplyReplyData {
  ReplyReplyData({
    this.page,
    this.config,
    this.replies,
    this.topReplies,
    this.upper,
    this.root,
  });

  ReplyPage? page;
  ReplyConfig? config;
  late List<Reply>? replies;
  late List<Reply>? topReplies;
  ReplyUpper? upper;
  Reply? root;

  ReplyReplyData.fromJson(Map<String, dynamic> json) {
    page = ReplyPage.fromJson(json['page']);
    config = ReplyConfig.fromJson(json['config']);
    replies = json['replies'] != null
        ? List<Reply>.from(json['replies']
        .map<Reply>(
            (item) => Reply.fromJson(item, json['upper']['mid'])))
        : <Reply>[];
    topReplies = json['top_replies'] != null
        ? List<Reply>.from(json['top_replies']
        .map<Reply>((item) => Reply.fromJson(
        item, json['upper']['mid'],
        isTopStatus: true)))
        : <Reply>[];
    upper = ReplyUpper.fromJson(json['upper']);
    root = Reply.fromJson(json['root'], json['upper']['mid']);
  }
}

class ReplyConfig {
  ReplyConfig({
    this.showtopic,
    this.showUpFlag,
    this.readOnly,
  });

  int? showtopic;
  bool? showUpFlag;
  bool? readOnly;

  ReplyConfig.fromJson(Map<String, dynamic> json) {
    showtopic = json['showtopic'];
    showUpFlag = json['show_up_flag'];
    readOnly = json['read_only'];
  }
}

class ReplyPage {
  ReplyPage({
    this.num,
    this.size,
    this.count,
    this.acount,
  });

  int? num;
  int? size;
  int? count;
  int? acount;

  ReplyPage.fromJson(Map<String, dynamic> json) {
    num = json['num'];
    size = json['size'];
    count = json['count'];
    acount = json['acount'];
  }
}

class ReplyCursor {
  ReplyCursor({
    this.isBegin,
    this.prev,
    this.next,
    this.isEnd,
    this.mode,
    this.modeText,
    this.allCount,
    this.supportMode,
    this.name,
    this.paginationReply,
    this.sessionId,
  });

  bool? isBegin;
  int? prev;
  int? next;
  bool? isEnd;
  int? mode;
  String? modeText;
  int? allCount;
  List<int>? supportMode;
  String? name;
  PaginationReply? paginationReply;
  String? sessionId;

  ReplyCursor.fromJson(Map<String, dynamic> json) {
    isBegin = json['is_begin'];
    prev = json['prev'];
    next = json['next'];
    isEnd = json['is_end'];
    mode = json['mode'];
    modeText = json['mode_text'];
    allCount = json['all_count'] ?? 0;
    supportMode = json['support_mode'].cast<int>();
    name = json['name'];
    paginationReply = json['pagination_reply'] != null
        ? PaginationReply.fromJson(json['pagination_reply'])
        : null;
    sessionId = json['session_id'];
  }
}

class PaginationReply {
  PaginationReply({
    this.nextOffset,
    this.prevOffset,
  });
  String? nextOffset;
  String? prevOffset;
  PaginationReply.fromJson(Map<String, dynamic> json) {
    nextOffset = json['next_offset'];
    prevOffset = json['prev_offset'];
  }
}

class ReplyUpper {
  ReplyUpper({
    this.mid,
    this.top,
  });

  int? mid;
  Reply? top;

  ReplyUpper.fromJson(Map<String, dynamic> json) {
    mid = json['mid'];
    top = json['top'] != null
        ? Reply.fromJson(json['top'], json['mid'])
        : null;
  }
}

class Reply {
  Reply({
    this.rpid,
    this.oid,
    this.type,
    this.mid,
    this.root,
    this.parent,
    this.dialog,
    this.count,
    this.floor,
    this.state,
    this.fansgrade,
    this.attr,
    this.ctime,
    this.rpidStr,
    this.rootStr,
    this.parentStr,
    this.like,
    this.action,
    this.member,
    this.content,
    this.replies,
    this.assist,
    this.upAction,
    this.invisible,
    this.replyControl,
    this.isUp,
    this.isTop,
    this.cardLabel,
  });

  int? rpid;
  int? oid;
  int? type;
  int? mid;
  int? root;
  int? parent;
  int? dialog;
  int? count;
  int? floor;
  int? state;
  int? fansgrade;
  int? attr;
  int? ctime;
  String? rpidStr;
  String? rootStr;
  String? parentStr;
  int? like;
  int? action;
  ReplyMember? member;
  ReplyContent? content;
  List<Reply>? replies;
  int? assist;
  UpAction? upAction;
  bool? invisible;
  ReplyControl? replyControl;
  bool? isUp;
  bool? isTop = false;
  List? cardLabel;

  Reply.fromJson(Map<String, dynamic> json, upperMid,
      {isTopStatus = false}) {
    rpid = json['rpid'];
    oid = json['oid'];
    type = json['type'];
    mid = json['mid'];
    root = json['root'];
    parent = json['parent'];
    dialog = json['dialog'];
    count = json['count'];
    floor = json['floor'];
    state = json['state'];
    fansgrade = json['fansgrade'];
    attr = json['attr'];
    ctime = json['ctime'];
    rpidStr = json['rpid_str'];
    rootStr = json['root_str'];
    parentStr = json['parent_str'];
    like = json['like'];
    action = json['action'];
    member = ReplyMember.fromJson(json['member']);
    content = ReplyContent.fromJson(json['content']);
    replies = json['replies'] != null
        ? List<Reply>.from(json['replies']
            .map((item) => Reply.fromJson(item, upperMid)))
        : <Reply>[];
    assist = json['assist'];
    upAction = UpAction.fromJson(json['up_action']);
    invisible = json['invisible'];
    replyControl = json['reply_control'] == null
        ? null
        : ReplyControl.fromJson(json['reply_control']);
    isUp = upperMid.toString() == json['member']['mid'];
    isTop = isTopStatus;
    cardLabel = json['card_label'] != null
        ? json['card_label'].map((e) => e['text_content']).toList()
        : [];
  }
}

class UpAction {
  UpAction({this.like, this.reply});

  bool? like;
  bool? reply;

  UpAction.fromJson(Map<String, dynamic> json) {
    like = json['like'];
    reply = json['reply'];
  }
}

class ReplyControl {
  ReplyControl({
    this.upReply,
    this.isUpTop,
    this.upLike,
    this.isShow,
    this.entryText,
    this.titleText,
    this.time,
    this.location,
  });

  bool? upReply;
  bool? isUpTop;
  bool? upLike;
  bool? isShow;
  String? entryText;
  String? titleText;
  String? time;
  String? location;

  ReplyControl.fromJson(Map<String, dynamic> json) {
    upReply = json['up_reply'] ?? false;
    isUpTop = json['is_up_top'] ?? false;
    upLike = json['up_like'] ?? false;
    if (json['sub_reply_entry_text'] != null) {
      final RegExp regex = RegExp(r"\d+");
      final RegExpMatch match = regex.firstMatch(
          json['sub_reply_entry_text'] == null
              ? ''
              : json['sub_reply_entry_text']!)!;
      isShow = int.parse(match.group(0)!) >= 3;
    } else {
      isShow = false;
    }

    entryText = json['sub_reply_entry_text'];
    titleText = json['sub_reply_title_text'];
    time = json['time_desc'];
    location = json['location'] != null ? json['location'].split('：')[1] : '';
  }
}

class ReplyContent {
  ReplyContent({
    this.message,
    this.atNameToMid, // @的用户的mid null
    this.members, // 被@的用户List 如果有的话 []
    this.emote, // 表情包 如果有的话 null
    this.jumpUrl, // {}
    this.pictures, // {}
    this.vote,
    this.richText,
    this.isText,
    this.topicsMeta,
  });

  String? message;
  Map? atNameToMid;
  List<MemberItemModel>? members;
  Map? emote;
  Map? jumpUrl;
  List? pictures;
  Map? vote;
  Map? richText;
  bool? isText;
  Map? topicsMeta;

  ReplyContent.fromJson(Map<String, dynamic> json) {
    message = json['message']
        .replaceAll('&gt;', '>')
        .replaceAll('&#34;', '"')
        .replaceAll('&#39;', "'");
    atNameToMid = json['at_name_to_mid'] ?? {};
    members = json['members'] != null
        ? json['members']
            .map<MemberItemModel>((e) => MemberItemModel.fromJson(e))
            .toList()
        : [];
    emote = json['emote'] ?? {};
    jumpUrl = json['jump_url'] ?? {};
    pictures = json['pictures'] ?? [];
    vote = json['vote'] ?? {};
    richText = json['rich_text'] ?? {};
    // 不包含@ 笔记 图片的时候，文字可折叠
    isText = atNameToMid!.isEmpty && vote!.isEmpty && pictures!.isEmpty;
    topicsMeta = json['topics_meta'] ?? {};
  }
}

class MemberItemModel {
  MemberItemModel({
    required this.mid,
    required this.uname,
  });

  late String mid;
  late String uname;

  MemberItemModel.fromJson(Map<String, dynamic> json) {
    mid = json['mid'];
    uname = json['uname'];
  }
}

class ReplyMember {
  ReplyMember({
    this.mid,
    this.uname,
    this.sign,
    this.avatar,
    this.level,
    this.pendant,
    this.officialVerify,
    this.vip,
    this.fansDetail,
  });

  String? mid;
  String? uname;
  String? sign;
  String? avatar;
  int? level;
  Pendant? pendant;
  Map? officialVerify;
  Map? vip;
  Map? fansDetail;
  UserSailing? userSailing;

  ReplyMember.fromJson(Map<String, dynamic> json) {
    mid = json['mid'];
    uname = json['uname'];
    sign = json['sign'];
    avatar = json['avatar'];
    level = json['level_info']['current_level'];
    pendant = Pendant.fromJson(json['pendant']);
    officialVerify = json['official_verify'];
    vip = json['vip'];
    fansDetail = json['fans_detail'];
    userSailing = json['user_sailing'] != null
        ? UserSailing.fromJson(json['user_sailing'])
        : UserSailing();
  }
}

class Pendant {
  Pendant({
    this.pid,
    this.name,
    this.image,
  });

  int? pid;
  String? name;
  String? image;

  Pendant.fromJson(Map<String, dynamic> json) {
    pid = json['pid'];
    name = json['name'];
    image = json['image'];
  }
}

class UserSailing {
  UserSailing({this.pendant, this.cardbg});

  Map? pendant;
  Map? cardbg;

  UserSailing.fromJson(Map<String, dynamic> json) {
    pendant = json['pendant'];
    cardbg = json['cardbg'];
  }
}

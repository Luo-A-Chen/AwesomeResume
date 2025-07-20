class ReplyResponse {
  final int code;
  final String message;
  final int ttl;
  final Data data;

  ReplyResponse({
    required this.code,
    required this.message,
    required this.ttl,
    required this.data,
  });

  factory ReplyResponse.fromJson(Map<String, dynamic> json) {
    return ReplyResponse(
      code: json['code'],
      message: json['message'],
      ttl: json['ttl'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  final Cursor cursor;
  final List<Reply> replies;
  final Top? top;
  final List<Reply> topReplies;
  final UpSelection? upSelection;
  final Effects effects;
  final int assist;
  final int blacklist;
  final int vote;
  final Config config;
  final Upper upper;
  final int note;
  final dynamic esportsGradeCard;
  final dynamic callbacks;
  final String? contextFeature;

  Data({
    required this.cursor,
    required this.replies,
    this.top,
    required this.topReplies,
     this.upSelection,
    required this.effects,
    required this.assist,
    required this.blacklist,
    required this.vote,
    required this.config,
    required this.upper,
    required this.note,
    this.esportsGradeCard,
    this.callbacks,
     this.contextFeature,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      cursor: Cursor.fromJson(json['cursor']),
      replies: List<Reply>.from(json['replies'].map((x) => Reply.fromJson(x))),
      top: json['top'] != null ? Top.fromJson(json['top']) : null,
      topReplies: List<Reply>.from(json['top_replies'].map((x) => Reply.fromJson(x))),
      // upSelection: UpSelection.fromJson(json['up_selection']),
      effects: Effects.fromJson(json['effects']),
      assist: json['assist'],
      blacklist: json['blacklist'],
      vote: json['vote'],
      config: Config.fromJson(json['config']),
      upper: Upper.fromJson(json['upper']),
      note: json['note'],
      esportsGradeCard: json['esports_grade_card'],
      callbacks: json['callbacks'],
      contextFeature: json['context_feature'],
    );
  }
}

class Cursor {
  final bool isBegin;
  final int prev;
  final int next;
  final bool isEnd;
  final int mode;
  final String modeText;
  final int allCount;
  final List<int> supportMode;
  final String name;
  final PaginationReply paginationReply;
  final String sessionId;

  Cursor({
    required this.isBegin,
    required this.prev,
    required this.next,
    required this.isEnd,
    required this.mode,
    required this.modeText,
    required this.allCount,
    required this.supportMode,
    required this.name,
    required this.paginationReply,
    required this.sessionId,
  });

  factory Cursor.fromJson(Map<String, dynamic> json) {
    return Cursor(
      isBegin: json['is_begin'],
      prev: json['prev'],
      next: json['next'],
      isEnd: json['is_end'],
      mode: json['mode'],
      modeText: json['mode_text'],
      allCount: json['all_count'],
      supportMode: List<int>.from(json['support_mode'].map((x) => x)),
      name: json['name'],
      paginationReply: PaginationReply.fromJson(json['pagination_reply']),
      sessionId: json['session_id'],
    );
  }
}

class PaginationReply {
  final String? nextOffset;

  PaginationReply({
    required this.nextOffset,
  });

  factory PaginationReply.fromJson(Map<String, dynamic> json) {
    return PaginationReply(
      nextOffset: json['next_offset'],
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
  final int dialog;
  final int count;
  final int rcount;
  final int state;
  final int fansgrade;
  final int attr;
  final int ctime;
  final String midStr;
  final String oidStr;
  final String rpidStr;
  final String rootStr;
  final String parentStr;
  final String dialogStr;
  final int like;
  final int action;
  final Member member;
  final Content content;
  final List<Reply>? replies;
  final int assist;
  final UpAction upAction;
  final bool invisible;
  final ReplyControl replyControl;
  final Folder folder;
  final String dynamicIdStr;
  final String noteCvidStr;
  final String trackInfo;

  Reply({
    required this.rpid,
    required this.oid,
    required this.type,
    required this.mid,
    required this.root,
    required this.parent,
    required this.dialog,
    required this.count,
    required this.rcount,
    required this.state,
    required this.fansgrade,
    required this.attr,
    required this.ctime,
    required this.midStr,
    required this.oidStr,
    required this.rpidStr,
    required this.rootStr,
    required this.parentStr,
    required this.dialogStr,
    required this.like,
    required this.action,
    required this.member,
    required this.content,
     this.replies,
    required this.assist,
    required this.upAction,
    required this.invisible,
    required this.replyControl,
    required this.folder,
    required this.dynamicIdStr,
    required this.noteCvidStr,
    required this.trackInfo,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      rpid: json['rpid'],
      oid: json['oid'],
      type: json['type'],
      mid: json['mid'],
      root: json['root'],
      parent: json['parent'],
      dialog: json['dialog'],
      count: json['count'],
      rcount: json['rcount'],
      state: json['state'],
      fansgrade: json['fansgrade'],
      attr: json['attr'],
      ctime: json['ctime'],
      midStr: json['mid_str'],
      oidStr: json['oid_str'],
      rpidStr: json['rpid_str'],
      rootStr: json['root_str'],
      parentStr: json['parent_str'],
      dialogStr: json['dialog_str'],
      like: json['like'],
      action: json['action'],
      member: Member.fromJson(json['member']),
      content: Content.fromJson(json['content']),
      // replies: List<Reply>.from(json['replies'].map((x) => Reply.fromJson(x))),
      assist: json['assist'],
      upAction: UpAction.fromJson(json['up_action']),
      invisible: json['invisible'],
      replyControl: ReplyControl.fromJson(json['reply_control']),
      folder: Folder.fromJson(json['folder']),
      dynamicIdStr: json['dynamic_id_str'],
      noteCvidStr: json['note_cvid_str'],
      trackInfo: json['track_info'],
    );
  }
}

class Member {
  final String mid;
  final String uname;
  final String sex;
  final String sign;
  final String avatar;
  final String rank;
  final int faceNftNew;
  final int isSeniorMember;
  final Map<String, dynamic> senior;
  final LevelInfo levelInfo;
  final Pendant pendant;
  final Nameplate nameplate;
  final OfficialVerify officialVerify;
  final Vip vip;
  final dynamic fansDetail;
  final UserSailing? userSailing;
  final Map<String, dynamic>? userSailingV2;
  final bool isContractor;
  final String contractDesc;
  final dynamic nftInteraction;
  final AvatarItem avatarItem;

  Member({
    required this.mid,
    required this.uname,
    required this.sex,
    required this.sign,
    required this.avatar,
    required this.rank,
    required this.faceNftNew,
    required this.isSeniorMember,
    required this.senior,
    required this.levelInfo,
    required this.pendant,
    required this.nameplate,
    required this.officialVerify,
    required this.vip,
    this.fansDetail,
     this.userSailing,
     this.userSailingV2,
    required this.isContractor,
    required this.contractDesc,
    this.nftInteraction,
    required this.avatarItem,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      mid: json['mid'],
      uname: json['uname'],
      sex: json['sex'],
      sign: json['sign'],
      avatar: json['avatar'],
      rank: json['rank'],
      faceNftNew: json['face_nft_new'],
      isSeniorMember: json['is_senior_member'],
      senior: Map<String, dynamic>.from(json['senior']),
      levelInfo: LevelInfo.fromJson(json['level_info']),
      pendant: Pendant.fromJson(json['pendant']),
      nameplate: Nameplate.fromJson(json['nameplate']),
      officialVerify: OfficialVerify.fromJson(json['official_verify']),
      vip: Vip.fromJson(json['vip']),
      fansDetail: json['fans_detail'],
      // userSailing: UserSailing.fromJson(json['user_sailing']),
      // userSailingV2: Map<String, dynamic>.from(json['user_sailing_v2']),
      isContractor: json['is_contractor'],
      contractDesc: json['contract_desc'],
      nftInteraction: json['nft_interaction'],
      avatarItem: AvatarItem.fromJson(json['avatar_item']),
    );
  }
}

class LevelInfo {
  final int currentLevel;
  final int currentMin;
  final int currentExp;
  final int nextExp;

  LevelInfo({
    required this.currentLevel,
    required this.currentMin,
    required this.currentExp,
    required this.nextExp,
  });

  factory LevelInfo.fromJson(Map<String, dynamic> json) {
    return LevelInfo(
      currentLevel: json['current_level'],
      currentMin: json['current_min'],
      currentExp: json['current_exp'],
      nextExp: json['next_exp'],
    );
  }
}

class Pendant {
  final int pid;
  final String name;
  final String image;
  final int expire;
  final String imageEnhance;
  final String imageEnhanceFrame;
  final int nPid;

  Pendant({
    required this.pid,
    required this.name,
    required this.image,
    required this.expire,
    required this.imageEnhance,
    required this.imageEnhanceFrame,
    required this.nPid,
  });

  factory Pendant.fromJson(Map<String, dynamic> json) {
    return Pendant(
      pid: json['pid'],
      name: json['name'],
      image: json['image'],
      expire: json['expire'],
      imageEnhance: json['image_enhance'],
      imageEnhanceFrame: json['image_enhance_frame'],
      nPid: json['n_pid'],
    );
  }
}

class Nameplate {
  final int nid;
  final String name;
  final String image;
  final String imageSmall;
  final String level;
  final String condition;

  Nameplate({
    required this.nid,
    required this.name,
    required this.image,
    required this.imageSmall,
    required this.level,
    required this.condition,
  });

  factory Nameplate.fromJson(Map<String, dynamic> json) {
    return Nameplate(
      nid: json['nid'],
      name: json['name'],
      image: json['image'],
      imageSmall: json['image_small'],
      level: json['level'],
      condition: json['condition'],
    );
  }
}

class OfficialVerify {
  final int type;
  final String desc;

  OfficialVerify({
    required this.type,
    required this.desc,
  });

  factory OfficialVerify.fromJson(Map<String, dynamic> json) {
    return OfficialVerify(
      type: json['type'],
      desc: json['desc'],
    );
  }
}

class Vip {
  final int vipType;
  final int vipDueDate;
  final String dueRemark;
  final int accessStatus;
  final int vipStatus;
  final String vipStatusWarn;
  final int themeType;
  final VipLabel label;
  final int avatarSubscript;
  final String nicknameColor;

  Vip({
    required this.vipType,
    required this.vipDueDate,
    required this.dueRemark,
    required this.accessStatus,
    required this.vipStatus,
    required this.vipStatusWarn,
    required this.themeType,
    required this.label,
    required this.avatarSubscript,
    required this.nicknameColor,
  });

  factory Vip.fromJson(Map<String, dynamic> json) {
    return Vip(
      vipType: json['vipType'],
      vipDueDate: json['vipDueDate'],
      dueRemark: json['dueRemark'],
      accessStatus: json['accessStatus'],
      vipStatus: json['vipStatus'],
      vipStatusWarn: json['vipStatusWarn'],
      themeType: json['themeType'],
      label: VipLabel.fromJson(json['label']),
      avatarSubscript: json['avatar_subscript'],
      nicknameColor: json['nickname_color'],
    );
  }
}

class VipLabel {
  final String path;
  final String text;
  final String labelTheme;
  final String textColor;
  final int bgStyle;
  final String bgColor;
  final String borderColor;
  final bool useImgLabel;
  final String imgLabelUriHans;
  final String imgLabelUriHant;
  final String imgLabelUriHansStatic;
  final String imgLabelUriHantStatic;

  VipLabel({
    required this.path,
    required this.text,
    required this.labelTheme,
    required this.textColor,
    required this.bgStyle,
    required this.bgColor,
    required this.borderColor,
    required this.useImgLabel,
    required this.imgLabelUriHans,
    required this.imgLabelUriHant,
    required this.imgLabelUriHansStatic,
    required this.imgLabelUriHantStatic,
  });

  factory VipLabel.fromJson(Map<String, dynamic> json) {
    return VipLabel(
      path: json['path'],
      text: json['text'],
      labelTheme: json['label_theme'],
      textColor: json['text_color'],
      bgStyle: json['bg_style'],
      bgColor: json['bg_color'],
      borderColor: json['border_color'],
      useImgLabel: json['use_img_label'],
      imgLabelUriHans: json['img_label_uri_hans'],
      imgLabelUriHant: json['img_label_uri_hant'],
      imgLabelUriHansStatic: json['img_label_uri_hans_static'],
      imgLabelUriHantStatic: json['img_label_uri_hant_static'],
    );
  }
}

class UserSailing {
  final dynamic pendant;
  final dynamic cardbg;
  final dynamic cardbgWithFocus;

  UserSailing({
    this.pendant,
    this.cardbg,
    this.cardbgWithFocus,
  });

  factory UserSailing.fromJson(Map<String, dynamic> json) {
    return UserSailing(
      pendant: json['pendant'],
      cardbg: json['cardbg'],
      cardbgWithFocus: json['cardbg_with_focus'],
    );
  }
}

class AvatarItem {
  final ContainerSize containerSize;
  final FallbackLayers fallbackLayers;
  final String mid;

  AvatarItem({
    required this.containerSize,
    required this.fallbackLayers,
    required this.mid,
  });

  factory AvatarItem.fromJson(Map<String, dynamic> json) {
    return AvatarItem(
      containerSize: ContainerSize.fromJson(json['container_size']),
      fallbackLayers: FallbackLayers.fromJson(json['fallback_layers']),
      mid: json['mid'],
    );
  }
}

class ContainerSize {
  final double width;
  final double height;

  ContainerSize({
    required this.width,
    required this.height,
  });

  factory ContainerSize.fromJson(Map<String, dynamic> json) {
    return ContainerSize(
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
    );
  }
}

class FallbackLayers {
  final List<Layer> layers;
  final bool isCriticalGroup;

  FallbackLayers({
    required this.layers,
    required this.isCriticalGroup,
  });

  factory FallbackLayers.fromJson(Map<String, dynamic> json) {
    return FallbackLayers(
      layers: List<Layer>.from(json['layers'].map((x) => Layer.fromJson(x))),
      isCriticalGroup: json['is_critical_group'],
    );
  }
}

class Layer {
  final bool visible;
  final GeneralSpec generalSpec;
  final LayerConfig? layerConfig;
  final Resource resource;

  Layer({
    required this.visible,
    required this.generalSpec,
     this.layerConfig,
    required this.resource,
  });

  factory Layer.fromJson(Map<String, dynamic> json) {
    return Layer(
      visible: json['visible'],
      generalSpec: GeneralSpec.fromJson(json['general_spec']),
      // layerConfig: LayerConfig.fromJson(json['layer_config']),
      resource: Resource.fromJson(json['resource']),
    );
  }
}

class GeneralSpec {
  final PosSpec posSpec;
  final SizeSpec sizeSpec;
  final RenderSpec renderSpec;

  GeneralSpec({
    required this.posSpec,
    required this.sizeSpec,
    required this.renderSpec,
  });

  factory GeneralSpec.fromJson(Map<String, dynamic> json) {
    return GeneralSpec(
      posSpec: PosSpec.fromJson(json['pos_spec']),
      sizeSpec: SizeSpec.fromJson(json['size_spec']),
      renderSpec: RenderSpec.fromJson(json['render_spec']),
    );
  }
}

class PosSpec {
  final int coordinatePos;
  final double axisX;
  final double axisY;

  PosSpec({
    required this.coordinatePos,
    required this.axisX,
    required this.axisY,
  });

  factory PosSpec.fromJson(Map<String, dynamic> json) {
    return PosSpec(
      coordinatePos: json['coordinate_pos'],
      axisX: json['axis_x'].toDouble(),
      axisY: json['axis_y'].toDouble(),
    );
  }
}

class SizeSpec {
  final num width;
  final num height;

  SizeSpec({
    required this.width,
    required this.height,
  });

  factory SizeSpec.fromJson(Map<String, dynamic> json) {
    return SizeSpec(
      width: json['width'],
      height: json['height'],
    );
  }
}

class RenderSpec {
  final int opacity;

  RenderSpec({
    required this.opacity,
  });

  factory RenderSpec.fromJson(Map<String, dynamic> json) {
    return RenderSpec(
      opacity: json['opacity'],
    );
  }
}

class LayerConfig {
  final Tags tags;
  final bool isCritical;
  final LayerMask? layerMask;

  LayerConfig({
    required this.tags,
    required this.isCritical,
     this.layerMask,
  });

  factory LayerConfig.fromJson(Map<String, dynamic> json) {
    return LayerConfig(
      tags: Tags.fromJson(json['tags']),
      isCritical: json['is_critical'],
      // layerMask: LayerMask.fromJson(json['layer_mask']),
    );
  }
}

class Tags {
  final Map<String, dynamic> avatarLayer;

  Tags({
    required this.avatarLayer,
  });

  factory Tags.fromJson(Map<String, dynamic> json) {
    return Tags(
      avatarLayer: Map<String, dynamic>.from(json['AVATAR_LAYER']),
    );
  }
}

class LayerMask {
  final GeneralSpec generalSpec;
  final MaskSrc maskSrc;

  LayerMask({
    required this.generalSpec,
    required this.maskSrc,
  });

  factory LayerMask.fromJson(Map<String, dynamic> json) {
    return LayerMask(
      generalSpec: GeneralSpec.fromJson(json['general_spec']),
      maskSrc: MaskSrc.fromJson(json['mask_src']),
    );
  }
}

class MaskSrc {
  final int srcType;
  final Draw draw;

  MaskSrc({
    required this.srcType,
    required this.draw,
  });

  factory MaskSrc.fromJson(Map<String, dynamic> json) {
    return MaskSrc(
      srcType: json['src_type'],
      draw: Draw.fromJson(json['draw']),
    );
  }
}

class Draw {
  final int drawType;
  final int fillMode;
  final ColorConfig colorConfig;

  Draw({
    required this.drawType,
    required this.fillMode,
    required this.colorConfig,
  });

  factory Draw.fromJson(Map<String, dynamic> json) {
    return Draw(
      drawType: json['draw_type'],
      fillMode: json['fill_mode'],
      colorConfig: ColorConfig.fromJson(json['color_config']),
    );
  }
}

class ColorConfig {
  final Day day;

  ColorConfig({
    required this.day,
  });

  factory ColorConfig.fromJson(Map<String, dynamic> json) {
    return ColorConfig(
      day: Day.fromJson(json['day']),
    );
  }
}

class Day {
  final String argb;

  Day({
    required this.argb,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      argb: json['argb'],
    );
  }
}

class Resource {
  final int resType;
  final ResImage? resImage;

  Resource({
    required this.resType,
     this.resImage,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      resType: json['res_type'],
      // resImage: ResImage.fromJson(json['res_image']),
    );
  }
}

class ResImage {
  final ImageSrc imageSrc;

  ResImage({
    required this.imageSrc,
  });

  factory ResImage.fromJson(Map<String, dynamic> json) {
    return ResImage(
      imageSrc: ImageSrc.fromJson(json['image_src']),
    );
  }
}

class ImageSrc {
  final int srcType;
  final int placeholder;
  final Remote remote;

  ImageSrc({
    required this.srcType,
    required this.placeholder,
    required this.remote,
  });

  factory ImageSrc.fromJson(Map<String, dynamic> json) {
    return ImageSrc(
      srcType: json['src_type'],
      placeholder: json['placeholder'],
      remote: Remote.fromJson(json['remote']),
    );
  }
}

class Remote {
  final String url;
  final String bfsStyle;

  Remote({
    required this.url,
    required this.bfsStyle,
  });

  factory Remote.fromJson(Map<String, dynamic> json) {
    return Remote(
      url: json['url'],
      bfsStyle: json['bfs_style'],
    );
  }
}

class Content {
  final String message;
  final List<dynamic> members;
  final Emote? emote;
  final Map<String, dynamic> jumpUrl;
  final int maxLine;

  Content({
    required this.message,
    required this.members,
     this.emote,
    required this.jumpUrl,
    required this.maxLine,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      message: json['message'],
      members: List<dynamic>.from(json['members'].map((x) => x)),
      // emote: Emote.fromJson(json['emote']),
      jumpUrl: Map<String, dynamic>.from(json['jump_url']),
      maxLine: json['max_line'],
    );
  }
}

class Emote {
  final Map<String, EmoteDetail> emoteDetail;

  Emote({
    required this.emoteDetail,
  });

  factory Emote.fromJson(Map<String, dynamic> json) {
    return Emote(
      emoteDetail: Map.fromEntries(json.entries.map((e) => MapEntry(e.key, EmoteDetail.fromJson(e.value)))),
    );
  }
}

class EmoteDetail {
  final int id;
  final int packageId;
  final int state;
  final int type;
  final int attr;
  final String text;
  final String url;
  final Meta meta;
  final int mtime;
  final String jumpTitle;

  EmoteDetail({
    required this.id,
    required this.packageId,
    required this.state,
    required this.type,
    required this.attr,
    required this.text,
    required this.url,
    required this.meta,
    required this.mtime,
    required this.jumpTitle,
  });

  factory EmoteDetail.fromJson(Map<String, dynamic> json) {
    return EmoteDetail(
      id: json['id'],
      packageId: json['package_id'],
      state: json['state'],
      type: json['type'],
      attr: json['attr'],
      text: json['text'],
      url: json['url'],
      meta: Meta.fromJson(json['meta']),
      mtime: json['mtime'],
      jumpTitle: json['jump_title'],
    );
  }
}

class Meta {
  final int size;
  final List<String> suggest;

  Meta({
    required this.size,
    required this.suggest,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      size: json['size'],
      suggest: List<String>.from(json['suggest'].map((x) => x)),
    );
  }
}

class UpAction {
  final bool like;
  final bool reply;

  UpAction({
    required this.like,
    required this.reply,
  });

  factory UpAction.fromJson(Map<String, dynamic> json) {
    return UpAction(
      like: json['like'],
      reply: json['reply'],
    );
  }
}

class ReplyControl {
  final int maxLine;
  final String timeDesc;
  final String? location;

  ReplyControl({
    required this.maxLine,
    required this.timeDesc,
     this.location,
  });

  factory ReplyControl.fromJson(Map<String, dynamic> json) {
    return ReplyControl(
      maxLine: json['max_line'],
      timeDesc: json['time_desc'],
      location: json['location'],
    );
  }
}

class Folder {
  final bool hasFolded;
  final bool isFolded;
  final String rule;

  Folder({
    required this.hasFolded,
    required this.isFolded,
    required this.rule,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      hasFolded: json['has_folded'],
      isFolded: json['is_folded'],
      rule: json['rule'],
    );
  }
}

class Top {
  final dynamic admin;
  final dynamic upper;
  final dynamic vote;

  Top({
    this.admin,
    this.upper,
    this.vote,
  });

  factory Top.fromJson(Map<String, dynamic> json) {
    return Top(
      admin: json['admin'],
      upper: json['upper'],
      vote: json['vote'],
    );
  }
}

class UpSelection {
  final int pendingCount;
  final int ignoreCount;

  UpSelection({
    required this.pendingCount,
    required this.ignoreCount,
  });

  factory UpSelection.fromJson(Map<String, dynamic> json) {
    return UpSelection(
      pendingCount: json['pending_count'],
      ignoreCount: json['ignore_count'],
    );
  }
}

class Effects {
  final String preloading;

  Effects({
    required this.preloading,
  });

  factory Effects.fromJson(Map<String, dynamic> json) {
    return Effects(
      preloading: json['preloading'],
    );
  }
}

class Config {
  final int showtopic;
  final bool showUpFlag;
  final bool readOnly;

  Config({
    required this.showtopic,
    required this.showUpFlag,
    required this.readOnly,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      showtopic: json['showtopic'],
      showUpFlag: json['show_up_flag'],
      readOnly: json['read_only'],
    );
  }
}

class Upper {
  final int mid;

  Upper({
    required this.mid,
  });

  factory Upper.fromJson(Map<String, dynamic> json) {
    return Upper(
      mid: json['mid'],
    );
  }
}
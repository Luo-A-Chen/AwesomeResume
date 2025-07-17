class SearchResponse {
  final int code;
  final String message;
  final int ttl;
  final SearchData data;

  SearchResponse({
    required this.code,
    required this.message,
    required this.ttl,
    required this.data,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      code: json['code'],
      message: json['message'],
      ttl: json['ttl'],
      data: SearchData.fromJson(json['data']),
    );
  }
}

class SearchData {
  final String seid;
  final int page;
  final int pagesize;
  final int numResults;
  final int numPages;
  final String suggestKeyword;
  final String rqtType;
  final List<SearchResult> result;

  SearchData({
    required this.seid,
    required this.page,
    required this.pagesize,
    required this.numResults,
    required this.numPages,
    required this.suggestKeyword,
    required this.rqtType,
    required this.result,
  });

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      seid: json['seid'] ?? '',
      page: json['page'] ?? 0,
      pagesize: json['pagesize'] ?? 0,
      numResults: json['numResults'] ?? 0,
      numPages: json['numPages'] ?? 0,
      suggestKeyword: json['suggest_keyword'] ?? '',
      rqtType: json['rqt_type'] ?? '',
      result: (json['result'] as List?)
              ?.map((e) => SearchResult.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SearchResult {
  final String type;
  final int id;
  final String author;
  final int mid;
  final String typeid;
  final String typename;
  final String arcurl;
  final int aid;
  final String bvid;
  final String title;
  final String description;
  final String arcrank;
  final String pic;
  final int play;
  final int videoReview;
  final int favorites;
  final String tag;
  final int review;
  final int pubdate;
  final int senddate;
  final String duration;
  final bool badgepay;
  final List<String> hitColumns;
  final String viewType;
  final int isPay;
  final int isUnionVideo;

  SearchResult({
    required this.type,
    required this.id,
    required this.author,
    required this.mid,
    required this.typeid,
    required this.typename,
    required this.arcurl,
    required this.aid,
    required this.bvid,
    required this.title,
    required this.description,
    required this.arcrank,
    required this.pic,
    required this.play,
    required this.videoReview,
    required this.favorites,
    required this.tag,
    required this.review,
    required this.pubdate,
    required this.senddate,
    required this.duration,
    required this.badgepay,
    required this.hitColumns,
    required this.viewType,
    required this.isPay,
    required this.isUnionVideo,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      type: json['type'] ?? '',
      id: json['id'] ?? 0,
      author: json['author'] ?? '',
      mid: json['mid'] ?? 0,
      typeid: json['typeid'] ?? '',
      typename: json['typename'] ?? '',
      arcurl: json['arcurl'] ?? '',
      aid: json['aid'] ?? 0,
      bvid: json['bvid'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      arcrank: json['arcrank'] ?? '',
      pic: json['pic'] ?? '',
      play: json['play'] ?? 0,
      videoReview: json['video_review'] ?? 0,
      favorites: json['favorites'] ?? 0,
      tag: json['tag'] ?? '',
      review: json['review'] ?? 0,
      pubdate: json['pubdate'] ?? 0,
      senddate: json['senddate'] ?? 0,
      duration: json['duration'] ?? '',
      badgepay: json['badgepay'] ?? false,
      hitColumns: (json['hit_columns'] as List?)?.map((e) => e.toString()).toList() ?? [],
      viewType: json['view_type'] ?? '',
      isPay: json['is_pay'] ?? 0,
      isUnionVideo: json['is_union_video'] ?? 0,
    );
  }
}
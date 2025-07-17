class UserCookie {
  final String sessDATA;
  final String biliJct;
  final String dedeUserId;
  final String dedeUserIdCkMd5;

  UserCookie.fromJson(Map json)
      : sessDATA = json['SESSDATA'] ?? '',
        biliJct = json['bili_jct'] ?? '',
        dedeUserId = json['DedeUserID'] ?? '',
        dedeUserIdCkMd5 = json['DedeUserID__ckMd5'] ?? '';
}

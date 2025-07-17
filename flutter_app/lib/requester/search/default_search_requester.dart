part of '../requester.dart';

class _DefaultSearchRequester extends SearchRequester {
  final List<int> mixinKeyEncTab = [
    46,
    47,
    18,
    2,
    53,
    8,
    23,
    32,
    15,
    50,
    10,
    31,
    58,
    3,
    45,
    35,
    27,
    43,
    5,
    49,
    33,
    9,
    42,
    19,
    29,
    28,
    14,
    39,
    12,
    38,
    41,
    13,
    37,
    48,
    7,
    16,
    24,
    55,
    40,
    61,
    26,
    17,
    0,
    1,
    60,
    51,
    30,
    4,
    22,
    25,
    54,
    21,
    56,
    59,
    6,
    63,
    57,
    62,
    11,
    36,
    20,
    34,
    44,
    52
  ];
  // 对 imgKey 和 subKey 进行字符顺序打乱编码
  String getMixinKey(String orig) {
    String temp = '';
    for (int i = 0; i < mixinKeyEncTab.length; i++) {
      temp += orig[mixinKeyEncTab[i]];
    }
    return temp.substring(0, 32);
  }

  Map<String, dynamic> getWbi({
    required Map<String, dynamic> params,
    required String imgKey,
    required String subKey,
  }) {
    final String mixinKey = getMixinKey(imgKey + subKey);
    final DateTime now = DateTime.now();
    final int currTime = (now.millisecondsSinceEpoch / 1000).round();
    final RegExp chrFilter = RegExp(r"[!\'\(\)*]");
    final List<String> query = <String>[];
    final Map<String, dynamic> newParams = Map.from(params)
      ..addAll({"wts": currTime}); // 添加 wts 字段
    // 按照 key 重排参数
    final List<String> keys = newParams.keys.toList()..sort();
    for (String i in keys) {
      query.add(
          '${Uri.encodeComponent(i)}=${Uri.encodeComponent(newParams[i].toString().replaceAll(chrFilter, ''))}');
    }
    final String queryStr = query.join('&');
    final String wbiSign =
        md5.convert(utf8.encode(queryStr + mixinKey)).toString(); // 计算 w_rid
    return {'w_rid': wbiSign, 'wts': currTime.toString()};
  }

  @override
  Future<List<SearchResult>> getAllSearchResults() async {
    AppToast.unimplemented();
    return [];
  }

  @override
  Future<List<SearchResult>> getTypeSearchResults(
    String keyword, {
    num page = 1,
    String? order,
    num? duration,
    String? tids,
    required String searchType,
  }) async {
    AppToast.unimplemented();
    return [];
  }
}

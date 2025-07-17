part of 'requester.dart';

class _BlblRequester extends Requester {
  _BlblRequester()
      : super(
          serverName: '哔哩哔哩',
          videoRequester: _BlblVideoRequester(),
          searchRequester: _BlblSearchRequester(),
        );

  // 获取本地img_key和sub_key
  static Future<Map<String, dynamic>> _getWbiKeys() async {
    final wbiKeysStringGetKey = 'wbiKeysString';
    final wbiKeysDataGetKey = 'wbiKeysDataString';
    final DateTime now = DateTime.now();
    final wbiKeysString = LocalStorage.sp!.getString(wbiKeysStringGetKey);
    final wbiKeysData = DateTime.fromMillisecondsSinceEpoch(
        LocalStorage.sp!.getInt(wbiKeysDataGetKey) ?? 0);
    if (wbiKeysString != null && wbiKeysData.day == now.day) {
      return jsonDecode(wbiKeysString);
    }
    // else
    final Map<String, dynamic> wbiKeys = await _getNewWbiKeys();
    LocalStorage.sp!.setString(wbiKeysStringGetKey, jsonEncode(wbiKeys));
    LocalStorage.sp!.setInt(wbiKeysDataGetKey, now.millisecondsSinceEpoch);
    return wbiKeys;
  }

  // 重新获取img_key和sub_key
  static Future<Map<String, dynamic>> _getNewWbiKeys() async {
    var res = await Http.get('/web-interface/nav');
    print('重新获取img_key和sub_key');
    var data = res.data['data'];
    final String imgUrl = data['wbi_img']['img_url'];
    final String subUrl = data['wbi_img']['sub_url'];
    final Map<String, dynamic> wbiKeys = {
      'imgKey': imgUrl
          .substring(imgUrl.lastIndexOf('/') + 1, imgUrl.length)
          .split('.')[0],
      'subKey': subUrl
          .substring(subUrl.lastIndexOf('/') + 1, subUrl.length)
          .split('.')[0]
    };
    return wbiKeys;
  }

  static final List<int> _mixinKeyEncTab = [
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
  static String _getMixinKey(String orig) {
    String temp = '';
    for (int i = 0; i < _mixinKeyEncTab.length; i++) {
      temp += orig[_mixinKeyEncTab[i]];
    }
    return temp.substring(0, 32);
  }

  static Map<String, dynamic> _encWbi({
    required Map<String, dynamic> params,
    required String imgKey,
    required String subKey,
  }) {
    final String mixinKey = _getMixinKey(imgKey + subKey);
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

  static Future<Map<String, dynamic>> makSign(
      Map<String, dynamic> params) async {
    // params 为需要加密的请求参数
    final Map<String, dynamic> wbiKeys = await _getWbiKeys();
    final Map<String, dynamic> query = params
      ..addAll(_encWbi(
          params: params,
          imgKey: wbiKeys['imgKey'],
          subKey: wbiKeys['subKey']));
    return query;
  }

  @override
  Future<void> cinfigHttp() async {
    Http.cleanOptions();
    final res = await Http.get('https://www.bilibili.com/');
    final cookie = res.headers['set-cookie']?.join(';');
    // 设置baseUrl和cookie
    Http.setOptions(BaseOptions(
      baseUrl: 'https://api.bilibili.com/x',
      // 设置请求头防止请求不返回数据
      headers: {
        'cookie': cookie,
        "env": "prod",
        "app-key": "android64",
        "x-bili-aurora-zone": "sh001",
        "referer": "https://www.bilibili.com/"
      },
    ));
  }
}

class BlblLoginSuccessRes {
  int code;
  Data data;
  String message;
  int ttl;

  BlblLoginSuccessRes({
    required this.code,
    required this.data,
    required this.message,
    required this.ttl,
  });
}

class Data {
  int code;
  String message;
  String refreshToken;
  int timestamp;
  String url;

  Data({
    required this.code,
    required this.message,
    required this.refreshToken,
    required this.timestamp,
    required this.url,
  });
}

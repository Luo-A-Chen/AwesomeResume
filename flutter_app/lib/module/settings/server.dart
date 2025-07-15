import 'dart:io';

import 'package:dio/dio.dart';

import '../../api/net_requester.dart';

abstract class Server {
  final String name;
  final String baseUrl;
  final VideoUrl videoUrl;

  Future<void> initNetRequester();

  Server({
    required this.name,
    required this.baseUrl,
    required this.videoUrl,
  });

  static final List<Server> values = [
    DefaultServer(),
    BlblServer(),
  ];
}

class DefaultServer extends Server {
  DefaultServer()
      : super(
            name: '默认',
            baseUrl: 'https://default',
            videoUrl: VideoUrl(
              homeRcmd: null,
            ));

  @override
  Future<void> initNetRequester() {
    // TODO: implement initNetRequester
    return Future.value();
  }
}

class BlblServer extends Server {
  BlblServer()
      : super(
            name: '哔哩哔哩',
            baseUrl: 'https://api.bilibili.com/x',
            videoUrl: VideoUrl(
              homeRcmd: '/web-interface/wbi/index/top/feed/rcmd',
            ));

  @override
  Future<void> initNetRequester() async {
    NetRequester.cleanOptions();
    final res = await NetRequester.get('https://www.bilibili.com/');
    final cookie = res?.headers['set-cookie']?.join(';');
    // 设置baseUrl和cookie
    NetRequester.setOptions(BaseOptions(
      baseUrl: baseUrl,
      headers: {'cookie': cookie},
    ));
  }
}

class VideoUrl {
  final String? homeRcmd;

  VideoUrl({required this.homeRcmd});
}

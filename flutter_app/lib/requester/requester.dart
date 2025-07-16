import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../api/app_toast.dart';
import '../api/http.dart';
import '../module/video/video_response.dart';

part 'default_requester.dart';
part 'blbl_requester.dart';

abstract class Requester {
  final String serverName;
  final VideoRequester videoRequester;
  Future<void> initHttpCinfig();

  Requester({
    required this.serverName,
    required this.videoRequester,
  });

  static final List<Requester> values = [
    _DefaultRequester(),
    _BlblRequester(),
  ];
}

abstract class VideoRequester {
  Future<List<Video>> getRcmdVideos({
    required int pageIdx,
    int count = 10,
  });
}

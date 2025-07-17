import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/module/search/search_model.dart';

import '../api/app_toast.dart';
import '../api/http.dart';
import '../api/local_storage.dart';
import '../module/video/video_response.dart';
import 'search/search_requester.dart';
import 'video/video_requester.dart';

part 'default_requester.dart';
part 'blbl_requester.dart';
part 'video/blbl_video_requester.dart';
part 'video/default_video_requester.dart';
part 'search/blbl_search_requester.dart';
part 'search/default_search_requester.dart';

abstract class Requester {
  final String serverName;
  final VideoRequester videoRequester;
  final SearchRequester searchRequester;
  Future<void> cinfigHttp();

  Requester({
    required this.serverName,
    required this.videoRequester,
    required this.searchRequester,
  });

  static final List<Requester> values = [
    _DefaultRequester(),
    _BlblRequester(),
  ];
}
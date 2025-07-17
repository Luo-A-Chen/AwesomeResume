part of 'requester.dart';

class _DefaultRequester extends Requester {
  _DefaultRequester()
      : super(
          serverName: '官方（开发中）',
          videoRequester: _DefaultVideoRequester(),
          searchRequester: _DefaultSearchRequester(),
        );

  @override
  Future<void> cinfigHttp() {
    // TODO: implement initNetRequester
    return Future.value();
  }
}

class _DefaultVideoRequester extends VideoRequester {
  @override
  Future<List<Video>> getRcmdVideos({
    required int pageIdx,
    int count = 18,
  }) async {
    return await AppToast.serverUnimplemented();
  }
}
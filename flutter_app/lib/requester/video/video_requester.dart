import '../../module/video/video_response.dart';

abstract class VideoRequester {
  Future<List<Video>> getRcmdVideos({
    required int pageIdx,
    int count = 10,
  });
}

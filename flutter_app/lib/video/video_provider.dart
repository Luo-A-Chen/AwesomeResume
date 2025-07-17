import 'video_response.dart';

abstract class VideoProvider {
  Future<List<Video>> getRcmdVideos({
    required int pageIdx,
    int count = 10,
  });
}

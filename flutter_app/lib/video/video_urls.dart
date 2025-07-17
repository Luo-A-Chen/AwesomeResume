// TODO 放到服务器类去
import '../api/http.dart';

class VideoUrls {
  VideoUrls._();

  /// 获取视频信息，包括cid
  /// 参数说明：
  /// - bvid: 视频的bvid
  static Future<Map<String, dynamic>> getVideoInfo(String bvid) async {
    try {
      final headers = {
        'Referer': 'https://www.bilibili.com',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      };

      final queryParams = {
        'bvid': bvid,
      };

      final res = await Http.get(
        'https://api.bilibili.com/x/web-interface/view',
        params: queryParams,
        headers: headers,
      );
      return res.data['data'];
    } catch (e) {
      print('获取视频信息失败: $e');
      rethrow;
    }
  }

  /// 获取视频流URL
  ///
  /// 参数说明：
  /// - bvid: 视频的bvid
  /// - cid: 视频的cid
  /// - qn: 清晰度，默认为64（480P）
  /// - fnval: 视频格式标识，默认为16（dash格式）
  static Future<Map<String, dynamic>> getVideoStreamUrl({
    required int avid,
    required int cid,
    int qn = 64,
    int fnval = 16,
  }) async {
    try {
      final headers = {
        'Referer': 'https://www.bilibili.com',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      };

      final queryParams = {
        'avid': avid,
        'cid': cid.toString(),
        'qn': qn.toString(),
        'fnval': fnval.toString(),
        'fnver': '0',
        'fourk': '1',
      };

      final res = await Http.get(
        'https://api.bilibili.com/x/player/playurl',
        params: queryParams,
        headers: headers,
      );
      return res.data;
    } catch (e) {
      print('获取视频流URL失败: $e');
      rethrow;
    }
  }

  /// 解析视频流URL
  ///
  /// 从API返回的数据中解析出可用的视频流URL和音频流URL
  static Map<String, String?>? parseVideoUrl(Map<String, dynamic> data) {
    try {
      if (data['code'] != 0) {
        print('获取视频流失败: ${data['message']}');
        return null;
      }

      final videoData = data['data'];
      String? videoUrl;
      String? audioUrl;

      // 处理dash格式
      if (videoData.containsKey('dash')) {
        final dash = videoData['dash'];
        if (dash['video'] != null && dash['video'].isNotEmpty) {
          videoUrl = dash['video'][0]['baseUrl'];
        }

        // 获取音频流URL
        if (dash['audio'] != null && dash['audio'].isNotEmpty) {
          audioUrl = dash['audio'][0]['baseUrl'];
        }

        return {
          'videoUrl': videoUrl,
          'audioUrl': audioUrl,
        };
      }

      // 处理普通格式
      if (videoData.containsKey('durl') && videoData['durl'].isNotEmpty) {
        videoUrl = videoData['durl'][0]['url'];
        return {
          'videoUrl': videoUrl,
          'audioUrl': null, // 普通格式中音频和视频是一体的
        };
      }

      return null;
    } catch (e) {
      print('解析视频流URL失败: $e');
      return null;
    }
  }
}

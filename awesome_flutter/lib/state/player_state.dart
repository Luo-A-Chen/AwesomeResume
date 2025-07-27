import 'package:screen_brightness/screen_brightness.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

class PlayerState {
  static Future<void> initState() async {
    try {
      _brightness = await ScreenBrightness.instance.application;
    } catch (e) {
      print('应用内屏幕亮度初始化失败: $e，当前为$_brightness');
    }
    try {
      _brightness = await ScreenBrightness.instance.system;
    } catch (e) {
      print('系统屏幕亮度初始化失败: $e，当前为$_brightness');
    }
    try {
      // 初始化音量
      if (UniversalPlatform.isOhos) {
        _volume = 1; // 鸿蒙不支持调整系统音量，使用播放器音量
      } else {
        VolumeController.instance.showSystemUI = false;
        _volume = await VolumeController.instance.getVolume();
      }
    } catch (e) {
      print('音量初始化失败: $e，当前为$_volume');
    }
    VolumeController.instance.addListener((volume) => _volume = volume);
  }

  /// 视频控制器
  // static VideoPlayerController _videoCntlr =
  //     VideoPlayerController.networkUrl(Uri());
  // static VideoPlayerController get videoCntlr => _videoCntlr;
  // static Future<void> setVideoCntlr({
  //   required VideoPlayerController cntlr,
  //   bool startPlay = true,
  // }) async {
  //   _videoCntlr = cntlr;
  //   await _videoCntlr.initialize();
  //   if (startPlay) _videoCntlr.play();
  // }

  /// 音量，初始为25%
  static double _volume = 0.25;
  static double get volume => _volume;
  static Future<void> setVolume(
    double delta,
    VideoPlayerController cntlr,
  ) async {
    _volume = (_volume + delta).clamp(0.0, 1.0);
    try {
      if (UniversalPlatform.isOhos) {
        await cntlr.setVolume(_volume);
      } else {
        await VolumeController.instance.setVolume(_volume);
      }
    } catch (e) {
      cntlr.setVolume(_volume);
      print('音量设置失败: $e');
    }
  }

  /// 屏幕亮度，初始为25%
  static double _brightness = 0.25;
  static double get brightness => _brightness;
  static setBrightness(double delta) async {
    _brightness = (_brightness + delta).clamp(0.0, 1.0);
    try {
      ScreenBrightness.instance.setApplicationScreenBrightness(_brightness);
      ScreenBrightness.instance.setSystemScreenBrightness(_brightness);
    } catch (e) {
      print('屏幕亮度设置失败，: $e');
    }
  }
}

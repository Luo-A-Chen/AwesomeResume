import 'package:screen_brightness/screen_brightness.dart';
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
      VolumeController.instance.showSystemUI = false;
      // 初始化音量
      _volume = await VolumeController.instance.getVolume();
    } catch (e) {
      print('系统音量初始化失败: $e，当前为$_volume');
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
  static Future<void> setVolume(double delta) async {
    _volume = (_volume + delta).clamp(0.0, 1.0);
    try {
      await VolumeController.instance.setVolume(_volume);
    } catch (e) {
      // await _videoCntlr.setVolume(_volume);
      print('系统音量设置失败，: $e');
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

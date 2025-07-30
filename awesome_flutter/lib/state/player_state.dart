import 'package:screen_brightness/screen_brightness.dart';
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
      VolumeController.instance.showSystemUI = false;
      VolumeController.instance.addListener((volume) => _volume = volume);
      _volume = await VolumeController.instance.getVolume();
    } catch (e) {
      print('音量初始化失败，当前为$_volume: \n$e');
    }
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

  /// 音量，初始为应用内播放器100%
  static double _volume = 1.0;
  static double get volume => _volume;
  static void setVolume(
    double delta,
    VideoPlayerController cntlr,
  ) {
    _volume = (_volume + delta).clamp(0.0, 1.0);
    try {
      VolumeController.instance.setVolume(_volume);
      // TODO 音量调整实战
      // 实测Mac上只设置0%音量还会有很小的声音
      // 并且Mac在系统中调整音量为0%后会启动静音模式
      // 会导致app内调整了音量但系统静音而没有声音
      // 所以这里需要手动根据app内音量来设置系统是否静音
      if (_volume == 0) {
        VolumeController.instance.setMute(true);
      } else {
        VolumeController.instance.setMute(false);
      }
    } catch (e) {
      cntlr.setVolume(_volume);
      print('系统音量设置失败，仅调整应用内播放器音量: \n$e');
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

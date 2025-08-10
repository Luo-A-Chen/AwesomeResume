import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart' as f_toast;
import 'package:window_manager/window_manager.dart';

import 'api/toast.dart';
import 'api/local_storage.dart';
import 'state/player_state.dart';
import 'view/bottom_nav/main_page.dart';
import 'view/settings/settings.dart';
import 'view/mine/auth_provider.dart';

Future<void> main() async {
  VirtualGesturesBinding(); // 触摸模拟
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.initSP(); // 必须在运行软件前初始化本地存储
  await Settings.loadFromLocal(); // 从本地加载设置
  await Settings.instance.dataProvider?.initHttp(); // 初始化网络请求
  await AuthProvider().init(); // TODO 暂时只针对blbl
  await PlayerState.initState(); // 初始化播放器状态
  try {
    await windowManager.ensureInitialized();
  } catch (e) {
    // TODO 鸿蒙不支持
    print(e);
  }

  runApp(RestartableApp(keyNotifier: Settings.instance.appKeyNotifier));
}

class RestartableApp extends StatefulWidget {
  final ValueNotifier<Key> keyNotifier;

  const RestartableApp({super.key, required this.keyNotifier});

  @override
  State<RestartableApp> createState() => _RestartableAppState();
}

class _RestartableAppState extends State<RestartableApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.keyNotifier,
      builder: (context, key, _) {
        final primaryColor = Color(0xffFB7299);
        return MaterialApp(
          key: key,
          builder: f_toast.FToastBuilder(),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: primaryColor,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              // 禁用滑动内容后appbar变色
              scrolledUnderElevation: 0,
            ),
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
            scaffoldBackgroundColor:
                const Color.fromRGBO(238, 238, 238, 1), // 背景色
            splashFactory: NoSplash.splashFactory, // 禁用涟漪效果
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // 按钮文字颜色
                backgroundColor: primaryColor, // 按钮背景颜色
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: primaryColor,
              type: BottomNavigationBarType.fixed,
            ),
          ),
          // 语言设置
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Stack(
            children: [
              FocusScope(
                canRequestFocus: false,
                child: Builder(builder: (context) {
                  Toast.init(context); // 初始化toast
                  return const MainPage();
                }),
              ), // 虚拟鼠标光标
              ValueListenableBuilder<Offset>(
                valueListenable: VirtualGesturesBinding.cursorListenable,
                builder: (_, offset, __) => Positioned(
                  left: offset.dx - 8,
                  top: offset.dy - 8,
                  child: IgnorePointer(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 1. 全局虚拟手势绑定
class VirtualGesturesBinding extends WidgetsFlutterBinding {
  static Offset _cursor = const Offset(400, 300);
  static Offset get cursor => _cursor;

  static final _cursorNotifier = ValueNotifier<Offset>(_cursor);
  static ValueListenable<Offset> get cursorListenable => _cursorNotifier;

  // 手势状态管理
  static bool _isPointerDown = false;
  static HitTestResult? _currentHit;
  static int _pointerId = 1;
  static Offset? _lastPosition;

  // 流畅移动相关
  static bool _isMoving = false;
  static Offset _targetPosition = const Offset(400, 300);
  static Offset _velocity = Offset.zero;
  static Timer? _moveTimer;
  static Timer? _stopTimer;
  static LogicalKeyboardKey? _currentDirection;

  // 移动参数
  static const double _baseSpeed = 8.0;  // 基础速度
  static const double _maxSpeed = 25.0;  // 最大速度
  static const double _acceleration = 1.5; // 加速度
  static const double _friction = 0.85;    // 摩擦力
  static const int _frameRate = 60;        // 帧率

  @override
  void initInstances() {
    super.initInstances();
    HardwareKeyboard.instance.addHandler(_handleKey);
    print('VirtualGesturesBinding initialized');
  }

  bool _handleKey(KeyEvent event) {
    const step = 10.0;

    // 处理select/enter键 - 模拟手势按下/松开
    if (event.logicalKey == LogicalKeyboardKey.select || 
        event.logicalKey == LogicalKeyboardKey.enter) {
      if (event is KeyDownEvent && !_isPointerDown) {
        // 开始手势 - 相当于手指触摸屏幕
        _startGesture(_cursor);
        return true;
      } else if (event is KeyUpEvent && _isPointerDown) {
        // 结束手势 - 相当于手指离开屏幕
        _endGesture();
        return true;
      }
      return true;
    }

    // 处理方向键移动
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      Offset? newPosition;

      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          newPosition = Offset(_cursor.dx, (_cursor.dy - step).clamp(0, 1e9));
          break;
        case LogicalKeyboardKey.arrowDown:
          newPosition = Offset(_cursor.dx, (_cursor.dy + step).clamp(0, 1e9));
          break;
        case LogicalKeyboardKey.arrowLeft:
          newPosition = Offset((_cursor.dx - step).clamp(0, 1e9), _cursor.dy);
          break;
        case LogicalKeyboardKey.arrowRight:
          newPosition = Offset((_cursor.dx + step).clamp(0, 1e9), _cursor.dy);
          break;
        default:
          return false;
      }

      if (newPosition != null) {
        _updateCursor(newPosition);
        return true;
      }
    }

    return false;
  }

  void _startGesture(Offset position) {
    print('开始手势：PointerDown at $position');
    _isPointerDown = true;
    _lastPosition = position;

    // 执行命中测试
    _currentHit = HitTestResult();
    RendererBinding.instance.hitTest(_currentHit!, position);

    // 创建并分发PointerDown事件
    final down = PointerDownEvent(
      // pointerId: _pointerId,
      position: position,
      timeStamp: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
      kind: PointerDeviceKind.touch,
    );

    RendererBinding.instance.dispatchEvent(down, _currentHit!);
    GestureBinding.instance.handlePointerEvent(down);
  }

  void _updateCursor(Offset newPosition) {
    _cursor = newPosition;
    _notifyCursorMoved();

    // 如果正在进行手势，发送PointerMove事件（拖拽）
    if (_isPointerDown && _currentHit != null && _lastPosition != null) {
      print('手势拖拽：PointerMove from $_lastPosition to $newPosition');

      final move = PointerMoveEvent(
        // pointerId: _pointerId,
        position: newPosition,
        delta: newPosition - _lastPosition!,
        timeStamp: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
        kind: PointerDeviceKind.touch,
      );

      RendererBinding.instance.dispatchEvent(move, _currentHit!);
      GestureBinding.instance.handlePointerEvent(move);
      _lastPosition = newPosition;
    }
  }

  void _endGesture() {
    if (!_isPointerDown || _currentHit == null) return;

    print('结束手势：PointerUp at $_cursor');

    final up = PointerUpEvent(
      // pointerId: _pointerId,
      position: _cursor,
      timeStamp: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
      kind: PointerDeviceKind.touch,
    );

    RendererBinding.instance.dispatchEvent(up, _currentHit!);
    GestureBinding.instance.handlePointerEvent(up);

    // 重置状态
    _isPointerDown = false;
    _currentHit = null;
    _lastPosition = null;
    _pointerId++; // 为下次手势使用新的指针ID
  }

  void _notifyCursorMoved() {
    _cursorNotifier.value = _cursor;
  }
}

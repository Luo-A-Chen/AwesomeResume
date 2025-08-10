import 'dart:async';

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
  TouchBallBinding(); // 初始化全局触摸球
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
        return FocusScope(
          // 禁用焦点
          canRequestFocus: false,
          child: MaterialApp(
            key: key,
            builder: (context, child) {
              // 首先应用 FToast builder
              Widget toastChild = f_toast.FToastBuilder().call(context, child);
              // 然后添加触控球
              return Stack(
                children: [
                  toastChild,
                  // 全局虚拟触控球
                  ValueListenableBuilder<Offset>(
                    valueListenable: TouchBallBinding.positionNotifier,
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
              );
            },
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
            home: Builder(builder: (context) {
              Toast.init(context); // 初始化toast
              // 为触控球设置屏幕尺寸
              TouchBallBinding.screenSize = MediaQuery.of(context).size;
              return const MainPage();
            }),
          ),
        );
      },
    );
  }
}

// 触控球绑定
class TouchBallBinding extends WidgetsFlutterBinding {
  static Size screenSize = Size(3840, 2160);
  static Offset _position = const Offset(-100, -100);
  static Offset get cursor => _position;

  static final _positionNotifier = ValueNotifier<Offset>(_position);
  static ValueListenable<Offset> get positionNotifier => _positionNotifier;

  // 手势状态管理
  static bool _isScrolling = false;
  static HitTestResult? _currentHit;
  static Offset? _lastPosition;
  static final _pointerId = 1; // 添加唯一的指针ID

  // 移动相关
  static bool _isMoving = false;
  static Timer? _moveTimer;
  static LogicalKeyboardKey? _currentDirection;

  // 移动参数
  static const double _moveSpeed = 4.0; // 移动速度
  static const int _frameRate = 120; // 帧率

  @override
  void initInstances() {
    super.initInstances();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  bool _handleKey(KeyEvent event) {
    // 处理select/enter键 - 模拟手势按下/松开
    if (event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.enter) {
      if (event is KeyDownEvent && !_isScrolling) {
        // 开始手势 - 相当于手指触摸屏幕
        _startTouch(_position);
        return true;
      } else if (event is KeyUpEvent && _isScrolling) {
        // 结束手势 - 相当于手指离开屏幕
        _endTouch();
        return true;
      }
      return true;
    }

    // 处理方向键移动
    LogicalKeyboardKey? direction;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowRight:
        direction = event.logicalKey;
        break;
      default:
        return false;
    }

    if (event is KeyDownEvent) {
      // 按键按下 - 开始流畅移动
      _starthMove(direction);
      return true;
    } else if (event is KeyUpEvent) {
      // 按键松开 - 停止该方向的移动
      _stopMove(direction);
      return true;
    }

    return false;
  }

  void _starthMove(LogicalKeyboardKey direction) {
    _currentDirection = direction;
    if (!_isMoving) {
      _isMoving = true;
      _startMoveAnimation();
    }
  }

  void _stopMove(LogicalKeyboardKey direction) {
    // 只有当前方向键松开时才停止
    if (_currentDirection == direction) {
      _isMoving = false;
      _currentDirection = null;
      _moveTimer?.cancel();
      _clampPosition();
    }
  }

  void _clampPosition() {
    if (_isScrolling) return;
    _position = Offset(
      _position.dx.clamp(0, screenSize.width),
      _position.dy.clamp(0, screenSize.height),
    );
    _notifyMoved();
  }

  Offset _getDirectionVector(LogicalKeyboardKey direction) {
    switch (direction) {
      case LogicalKeyboardKey.arrowUp:
        return const Offset(0, -1);
      case LogicalKeyboardKey.arrowDown:
        return const Offset(0, 1);
      case LogicalKeyboardKey.arrowLeft:
        return const Offset(-1, 0);
      case LogicalKeyboardKey.arrowRight:
        return const Offset(1, 0);
      default:
        return Offset.zero;
    }
  }

  void _startMoveAnimation() {
    _moveTimer?.cancel();
    _moveTimer =
        Timer.periodic(Duration(milliseconds: 1000 ~/ _frameRate), (timer) {
      if (!_isMoving) {
        timer.cancel();
        return;
      }
      _updatePisation();
    });
  }

  void _updatePisation() {
    if (!_isMoving || _currentDirection == null) {
      return;
    }
    // 根据方向计算新位置
    final direction = _getDirectionVector(_currentDirection!);
    final newPosition = Offset(
      (_position.dx + direction.dx * _moveSpeed),
      (_position.dy + direction.dy * _moveSpeed),
    );
    _position = newPosition;
    _notifyMoved();

    // 如果正在进行手势，发送拖拽事件
    if (_isScrolling && _currentHit != null && _lastPosition != null) {
      final move = PointerMoveEvent(
        pointer: _pointerId,
        position: newPosition,
        delta: newPosition - _lastPosition!,
        timeStamp:
            Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
        kind: PointerDeviceKind.touch,
      );

      RendererBinding.instance.dispatchEvent(move, _currentHit!);
      GestureBinding.instance.handlePointerEvent(move);
      _lastPosition = newPosition;
    }
  }

  void _startTouch(Offset position) {
    print('开始手势：PointerDown at $position');
    _isScrolling = true;
    _lastPosition = position;

    // 执行命中测试
    _currentHit = HitTestResult();
    RendererBinding.instance.hitTest(_currentHit!, position);

    // 创建并分发PointerDown事件
    final down = PointerDownEvent(
      pointer: _pointerId,
      position: position,
      timeStamp: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
      kind: PointerDeviceKind.touch,
    );

    RendererBinding.instance.dispatchEvent(down, _currentHit!);
    GestureBinding.instance.handlePointerEvent(down);
  }

  void _endTouch() {
    if (!_isScrolling || _currentHit == null) return;
    print('结束手势：PointerUp at $_position');
    final up = PointerUpEvent(
      pointer: _pointerId,
      position: _position,
      timeStamp: Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
      kind: PointerDeviceKind.touch,
    );
    RendererBinding.instance.dispatchEvent(up, _currentHit!);
    GestureBinding.instance.handlePointerEvent(up);
    // 重置状态
    _isScrolling = false;
    _currentHit = null;
    _lastPosition = null;
    // 限制小球位置在屏幕范围内
    _clampPosition();
  }

  void _notifyMoved() {
    _positionNotifier.value = _position;
  }
}

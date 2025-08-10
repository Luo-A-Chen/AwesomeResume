import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class TouchBallBinding extends WidgetsFlutterBinding {
  static Size screenSize = Size(3840, 2160);
  static Offset _position = const Offset(400, 300);

  static final positionNotifire = ValueNotifier<Offset>(_position);

  // 手势状态管理
  static bool _isPointerDown = false;
  static HitTestResult? _currentHit;
  static Offset? _lastPosition;
  static int _pointerId = 0; // 动态生成指针ID

  // 移动相关
  static bool _ballIsMoving = false;
  static Timer? _moveTimer;
  static LogicalKeyboardKey? _currentDirection;

  // 移动参数
  static const double _moveSpeed = 4.0; // 移动速度
  static const int _frameRate = 120; // 帧率

  @override
  void initInstances() {
    super.initInstances();
    HardwareKeyboard.instance.addHandler(_handleKey);
    print('TouchBallBinding initialized');
  }

  bool _handleKey(KeyEvent event) {
    // 处理select/enter键 - 模拟触控
    if (event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.enter) {
      if (event is KeyDownEvent && !_isPointerDown) {
        // 开始触控
        _startTouch(_position);
        return true;
      } else if (event is KeyUpEvent && _isPointerDown) {
        // 结束触控
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
      // 按键按下 - 开始移动
      _startMovement(direction);
      return true;
    } else if (event is KeyUpEvent) {
      // 按键松开 - 停止该方向的移动
      _stopMovement(direction);
      return true;
    }

    return false;
  }

  void _startMovement(LogicalKeyboardKey direction) {
    _currentDirection = direction;

    if (!_ballIsMoving) {
      _ballIsMoving = true;
      _startMoveAnimation();
    }
  }

  void _stopMovement(LogicalKeyboardKey direction) {
    // 只有当前方向键松开时才停止
    if (_currentDirection == direction) {
      _ballIsMoving = false;
      _currentDirection = null;
      _moveTimer?.cancel();
    }
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
      if (!_ballIsMoving) {
        timer.cancel();
        return;
      }

      _updatePosition();
    });
  }

  void _updatePosition() {
    if (!_ballIsMoving || _currentDirection == null) {
      return;
    }

    // 根据方向计算新位置
    final direction = _getDirectionVector(_currentDirection!);
    final newPosition = Offset(
      (_position.dx + direction.dx * _moveSpeed),
      (_position.dy + direction.dy * _moveSpeed),
    );

    _position = newPosition;
    if (!_isPointerDown) {
      _position = Offset(
        _position.dx.clamp(0, screenSize.width),
        _position.dy.clamp(0, screenSize.height),
      );
    }
    // 如果正在触控，发送移动事件
    else if (_currentHit != null && _lastPosition != null) {
      _sendMoveEvent(newPosition);
    }
    _notifyPositionChanged();
  }

  void _startTouch(Offset position) {
    if (_isPointerDown) {
      print('警告：已有触控进行中，忽略新的触控请求');
      return;
    }

    print('开始触控：$position');

    // 生成新的指针ID
    _pointerId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _isPointerDown = true;
    _lastPosition = position;

    // 执行命中测试
    _currentHit = HitTestResult();
    try {
      RendererBinding.instance.hitTest(_currentHit!, position);

      // 创建并分发PointerDown事件
      final down = PointerDownEvent(
        pointer: _pointerId,
        position: position,
        timeStamp:
            Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
        kind: PointerDeviceKind.touch,
      );

      RendererBinding.instance.dispatchEvent(down, _currentHit!);
      GestureBinding.instance.handlePointerEvent(down);

      print('触控开始成功');
    } catch (e) {
      print('触控开始失败: $e');
      _resetTouchState();
    }
  }

  void _sendMoveEvent(Offset newPosition) {
    if (!_isPointerDown || _currentHit == null || _lastPosition == null) {
      return;
    }

    try {
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
    } catch (e) {
      print('发送移动事件失败: $e');
      _resetTouchState();
    }
  }

  void _endTouch() {
    if (!_isPointerDown || _currentHit == null) {
      print('警告：没有进行中的触控可以结束');
      return;
    }
    print('结束触控：$_position');
    try {
      final up = PointerUpEvent(
        pointer: _pointerId,
        position: _position,
        timeStamp:
            Duration(milliseconds: DateTime.now().millisecondsSinceEpoch),
        kind: PointerDeviceKind.touch,
      );
      RendererBinding.instance.dispatchEvent(up, _currentHit!);
      GestureBinding.instance.handlePointerEvent(up);
      print('触控结束成功');
    } catch (e) {
      print('触控结束失败: $e');
    } finally {
      _resetTouchState();
    }
  }

  void _resetTouchState() {
    _isPointerDown = false;
    _currentHit = null;
    _lastPosition = null;
  }

  void _notifyPositionChanged() {
    positionNotifire.value = _position;
  }
}

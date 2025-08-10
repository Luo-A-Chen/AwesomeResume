import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_flutter/api/nav_extension.dart';
import 'package:video_player/video_player.dart';
import 'package:window_manager/window_manager.dart';

import '../../state/player_state.dart';

class VidioPlayView extends StatefulWidget {
  final int avid; // 视频的avid
  final int cid; // 视频的cid
  final bool isfullScreen; // 是否全屏
  final String? title; // 用于非全屏时顶部返回条的标题
  final VideoPlayerController cntlr;

  const VidioPlayView({
    super.key,
    required this.avid,
    required this.cid,
    required this.cntlr,
    required this.isfullScreen,
    this.title,
  });

  @override
  State<VidioPlayView> createState() => _VidioPlayViewState();
}

class _VidioPlayViewState extends State<VidioPlayView> {
  bool _showCntlrHub = false;
  Timer? _controlsTimer;
  Duration _position = Duration.zero;
  bool _isPlaying = true;
  bool _isBuffering = true;
  bool _positionSetting = false; // 是否正在调整进度
  bool _isSettingBrightness = false; // 是否正在调整亮度
  bool _isSettingVolume = false; // 是否正在调整音量
  PointerDeviceKind? _tapKind; // 可以判断是鼠标还是触屏等
  bool _isMultipleSpeed = false; // 判断是否长按倍数播放
  bool _isLock = false; // 是否锁定

  Future<void> _setBrightnessOrVolume(DragUpdateDetails details) async {
    final delta = -details.delta.dy * 0.01; // 调整灵敏度
    _isSettingBrightness
        ? await PlayerState.setBrightness(delta)
        : await PlayerState.setVolume(delta, widget.cntlr);
    setState(() {
      // 更新亮度或音量值
    });
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
    widget.cntlr.addListener(_onControllerUpdated);
  }

  @override
  void dispose() {
    super.dispose();
    _controlsTimer?.cancel();
    widget.cntlr.removeListener(_onControllerUpdated);
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
  }

  bool _onKeyEvent(KeyEvent event) {
    if (event is! KeyUpEvent) return true;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
        _togglePlay();
    }
    return true;
  }

  void _onControllerUpdated() {
    var position = widget.cntlr.value.position;
    bool isBuffering =
        _isPlaying && position - _position < const Duration(milliseconds: 50);
    if (_isBuffering != isBuffering) {
      setState(() {
        _isBuffering = isBuffering;
      });
    }
    if (_position.inSeconds != position.inSeconds) {
      setState(() {
        _position = position;
      });
    }
  }

  void _exitFullScreen() {
    try {
      windowManager.setFullScreen(false);
    } catch (e) {
      // TODO 鸿蒙不支持
      print(e);
    }
    // 退出全屏时，恢复屏幕方向
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    // 恢复状态栏
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    context.pop();
  }

  void _enterFullScreen() {
    try {
      windowManager.setFullScreen(true);
    } catch (e) {
      // TODO 鸿蒙PC全屏
      print(e);
    }
    if (widget.cntlr.value.aspectRatio > 1) {
      // 如果视频是横屏内容，需要锁定屏幕方向为横向
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      // 设置状态栏全屏显示模式
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    // Scaffold包裹，防止样式异常
    context.push(Scaffold(
      body: VidioPlayView(
        title: widget.title,
        isfullScreen: true,
        avid: widget.avid,
        cntlr: widget.cntlr,
        cid: widget.cid,
      ),
    ));
  }

  void _toggleFullScreen() {
    // Toast.showWarning('全屏切换待开发');
    // TODO 全屏功能
    if (widget.isfullScreen) {
      // 退出全屏
      _exitFullScreen();
    } else {
      // 进入全屏
      _enterFullScreen();
    }
  }

  void _toggleControls([bool? show]) {
    if (!mounted) return;
    setState(() {
      _showCntlrHub = show ?? !_showCntlrHub;
    });
    _controlsTimer?.cancel();
    // 控制Hub显示5秒后自动隐藏
    if (_showCntlrHub) {
      _controlsTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showCntlrHub = false;
          });
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return [if (hours > 0) hours, minutes, seconds].map(twoDigits).join(':');
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    _isPlaying ? widget.cntlr.play() : widget.cntlr.pause();
  }

  void _setPosition(details) {
    // 处理水平拖动以调整进度
    final position = widget.cntlr.value.position;
    final duration = widget.cntlr.value.duration;
    final delta = details.delta.dx * 1; // TODO 调整灵敏度
    final newPosition = position + Duration(seconds: delta.round());
    if (newPosition < duration && newPosition >= Duration.zero) {
      widget.cntlr.seekTo(newPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    // MouseRegion包裹在Stack外层，防止GestureDetector与_hub竞争监听
    return ColoredBox(
      color: Colors.black,
      child: PopScope(
        canPop: !widget.isfullScreen,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _isLock ? _toggleControls(true) : _exitFullScreen();
        },
        child: MouseRegion(
          onEnter: (_) => _toggleControls(true),
          onExit: (_) => _toggleControls(false),
          onHover: (_) => _toggleControls(true),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 视频本身
              widget.cntlr.value.hasError
                  ? const Center(
                      child: Text(
                        '视频加载失败',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: widget.cntlr.value.aspectRatio,
                      child: VideoPlayer(widget.cntlr),
                    ),

              _messageHub(), // 中间的提示信息
              // 注意GestureDetector的层级顺序
              // 放在控制Hub层的下一层
              Padding(
                // 防止操作状态栏时误触，具体值未测试
                padding: const EdgeInsets.only(top: 50),
                child: GestureDetector(
                  onTap: _tapKind == PointerDeviceKind.mouse
                      ? _togglePlay
                      : _toggleControls,
                  onLongPressStart: (_) {
                    widget.cntlr.setPlaybackSpeed(2.0); // 设置倍速播放
                    setState(() {
                      _isMultipleSpeed = true;
                    });
                  },
                  onLongPressEnd: (_) {
                    widget.cntlr.setPlaybackSpeed(1.0); // 恢复正常速度
                    setState(() {
                      _isMultipleSpeed = false;
                    });
                  },
                  // 更新点击类型
                  onTapDown: (details) => _tapKind = details.kind,
                  onDoubleTap: _tapKind == PointerDeviceKind.mouse
                      ? _toggleFullScreen
                      : _togglePlay,
                  // 音量和亮度调整
                  onVerticalDragStart: (details) => setState(() {
                    // 左边亮度，右边音量
                    details.localPosition.dx <
                            MediaQuery.of(context).size.width / 2
                        ? _isSettingBrightness = true
                        : _isSettingVolume = true;
                  }),
                  onVerticalDragUpdate: _setBrightnessOrVolume,
                  onVerticalDragEnd: (_) => setState(() {
                    _isSettingBrightness = false;
                    _isSettingVolume = false;
                  }),
                  // 进度调整
                  onHorizontalDragStart: (_) => setState(() {
                    _positionSetting = true;
                  }),
                  onHorizontalDragUpdate: _setPosition,
                  onHorizontalDragEnd: (_) => setState(() {
                    _positionSetting = false;
                  }),
                ),
              ),
              if (!_isLock && _showCntlrHub)
                ...__unLockedHub() // 未锁定时的Hub
              else
                // 底部细小进度条
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 7, // 和哔哩哔哩比较一致
                  child: SizedBox(
                    child: VideoProgressIndicator(
                      widget.cntlr,
                      allowScrubbing: false,
                    ),
                  ),
                ),
              // 锁定时的Hub，包含一个GestureDetector
              // 挡住之前的GestureDetector监听，从而实现锁定功能
              if (_isLock) ..._lockedHub()
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageHub() {
    String? centent;
    if (_isMultipleSpeed) {
      centent = '倍数播放中';
    } else if (_isSettingBrightness) {
      centent = '亮度：${(PlayerState.brightness * 100).toInt()}%';
    } else if (_isSettingVolume) {
      centent = '音量：${(PlayerState.volume * 100).toInt()}%';
    } else if (_positionSetting) {
      centent =
          '${_formatDuration(widget.cntlr.value.position)}/${_formatDuration(widget.cntlr.value.duration)}';
    } else if (_isBuffering) {
      centent = '正在缓冲...';
    }
    if (centent == null) return const SizedBox();
    return Center(
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          centent,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  List<Widget> __unLockedHub() {
    return [
      // 顶部控制栏
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: Colors.black12,
          height: 40,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _exitFullScreen,
              ),
              Expanded(
                child: Text(
                  widget.title ?? '',
                  style: const TextStyle(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 可以在这里添加其他按钮，例如投屏
            ],
          ),
        ),
      ),

      // 锁定按钮
      if (widget.isfullScreen)
        Positioned(
          right: 10,
          child: IconButton(
            icon: Icon(Icons.lock_open, color: Colors.white),
            onPressed: () => setState(() => _isLock = true),
          ),
        ),

      // 底部控制栏
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: Colors.black12,
          height: 40,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _togglePlay,
              ),
              Expanded(
                child: VideoProgressIndicator(
                  widget.cntlr,
                  allowScrubbing: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              Text(
                '${_formatDuration(widget.cntlr.value.position)}/${_formatDuration(widget.cntlr.value.duration)}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              IconButton(
                icon: Icon(
                  widget.isfullScreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: _toggleFullScreen,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _lockedHub() {
    return [
      GestureDetector(
        onPanDown: (_) => _toggleControls(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
        ),
      ),
      if (_showCntlrHub) ...[
        Positioned(
          left: 20,
          child: IconButton(
            icon: Icon(Icons.lock, color: Colors.white),
            onPressed: () => setState(() => _isLock = false),
          ),
        ),
        Positioned(
          right: 10,
          child: IconButton(
            icon: Icon(Icons.lock, color: Colors.white),
            onPressed: () => setState(() => _isLock = false),
          ),
        ),
      ]
    ];
  }
}

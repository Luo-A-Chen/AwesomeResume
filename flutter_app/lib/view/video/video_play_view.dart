import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/api/nav_extension.dart';
import 'package:video_player/video_player.dart';

import '../../api/toast.dart';
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
  bool _showControls = false;
  Timer? _controlsTimer;
  Duration _position = Duration.zero;
  bool _isPlaying = true;
  bool _isBuffering = true;
  bool _positionSetting = false; // 是否正在调整进度
  bool _brightnessSetting = false; // 是否正在调整亮度
  bool _volumeSetting = false; // 是否正在调整音量
  PointerDeviceKind? _tapKind; // 可以判断是鼠标还是触屏等
  bool _dragLeft = false; // 用于判断左右

  Future<void> _setBrightnessOrVolume(DragUpdateDetails details) async {
    final delta = -details.delta.dy * 0.01; // 调整灵敏度
    if (_brightnessSetting) {
      await PlayerState.setBrightness(delta);
    } else if (_volumeSetting) {
      await PlayerState.setVolume(delta);
    }
    setState(() {}); // 更新UI显示当前亮度或音量
  }

  @override
  void initState() {
    super.initState();
    widget.cntlr.addListener(_onControllerUpdated);
  }

  @override
  void dispose() {
    super.dispose();
    _controlsTimer?.cancel();
    widget.cntlr.removeListener(_onControllerUpdated);
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

  Future<void> _exitFullScreen() async {
    // 退出全屏时，恢复屏幕方向
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // 恢复状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    // ignore: use_build_context_synchronously
    context.pop();
  }

  void _enterFullScreen() async {
    // 如果视频是横屏内容，需要锁定屏幕方向为横向
    if (widget.cntlr.value.aspectRatio > 1) {
      print('锁定屏幕方向为横向');
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      // 隐藏状态栏
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
    // ignore: use_build_context_synchronously
    context.push(Scaffold(
      body: SafeArea(
        child: PopScope(
          canPop: false,
          // 重写返回按钮的行为
          onPopInvoked: (didPop) {
            if (!didPop) _exitFullScreen();
          },
          child: VidioPlayView(
            title: widget.title,
            isfullScreen: true,
            avid: widget.avid,
            cntlr: widget.cntlr,
            cid: widget.cid,
          ),
        ),
      ),
    ));
  }

  void _toggleFullScreen() async {
    // Toast.showWarning('全屏切换待开发');
    // TODO 全屏功能
    if (widget.isfullScreen) {
      // 退出全屏
      await _exitFullScreen();
    } else {
      // 进入全屏
      _enterFullScreen();
    }
  }

  void _toggleControls([bool? show]) {
    if (!mounted) return;
    setState(() {
      _showControls = show ?? !_showControls;
    });

    _controlsTimer?.cancel();
    if (_showControls) {
      _controlsTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showControls = false;
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
    return MouseRegion(
      onEnter: _tapKind == PointerDeviceKind.mouse
          ? (_) => _toggleControls(true)
          : null,
      onExit: _tapKind == PointerDeviceKind.mouse
          ? (_) => _toggleControls(false)
          : null,
      onHover: _tapKind == PointerDeviceKind.mouse
          ? (_) => _toggleControls(true)
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _tapKind == PointerDeviceKind.mouse
                ? _togglePlay
                : _toggleControls,
            onTapDown: (details) {
              _tapKind = details.kind;
            },
            onDoubleTap: _tapKind == PointerDeviceKind.mouse
                ? _toggleFullScreen
                : _togglePlay,
            onVerticalDragStart: (details) => setState(() {
              _dragLeft = details.localPosition.dx <
                  MediaQuery.of(context).size.width / 2;
              _dragLeft ? _brightnessSetting = true : _volumeSetting = true;
            }),
            onVerticalDragEnd: (_) => setState(() {
              _brightnessSetting = false;
              _volumeSetting = false;
            }),
            onVerticalDragUpdate: _setBrightnessOrVolume,
            onHorizontalDragStart: (_) => setState(() {
              _positionSetting = true;
            }),
            onHorizontalDragEnd: (_) => setState(() {
              _positionSetting = false;
            }),
            onHorizontalDragUpdate: _setPosition,
            child: widget.cntlr.value.hasError
                ? const Center(
                    child: Text(
                      '视频加载失败',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  )
                : VideoPlayer(widget.cntlr),
          ),
          if (_brightnessSetting || _volumeSetting)
            Center(
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _brightnessSetting
                      ? '亮度：${(PlayerState.brightness * 100).toInt()}%'
                      : '音量：${(PlayerState.volume * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          // 这里else if让音量/亮度、进度和缓冲只能显示一个
          else if (_positionSetting) // 显示进度调整条
            Center(
              child: GestureDetector(
                onHorizontalDragUpdate: _setPosition,
                child: Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${_formatDuration(widget.cntlr.value.position)}/${_formatDuration(widget.cntlr.value.duration)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            )
          else if (_positionSetting) // 显示进度调整条
            Center(
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${_formatDuration(widget.cntlr.value.position)}/${_formatDuration(widget.cntlr.value.duration)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          else if (_isBuffering) // 显示缓冲指示器
            const Center(child: CircularProgressIndicator()),
          // 控制界面
          if (_showControls)
            ..._hub()
          else
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
        ],
      ),
    );
  }

  List _hub() {
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
}

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/api/nav_extension.dart';
import 'package:video_player/video_player.dart';

class BlblPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String pic;
  final bool isfullScreen; // 是否全屏
  final String? title; // 用于非全屏时顶部返回条的标题

  const BlblPlayer({
    super.key,
    required this.controller,
    required this.pic,
    required this.isfullScreen,
    this.title,
  });

  @override
  State<BlblPlayer> createState() => _BlblPlayerState();
}

class _BlblPlayerState extends State<BlblPlayer> {
  bool _showControls = false;
  Timer? _controlsTimer;

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
    if (widget.controller.value.aspectRatio > 1) {
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
          child: BlblPlayer(
            controller: widget.controller,
            pic: widget.pic,
            title: widget.title,
            isfullScreen: true,
          ),
        ),
      ),
    ));
  }

  void _toggleFullScreen() async {
    if (widget.isfullScreen) {
      // 退出全屏
      await _exitFullScreen();
    } else {
      // 进入全屏
      _enterFullScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdated);
    _toggleControls();
  }

  void _onControllerUpdated() {
    // 可以在这里处理 controller 的其他状态更新，例如错误
    if (widget.controller.value.hasError) {
      if (mounted) {
        setState(() {}); // 更新UI以显示错误信息
      }
    }
    // 确保在 controller 更新时刷新状态，例如播放/暂停按钮
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleControls() {
    if (!mounted) return;
    setState(() {
      _showControls = !_showControls;
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

  // @override
  // void didUpdateWidget(covariant BlblPlayer oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.controller != oldWidget.controller) {
  //     oldWidget.controller.removeListener(_onControllerUpdated);
  //     widget.controller.addListener(_onControllerUpdated);
  //     if (mounted) {
  //       setState(() {}); // 确保在controller改变时刷新UI
  //     }
  //   }
  // }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    widget.controller.removeListener(_onControllerUpdated);
    // _chewieController?.dispose(); // 如果使用Chewie
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final deviceWidth = MediaQuery.of(context).size.width;
    // 宽高比，默认为16:9，如果视频已初始化，则使用视频的宽高比
    final aspectRatio =
        controller.value.isInitialized ? controller.value.aspectRatio : 16 / 9;

    // 手动构建播放器UI
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.black,
        width:
            widget.isfullScreen ? deviceWidth : double.infinity, // 全屏时宽度为设备宽度
        height: widget.isfullScreen
            ? MediaQuery.of(context).size.height
            : (widget.isfullScreen
                ? null
                : deviceWidth / aspectRatio), // 非全屏时根据宽高比计算高度
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 视频播放器
            if (controller.value.isInitialized)
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              )
            else if (controller.value.hasError)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '视频加载失败',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              )
            else if (widget.pic.isNotEmpty)
              CachedNetworkImage(
               imageUrl:  widget.pic,
                fit: BoxFit.contain, // 使用 contain 避免图片裁剪
                width: double.infinity,
                height: double.infinity,
              )
            else
              const Center(
                  child: CircularProgressIndicator(color: Colors.white)),

            // 控制界面
            if (_showControls &&
                controller.value.isInitialized &&
                !controller.value.hasError) ...[
              // 播放/暂停按钮 (居中)
              Center(
                child: IconButton(
                  icon: Icon(
                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                  onPressed: () {
                    setState(() {
                      controller.value.isPlaying
                          ? controller.pause()
                          : controller.play();
                    });
                  },
                ),
              ),

              // 顶部控制栏
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.black45,
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
                  color: Colors.black45,
                  height: 40,
                  child: Row(
                    children: [
                      Text(
                        _formatDuration(controller.value.position),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2.0,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6.0),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12.0),
                          ),
                          child: Slider(
                            value: controller.value.position.inMilliseconds >
                                    controller.value.duration.inMilliseconds
                                ? controller.value.duration.inMilliseconds
                                    .toDouble()
                                : controller.value.position.inMilliseconds
                                    .toDouble(),
                            min: 0.0,
                            max: controller.value.duration.inMilliseconds
                                .toDouble(),
                            onChanged: (value) {
                              controller.seekTo(
                                  Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(controller.value.duration),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
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
            ],
          ],
        ),
      ),
    );
  }
}

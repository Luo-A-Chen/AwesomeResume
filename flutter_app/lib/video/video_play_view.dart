import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/api/nav_extension.dart';
import 'package:video_player/video_player.dart';

import 'video_player_cntlr.dart';
import 'video_urls.dart';

class VidioPlayView extends StatefulWidget {
  final int avid; // 视频的avid
  final int cid; // 视频的cid
  final bool isfullScreen; // 是否全屏
  final String? title; // 用于非全屏时顶部返回条的标题

  const VidioPlayView({
    super.key,
    required this.avid,
    required this.cid,
    required this.isfullScreen,
    this.title,
  });

  @override
  State<VidioPlayView> createState() => _VidioPlayViewState();
}

class _VidioPlayViewState extends State<VidioPlayView> {
  bool _showControls = false;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _loadVedio();
  }

  Future<void> _loadVedio() async {
    final data = await VideoUrls.getVideoStreamUrl(
      avid: widget.avid,
      cid: widget.cid,
      fnval: 1,
    );
    final urlMap = VideoUrls.parseVideoUrl(data);
    if (urlMap == null || urlMap['videoUrl'] == null) {
      return;
    }
    final videoUrl = urlMap['videoUrl']!;
    print('获取到视频URL: $videoUrl');
    videoPlayerCntlr = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      httpHeaders: {
        'Referer': 'https://www.bilibili.com',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      },
    );
    await videoPlayerCntlr.initialize();
    await videoPlayerCntlr.play();
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
    if (videoPlayerCntlr.value.aspectRatio > 1) {
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
            cid: widget.cid,
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

  @override
  void dispose() {
    _controlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    // 宽高比，默认为16:9，如果视频已初始化，则使用视频的宽高比
    final aspectRatio = videoPlayerCntlr.value.isInitialized
        ? videoPlayerCntlr.value.aspectRatio
        : 16 / 9;

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
            if (videoPlayerCntlr.value.hasError)
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

            // 视频播放器
            else
              AspectRatio(
                aspectRatio: videoPlayerCntlr.value.aspectRatio,
                child: VideoPlayer(videoPlayerCntlr),
              ),
            // 控制界面
            if (_showControls &&
                videoPlayerCntlr.value.isInitialized &&
                !videoPlayerCntlr.value.hasError) ...[
              // 播放/暂停按钮 (居中)
              Center(
                child: IconButton(
                  icon: Icon(
                    videoPlayerCntlr.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                  onPressed: () {
                    setState(() {
                      videoPlayerCntlr.value.isPlaying
                          ? videoPlayerCntlr.pause()
                          : videoPlayerCntlr.play();
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
                        _formatDuration(videoPlayerCntlr.value.position),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Expanded(
                        child: VideoProgressIndicator(
                          videoPlayerCntlr,
                          allowScrubbing: true,
                        ),
                      ),
                      Text(
                        _formatDuration(videoPlayerCntlr.value.duration),
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

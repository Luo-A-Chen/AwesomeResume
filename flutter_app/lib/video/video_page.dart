import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/nav_extension.dart';
import 'package:video_player/video_player.dart';
import '../reply/reply_view.dart';
import 'blbl_player.dart';
import 'info_view.dart';
import 'video_urls.dart';

class VideoPage extends StatefulWidget {
  /// 稿件id，用于获取视频url
  final int cid;

  /// 视频avid，用于获取推荐视频和视频流
  final int avid;

  /// 视频标题
  final String title;

  /// 视频封面地址
  final String imgUrl;

  const VideoPage(
      {super.key,
      required this.cid,
      required this.avid,
      required this.title,
      required this.imgUrl});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller = VideoPlayerController.network('');
  bool _isVideoLoading = true;
  String? _errorMessage;
  late double _deviceWidth;
  final ScrollController _scrollController = ScrollController();

  double _hWRatio = 9 / 16; // 默认宽高比

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    setState(() {
      _isVideoLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await VideoUrls.getVideoStreamUrl(
        avid: widget.avid,
        cid: widget.cid,
        fnval: 1,
      );
      final urlMap = VideoUrls.parseVideoUrl(data);
      if (urlMap == null || urlMap['videoUrl'] == null) {
        setState(() {
          _isVideoLoading = false;
          _errorMessage = '无法获取视频流，请稍后再试';
        });
        return;
      }
      final videoUrl = urlMap['videoUrl']!;
      print('获取到视频URL: $videoUrl');

      // 释放旧的控制器（如果存在且已初始化）
      if (_controller.value.isInitialized) {
        await _controller.dispose();
      }

      _controller = VideoPlayerController.network(
        videoUrl,
        httpHeaders: {
          'Referer': 'https://www.bilibili.com',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );
      await _controller.initialize();
      await _controller.play();
      _controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
      if (mounted) {
        setState(() {
          final videoSize = _controller.value.size;
          if (videoSize.width > 0 && videoSize.height > 0) {
            if (videoSize.width > videoSize.height) {
              _hWRatio = videoSize.height / videoSize.width;
              if (_hWRatio < (9 / 16 - 0.1) || _hWRatio > (9 / 16 + 0.1)) {
                _hWRatio = 9 / 16;
              }
            } else {
              _hWRatio = 1.0;
            }
          } else {
            _hWRatio = 9 / 16; // Fallback if size is invalid
          }
          _isVideoLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _errorMessage = '视频加载失败: $e';
        });
      }
      print('视频加载失败: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.black),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              // 视频播放器
              ListenableBuilder(
                listenable: _controller,
                child: _buildVedioPlayer(),
                builder: (context, vedioPlayer) {
                  final height = _deviceWidth * _hWRatio;
                  return SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverPersistentHeaderDelegate(
                      minHeight: _controller.value.isPlaying ? height : 50,
                      maxHeight: height,
                      child: ListenableBuilder(
                        listenable: _scrollController,
                        builder: (context, child) {
                          double opacity =
                              (_scrollController.offset - 100) / 100;
                          switch (opacity) {
                            case < 0:
                              opacity = 0;
                            case > 1:
                              opacity = 1;
                          }
                          return Stack(children: [
                            vedioPlayer!,
                            if (!_controller.value.isPlaying &&
                                _scrollController.offset > 50)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _controller.play();
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                },
                                child: Container(
                                  height: height,
                                  alignment: Alignment.topCenter,
                                  color: Color.fromRGBO(243, 143, 165, opacity),
                                  child: Row(children: [
                                    const BackButton(color: Colors.white),
                                    IconButton(
                                      onPressed: context.popUntil,
                                      icon: const Icon(Icons.home,
                                          color: Colors.white),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    const Icon(Icons.play_arrow,
                                        color: Colors.white, size: 32),
                                    const Text(
                                      '继续播放',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    IconButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          builder: _modalBottomSheetBuilder,
                                        );
                                      },
                                      icon: const Icon(Icons.more_vert,
                                          color: Colors.white),
                                      color: Colors.white,
                                    ),
                                  ]),
                                ),
                              ),
                          ]);
                        },
                      ),
                    ),
                  );
                },
              ),
              // 标签栏
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverPersistentHeaderDelegate(
                  minHeight: 50,
                  maxHeight: 50,
                  child: Container(
                    color: Colors.white,
                    child: const TabBar(
                      tabs: [Tab(text: '简介'), Tab(text: '评论')],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              // 简介页面
              InfoView(
                avid: widget.avid,
                controller: _controller,
                title: widget.title,
              ),
              // 评论页面
              ReplyView(oid: widget.avid),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalBottomSheetBuilder(context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // 70高度
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
              child: ListView(
            padding: const EdgeInsets.all(12),
            children: List.generate(
              30,
              (index) => ListTile(
                leading: const Icon(Icons.abc),
                title: const Text('设置项待开发'),
                onTap: () {},
                trailing: const Icon(Icons.settings),
              ),
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildVedioPlayer() {
    if (_isVideoLoading) {
      return Container(
        color: Colors.black,
        width: _deviceWidth,
        height: _deviceWidth * (9 / 16), // 保持加载时的默认高度
        child:
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_errorMessage != null) {
      return Container(
        color: Colors.black,
        width: _deviceWidth,
        height: _deviceWidth * (9 / 16), // 保持错误时的默认高度
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }
    // 确保 _controller 已经初始化并且有有效的宽高比
    // BlblPlayer 内部会处理 controller 未初始化的情况，但这里可以提前返回占位图
    if (!_controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        width: _deviceWidth,
        height: _deviceWidth * _hWRatio,
        child: widget.imgUrl.isNotEmpty
            ? CachedNetworkImage(imageUrl: widget.imgUrl, fit: BoxFit.cover)
            : const Center(
                child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return BlblPlayer(
      controller: _controller,
      pic: widget.imgUrl,
      isfullScreen: false, // 在主页面，不是全屏
    );
  }
}

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverPersistentHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

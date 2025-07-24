import 'package:flutter/material.dart';
import '../api/nav_extension.dart';
import 'package:video_player/video_player.dart';
import '../comment/comment_view.dart';
import 'video_play_view.dart';
import 'info_view.dart';
import 'video_response.dart';
import 'video_urls.dart';

class VideoPage extends StatefulWidget {
  /// 稿件id，用于获取视频url
  final int cid;

  /// 视频avid，用于获取推荐视频和视频流
  final int avid;

  /// 视频标题
  final String title;

  const VideoPage({
    super.key,
    required this.cid,
    required this.avid,
    required this.title,
  });

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _playerCntlr;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initPlayerCntlr();
  }

  @override
  void dispose() {
    super.dispose();
    _playerCntlr.dispose(); // 释放视频播放器资源
  }

  Future<void> _initPlayerCntlr() async {
    final data = await VideoUrls.getVideoStreamUrl(
      avid: widget.avid,
      cid: widget.cid,
      fnval: 1,
    );
    final urlMap = VideoUrls.parseVideoUrl(data);
    if (urlMap == null || urlMap['videoUrl'] == null) {
      return;
    }
    setState(() {
      _playerCntlr = VideoPlayerController.networkUrl(
        Uri.parse(urlMap['videoUrl']!),
        httpHeaders: {
          'Referer': 'https://www.bilibili.com',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );
      _loading = false;
    });
  }

  Future<void> _pushNewVideoPage(Video video) async {
    var wasPlaying = _playerCntlr.value.isPlaying; // 保存当前视频的播放状态
    // 暂停当前视频
    _playerCntlr.pause();
    await context.push(
      VideoPage(avid: video.avid, cid: video.cid, title: video.title),
    );
    if (wasPlaying) {
      _playerCntlr.play(); // 恢复播放状态
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.black),
      body: DefaultTabController(
        length: 2,
        child: Column(children: [
          Container(
            color: Colors.black,
            height: 9 / 16 * MediaQuery.of(context).size.width,
            child: _loading
                ? null
                : VidioPlayView(
                    avid: widget.avid,
                    cid: widget.cid,
                    isfullScreen: false,
                    playerCntlr: _playerCntlr,
                  ),
          ),
          // 标签栏
          const TabBar(tabs: [Tab(text: '简介'), Tab(text: '评论')]),
          Expanded(
            child: TabBarView(
              children: [
                // 简介页面
                InfoView(
                  avid: widget.avid,
                  title: widget.title,
                  onTapVideo: (video) => _pushNewVideoPage(video),
                ),
                // 评论页面
                ReplyView(oid: widget.avid),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

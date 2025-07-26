import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../api/nav_extension.dart';
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
  late final VideoPlayerController _videoCntlr;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void dispose() {
    super.dispose();
    _videoCntlr.dispose();
  }

  Future<void> _loadVideo() async {
    try {
      final data = await VideoUrls.getVideoStreamUrl(
        avid: widget.avid,
        cid: widget.cid,
        fnval: 1,
      );
      final urlMap = VideoUrls.parseVideoUrl(data);
      if (urlMap == null || urlMap['videoUrl'] == null) {
        return;
      }
      _videoCntlr = VideoPlayerController.networkUrl(
        Uri.parse(urlMap['videoUrl']!),
        httpHeaders: {
          'Referer': 'https://www.bilibili.com',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );
      setState(() {
        _loading = false;
      });
      await _videoCntlr.initialize();
      _videoCntlr.play();
    } catch (e) {
      print('视频加载失败：$e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pushNewVideoPage(Video video) async {
    var wasPlaying = _videoCntlr.value.isPlaying; // 保存当前视频的播放状态
    _videoCntlr.pause(); // 暂停当前视频
    await context.push(
      VideoPage(avid: video.avid, cid: video.cid, title: video.title),
    );
    if (wasPlaying) _videoCntlr.play();
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
                    cntlr: _videoCntlr,
                    isfullScreen: false,
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

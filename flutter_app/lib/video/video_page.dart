import 'package:flutter/material.dart';
import '../comment/comment_view.dart';
import 'video_play_view.dart';
import 'info_view.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.black),
      body: DefaultTabController(
        length: 2,
        child: Column(children: [
          VidioPlayView(
            avid: widget.avid,
            cid: widget.cid,
            isfullScreen: false, // 在主页面，不是全屏
          ),
          // 标签栏
          const TabBar(tabs: [Tab(text: '简介'), Tab(text: '评论')]),
          Expanded(
            child: TabBarView(
              children: [
                // 简介页面
                InfoView(avid: widget.avid, title: widget.title),
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

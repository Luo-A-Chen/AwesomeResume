import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/nav_extension.dart';
import 'package:video_player/video_player.dart';

import '../api/http.dart';
import 'video_page.dart';
import 'video_response.dart';

class InfoView extends StatefulWidget {
  const InfoView({
    super.key,
    required this.avid,
    required this.controller,
    required this.title,
  });

  final int avid;
  final VideoPlayerController controller;
  final String title;

  @override
  State<InfoView> createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  List<Video> _videos = [];

  @override
  void initState() {
    _getVideos();
    super.initState();
  }

  void _getVideos() async {
    final res = await Http.get(
        '/web-interface/archive/related?aid=${widget.avid}');
    setState(() {
      _videos = RelatedVideoRes.fromJson(res.data).data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 视频简介信息
        SliverToBoxAdapter(child: _videoInfo()),
        // 分隔线
        const SliverToBoxAdapter(
          child: Divider(height: 1, color: Colors.black12),
        ),
        // 推荐视频标题
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              '相关推荐',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // 推荐视频列表
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildRecommendItem(_videos[index]),
            childCount: _videos.length,
          ),
        ),
      ],
    );
  }

  Widget _videoInfo() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: 展开显示简介；播放量、弹幕数、发布时间 实时观众数
          Text(
            widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // 互动按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // TODO: 实现点赞、投币、收藏、分享功能
              _buildActionButton(Icons.thumb_up_outlined, '点赞'),
              _buildActionButton(Icons.thumb_down_outlined, '不喜欢'),
              _buildActionButton(Icons.monetization_on_outlined, '投币'),
              _buildActionButton(Icons.star_outline, '收藏'),
              _buildActionButton(Icons.share_outlined, '分享'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // 添加 _formatDuration 方法，供推荐列表使用
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildRecommendItem(Video video) {
    return InkWell(
      onTap: () {
        widget.controller.pause(); // TODO: 控制器有可能没有初始化
        context
            .push(VideoPage(
          avid: video.avid,
          title: video.title,
          imgUrl: video.pic,
          cid: video.cid,
        ))
            .then((value) {
          if (mounted) {
            widget.controller.play();
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频封面
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                   imageUrl:  video.pic,
                    width: 160,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 5,
                  bottom: 5,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(video.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${video.owner.name} · ${_formatDuration(video.duration)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

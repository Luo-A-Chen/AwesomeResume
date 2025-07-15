import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/nav_extension.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../video/video_page.dart';
import '../video/video_response.dart';
import 'video_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _videoRepository = VideoRepository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: SelectableText('首页'), centerTitle: true),
      body: LoadingMoreCustomScrollView(slivers: [
        LoadingMoreSliverList(SliverListConfig(
          itemBuilder: (context, video, index) {
            return _buildVideoCard(video);
          },
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            maxCrossAxisExtent: 300,
            childAspectRatio: 0.8,
          ),
          sourceList: _videoRepository,
        )),
      ]),
    );
  }

  Widget _buildVideoCard(Video video) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => context.push(
          VideoPage(
              cid: video.cid,
              avid: video.avid,
              title: video.title,
              imgUrl: video.pic),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频封面
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.4,
                  child: CachedNetworkImage(
                    imageUrl:  video.pic,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.error)),
                      );
                    },
                  ),
                ),
                // 视频数据
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 14, 6, 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4)
                        ],
                      ),
                    ),
                    child: Row(children: [
                      // 播放量
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        _formatCount(video.stat.view),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      // 弹幕量
                      const Icon(Icons.comment_outlined,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        _formatCount(video.stat.danmaku),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          _formatDuration(video.duration),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      )
                    ]),
                  ),
                ),
              ],
            ),
            // 视频标题
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            // 视频作者
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  // TODO 如果视频是竖屏，显示竖屏标签
                  Expanded(
                    child: Text(
                      video.owner.name,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      // TODO 视频卡片显示更多选项
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }
}

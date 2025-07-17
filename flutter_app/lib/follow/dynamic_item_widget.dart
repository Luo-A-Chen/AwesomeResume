import 'package:flutter/material.dart';
import 'package:flutter_app/api/nav_extension.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../video/video_page.dart';
import '../video/video_urls.dart';
import 'dynamic.dart';

class DynamicItemWidget extends StatelessWidget {
  final Dynamic dynamicItem;

  const DynamicItemWidget({super.key, required this.dynamicItem});

  @override
  Widget build(BuildContext context) {
    // 根据动态类型构建不同的UI
    Widget contentWidget;
    switch (dynamicItem.type) {
      case DynamicType.video:
        contentWidget = _buildVideoDynamic(
            dynamicItem.modules.moduleDynamic?.major?.archive);
        break;
      case DynamicType.draw:
        contentWidget = _buildDrawDynamic(dynamicItem.modules.moduleDesc,
            dynamicItem.modules.moduleDynamic?.major?.draw);
        break;
      case DynamicType.word:
        contentWidget = _buildWordDynamic(dynamicItem.modules.moduleDesc);
        break;
      case DynamicType.forward:
        // 对于转发动态，需要同时显示转发内容和原始内容
        contentWidget = _buildForwardDynamic(
          dynamicItem.modules.moduleDesc, // 转发时的文字描述
          dynamicItem.orig, // 原始动态内容
        );
        break;
      case DynamicType.live:
        // TODO: 实现直播动态UI
        contentWidget =
            _buildLiveDynamic(dynamicItem.modules.moduleDynamic?.major?.live);
        break;
      case DynamicType.article:
        // TODO: 实现专栏动态UI
        contentWidget = _buildArticleDynamic(
            dynamicItem.modules.moduleDynamic?.major?.article);
        break;
      case DynamicType.unknown:
      default:
        contentWidget = const Text('未知动态类型');
        break;
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        splashColor: Colors.transparent, // 禁用涟漪
        onTap: () async {
          // TODO 打开更多类型的动态
          if (dynamicItem.type == DynamicType.video) {
            final archive = dynamicItem.modules.moduleDynamic?.major?.archive;
            if (archive == null) return;
            final videoInfo = await VideoUrls.getVideoInfo(archive.bvid);
            if (videoInfo['cid'] is! int) return;
            context.push(VideoPage(
              cid: videoInfo['cid'],
              avid: int.parse(archive.aid),
              title: archive.title,
              imgUrl: archive.cover,
            ));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 作者信息
              _buildAuthorInfo(dynamicItem.modules.moduleAuthor,
                  dynamicItem.basic.timestamp),
              const SizedBox(height: 8.0),
              // 动态内容
              contentWidget,
              const SizedBox(height: 8.0),
              // 统计信息 (点赞、评论、转发)
              _buildStatInfo(dynamicItem.modules.moduleStat),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(ModuleAuthor author, int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final timeAgoString = timeago.format(dateTime, locale: 'zh_CN');

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(author.face),
        ),
        const SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(author.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(timeAgoString, // TODO timeAgo时间显示错误
                style: const TextStyle(color: Colors.grey, fontSize: 12.0)),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoDynamic(DynamicArchive? archive) {
    if (archive == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(archive.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4.0),
        Text(archive.desc),
        const SizedBox(height: 8.0),
        Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              archive.cover,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
            const Icon(Icons.play_circle_fill,
                size: 50, color: Colors.white70), // Play button overlay
          ],
        ),
      ],
    );
  }

  Widget _buildDrawDynamic(ModuleDesc? desc, DynamicDraw? draw) {
    if (draw == null || draw.items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (desc != null) Text(desc.text), // 文字描述
        if (desc != null) const SizedBox(height: 8.0),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 每行显示3张图片
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            childAspectRatio: 1.0, // 图片宽高比
          ),
          itemCount: draw.items.length,
          itemBuilder: (context, index) {
            final item = draw.items[index];
            return Image.network(
              item.src,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWordDynamic(ModuleDesc? desc) {
    if (desc == null) return const SizedBox.shrink();
    return Text(desc.text);
  }

  Widget _buildForwardDynamic(ModuleDesc? desc, DynamicOriginal? original) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (desc != null) Text(desc.text), // 转发时的文字描述
        if (desc != null) const SizedBox(height: 8.0),
        if (original != null)
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 原始动态的作者信息
                _buildAuthorInfo(
                    original.modules.moduleAuthor,
                    original
                        .basic.timestamp), // Pass timestamp for original post
                const SizedBox(height: 8.0),
                // 原始动态的内容
                _buildOriginalContent(original.modules),
                const SizedBox(height: 8.0),
                // 原始动态的统计信息
                _buildStatInfo(original.modules.moduleStat),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOriginalContent(DynamicModules modules) {
    // 根据原始动态的类型构建内容UI
    // Need to check the major type within moduleDynamic
    if (modules.moduleDynamic?.major?.archive != null) {
      return _buildVideoDynamic(modules.moduleDynamic?.major?.archive);
    } else if (modules.moduleDynamic?.major?.draw != null) {
      return _buildDrawDynamic(
          modules.moduleDesc, modules.moduleDynamic?.major?.draw);
    } else if (modules.moduleDesc != null) {
      return _buildWordDynamic(modules.moduleDesc);
    } else if (modules.moduleDynamic?.major?.live != null) {
      // Add live type check
      return _buildLiveDynamic(modules.moduleDynamic?.major?.live);
    } else if (modules.moduleDynamic?.major?.article != null) {
      // Add article type check
      return _buildArticleDynamic(modules.moduleDynamic?.major?.article);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildStatInfo(ModuleStat stat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            const Icon(Icons.share), // 转发图标
            const SizedBox(width: 4.0),
            Text(stat.share.count.toString()),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.comment), // 评论图标
            const SizedBox(width: 4.0),
            Text(stat.comment.count.toString()),
          ],
        ),
        Row(
          children: [
            Icon(stat.like.status
                ? Icons.thumb_up
                : Icons.thumb_up_outlined), // 点赞图标
            const SizedBox(width: 4.0),
            Text(stat.like.count.toString()),
          ],
        ),
      ],
    );
  }

  // 新增：构建直播动态UI
  Widget _buildLiveDynamic(DynamicLive? live) {
    if (live == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('直播标题: ${live.title}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4.0),
        Text('UP主: ${live.author.name}'),
        const SizedBox(height: 8.0),
        // 显示直播封面和状态
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.network(
              live.cover,
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 150,
                  color: Colors.red[100],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.red[100],
                child: const Icon(Icons.error),
              ),
            ),
            if (live.liveState == 1) // Assuming 1 means live streaming
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.red, // Live indicator color
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  '直播中',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // 新增：构建专栏动态UI
  Widget _buildArticleDynamic(DynamicArticle? article) {
    if (article == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('专栏标题: ${article.title}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4.0),
        Text(article.desc),
        const SizedBox(height: 8.0),
        // 显示专栏封面
        if (article.covers.isNotEmpty)
          Image.network(
            article.covers.first,
            fit: BoxFit.cover,
            height: 150,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 150,
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: 150,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
      ],
    );
  }
}

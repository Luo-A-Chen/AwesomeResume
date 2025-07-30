import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:awesome_flutter/api/nav_extension.dart';

import '../../api/toast.dart';
import '../video/video_page.dart';
import '../video/video_urls.dart';
import 'dynamic.dart';

class DynamicCart extends StatelessWidget {
  final Dynamic dynamicItem;

  const DynamicCart({super.key, required this.dynamicItem});

  @override
  Widget build(BuildContext context) {
    // 根据动态类型构建不同的UI
    Widget contentWidget;
    switch (dynamicItem.type) {
      case DynamicType.video:
        contentWidget = _buildVideoDynamic(
          context,
          dynamicItem.modules.moduleDynamic?.major?.archive,
        );
        break;
      case DynamicType.draw:
        contentWidget = _buildDrawDynamic(
            dynamicItem.modules.moduleDynamic?.desc,
            dynamicItem.modules.moduleDynamic?.major?.draw);
        break;
      case DynamicType.word:
        contentWidget =
            _buildWordDynamic(dynamicItem.modules.moduleDynamic?.desc);
        break;
      case DynamicType.forward:
        // 对于转发动态，需要同时显示转发内容和原始内容
        contentWidget = _buildForwardDynamic(
          context,
          dynamicItem.modules.moduleDynamic?.desc, // 转发时的文字描述
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
          // TODO 动态卡片点击
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 作者信息
              _buildAuthorInfo(dynamicItem.modules.moduleAuthor),
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

  Widget _buildAuthorInfo(ModuleAuthor author) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(author.face),
        ),
        const SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(author.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              author.pubTime,
              style: const TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoDynamic(BuildContext context, DynamicArchive? archive) {
    if (archive == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () async {
        final videoInfo = await VideoUrls.getVideoInfo(archive.bvid);
        if (videoInfo['cid'] is! int || !context.mounted) return;
        context.push(VideoPage(
          cid: videoInfo['cid'],
          avid: int.parse(archive.aid),
          title: archive.title,
        ));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(archive.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4.0),
          Text(archive.desc),
          const SizedBox(height: 8.0),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CachedNetworkImage(
                imageUrl: archive.cover,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
              const Icon(
                Icons.play_circle_fill,
                size: 50,
                color: Colors.white,
              ), // Play button overlay
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawDynamic(DynamicDesc? desc, DynamicDraw? draw) {
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
            return CachedNetworkImage(
              imageUrl: item.src,
              fit: BoxFit.cover,
              // loadingBuilder: (context, child, loadingProgress) {
              //   if (loadingProgress == null) return child;
              //   return Center(
              //     child: CircularProgressIndicator(
              //       value: loadingProgress.expectedTotalBytes != null
              //           ? loadingProgress.cumulativeBytesLoaded /
              //               loadingProgress.expectedTotalBytes!
              //           : null,
              //     ),
              //   );
              // },
              errorWidget: (context, error, stackTrace) =>
                  const Icon(Icons.error),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWordDynamic(DynamicDesc? desc) {
    if (desc == null) return const SizedBox.shrink();
    return Text(desc.text);
  }

  Widget _buildForwardDynamic(
    BuildContext context,
    DynamicDesc? desc,
    DynamicOriginal? original,
  ) {
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
                _buildAuthorInfo(original
                    .modules.moduleAuthor), // Pass timestamp for original post
                const SizedBox(height: 8.0),
                // 原始动态的内容
                _buildOriginalContent(context, original.modules),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOriginalContent(BuildContext context, DynamicModules modules) {
    // 根据原始动态的类型构建内容UI
    // Need to check the major type within moduleDynamic
    if (modules.moduleDynamic?.major?.archive != null) {
      return _buildVideoDynamic(context, modules.moduleDynamic?.major?.archive);
    } else if (modules.moduleDynamic?.major?.draw != null) {
      return _buildDrawDynamic(
          modules.moduleDynamic?.desc, modules.moduleDynamic?.major?.draw);
    } else if (modules.moduleDynamic != null) {
      return _buildWordDynamic(modules.moduleDynamic?.desc);
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
      children: [
        Expanded(
          child: GestureDetector(
            onTap: Toast.unimplemented,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share),
                const SizedBox(width: 4.0),
                // TODO 转发数量不正确
                Text(stat.share.count > 0 ? stat.share.count.toString() : '转发'),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: Toast.unimplemented,
            child: Row(
              children: [
                const Icon(Icons.comment), // 评论图标
                const SizedBox(width: 4.0),
                Text(stat.comment.count > 0
                    ? stat.comment.count.toString()
                    : '评论'),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: Toast.unimplemented,
            child: Row(
              children: [
                Icon(stat.like.status
                    ? Icons.thumb_up
                    : Icons.thumb_up_outlined), // 点赞图标
                const SizedBox(width: 4.0),
                Text(stat.like.count > 0 ? stat.like.count.toString() : '点赞'),
              ],
            ),
          ),
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
            CachedNetworkImage(
              imageUrl: live.cover,
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
              errorWidget: (context, error, stackTrace) => Container(
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
          CachedNetworkImage(
            imageUrl: article.covers.first,
            fit: BoxFit.cover,
            height: 150,
            width: double.infinity,
            // loadingBuilder: (context, child, loadingProgress) {
            //   if (loadingProgress == null) return child;
            //   return Container(
            //     height: 150,
            //     color: Colors.grey[300],
            //     child: Center(
            //       child: CircularProgressIndicator(
            //         value: loadingProgress.expectedTotalBytes != null
            //             ? loadingProgress.cumulativeBytesLoaded /
            //                 loadingProgress.expectedTotalBytes!
            //             : null,
            //       ),
            //     ),
            //   );
            // },
            errorWidget: (context, error, stackTrace) => Container(
              height: 150,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
      ],
    );
  }
}

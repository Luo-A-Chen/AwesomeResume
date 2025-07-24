import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import 'comment.dart';
import 'comment_repository.dart';

class ReplyView extends StatefulWidget {
  const ReplyView({super.key, required this.oid});

  /// 目标评论区id，视频评论区为视频avid
  final num oid;

  @override
  State<ReplyView> createState() => _ReplyViewState();
}

class _ReplyViewState extends State<ReplyView>
    with AutomaticKeepAliveClientMixin {
  String? _errorMessage;

  late final _commentRepository = CommmentRepository(oid: widget.oid);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_errorMessage != null) {
      return RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: Center(child: Text('错误：$_errorMessage')),
      );
    }
    List<Widget> slivers = [];
    slivers.add(const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text('热门评论',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ));
    // TODO 热门评论
    // slivers.add(SliverList(
    //   delegate: SliverChildBuilderDelegate(
    //     (context, index) => _buildCommentItem(_hotComments[index]),
    //     childCount: _hotComments.length,
    //   ),
    // ));
    slivers.add(const SliverToBoxAdapter(
        child: Divider(height: 20, thickness: 8, color: Color(0xFFF0F0F0))));

    // 全部评论标题
    slivers.add(SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text('全部评论',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ));

    // 评论列表

    slivers.add(LoadingMoreSliverList(
      SliverListConfig(
        sourceList: _commentRepository,
        itemBuilder: (context, reply, index) {
          return _buildCommentItem(reply);
        },
      ),
    ));
    return RefreshIndicator(
      onRefresh: _commentRepository.refresh,
      child: LoadingMoreCustomScrollView(
        slivers: slivers,
      ),
    );
  }

  Widget _buildCommentItem(Reply comment) {
    final commentTime =
        DateTime.fromMillisecondsSinceEpoch(comment.ctime * 1000);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              comment.member.avatar,
            ),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.member.uname,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.pinkAccent),
                    ),
                    // 可以根据需要添加等级、勋章等
                    if (comment.member.vip.vipStatus == 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          comment.member.vip.label.text,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.pink,
                              backgroundColor: Colors.pink.withOpacity(0.1)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content.message,
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      commentTime.toString(),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.thumb_up_alt_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(comment.like > 0 ? comment.like.toString() : '点赞',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(width: 16),
                    Icon(Icons.comment_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(comment.count > 0 ? comment.count.toString() : '回复',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                if (comment.replies != null && comment.replies!.isNotEmpty)
                  _buildReplies(comment.replies!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplies(List<Reply> replies) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: replies.take(2).map((reply) {
          // 最多显示2条子评论，可加展开按钮
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reply.member.uname}: ',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black54),
                ),
                Expanded(
                    child: Text(reply.content.message,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

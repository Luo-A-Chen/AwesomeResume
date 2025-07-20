import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api/http.dart';
import 'reply.dart';

class ReplyView extends StatefulWidget {
  const ReplyView({super.key, required this.oid});

  /// 目标评论区id，视频评论区为视频avid
  final int oid;

  @override
  State<ReplyView> createState() => _ReplyViewState();
}

class _ReplyViewState extends State<ReplyView>
    with AutomaticKeepAliveClientMixin {
  List<Reply> _comments = [];
  List<Reply> _hotComments = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _pn = 1; // 当前页码
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _hasMore &&
          !_isLoading) {
        _fetchComments(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _pn = 1;
        _comments = [];
        _hotComments = [];
        _hasMore = true;
      });
    } else {
      setState(() {
        _isLoading = true; // 加载更多时也显示加载指示
      });
    }

    // 根据B站API文档，type=1 表示视频稿件评论，oid为avid
    // sort=0 按时间排序，sort=1 按点赞数，sort=2 按回复数
    // 首次加载获取热评 (nohot=0)，后续加载不再获取热评 (nohot=1)
    final nohot = _pn == 1 ? 0 : 1;

    // 注意：B站API可能需要登录凭证(Cookie SESSDATA)才能获取完整数据或避免风控
    // 此处为简化，使用未登录的请求，实际项目中可能需要处理登录和Cookie
    final res = await Http.dio.get(
        'https://api.bilibili.com/x/v2/reply/main?type=1&oid=${widget.oid}&sort=0&pn=$_pn&nohot=$nohot',
        options: null);
    print('评论请求头：\n${Http.dio.options.headers}');
    print('评论请求结果：\n${res.data}');
    final commentResponse = ReplyResponse.fromJson(res.data);
    if (commentResponse.code == 0) {
      setState(() {
        if (_pn == 1) {
          _hotComments = commentResponse.data.topReplies;
        }
        _comments = commentResponse.data.replies;
        _pn++;
        _hasMore = commentResponse.data.replies.length == 20; // 假设每页20条
      });
    } else {
      _errorMessage = commentResponse.message;
      _hasMore = false;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: Center(child: Text('错误：$_errorMessage')),
      );
    }
    List<Widget> slivers = [];
    // 热门评论
    if (_hotComments.isNotEmpty) {
      slivers.add(const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text('热门评论',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ));
      slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildCommentItem(_hotComments[index]),
          childCount: _hotComments.length,
        ),
      ));
      slivers.add(const SliverToBoxAdapter(
          child: Divider(height: 20, thickness: 8, color: Color(0xFFF0F0F0))));
    }

    // 全部评论标题
    slivers.add(SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text('全部评论 (${_comments.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ));

    // 评论列表
    if (_comments.isEmpty && !_isLoading) {
      slivers.add(const SliverFillRemaining(
        child: Center(child: Text('暂无评论')),
      ));
    } else {
      slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < _comments.length) {
              return _buildCommentItem(_comments[index]);
            }
            // 加载更多指示器
            if (_hasMore) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return null; // 没有更多了
          },
          childCount: _comments.length + (_hasMore ? 1 : 0),
        ),
      ));
    }
    return RefreshIndicator(
      onRefresh: () => _fetchComments(),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        controller: _scrollController,
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
              comment.member!.avatar!,
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
                          comment.member.vip!.label.text,
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

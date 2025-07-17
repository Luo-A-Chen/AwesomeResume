import 'package:flutter/material.dart';
import 'package:flutter_app/api/nav_extension.dart';

import '../../api/app_toast.dart';
import '../../requester/requester.dart';
import '../settings/settings.dart';
import '../video/video_page.dart';
import 'search_model.dart';

class SearchPage extends StatefulWidget {
  final String initialKeyword;

  const SearchPage({super.key, this.initialKeyword = ''});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  String _currentKeyword = '';
  late TabController _tabController;
  final _settings = Settings.instance;

// TODO 实现综合搜索
  final List<String> _tabs = ['视频', '番剧', '直播', '用户', '影视', '图文'];
  final Map<String, String?> _tabSearchType = {
    '视频': 'video',
    '番剧': 'media_bangumi',
    '直播': 'live',
    '用户': 'user',
    '影视': 'media_ft',
    '图文': 'article',
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialKeyword);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    final index = _tabController.index;
    _performSearch(_currentKeyword, _tabSearchType[_tabs[index]]);
  }

  Future<void> _performSearch(String keyword, String? searchType) async {
    setState(() {
      _isLoading = true;
      _currentKeyword = keyword;
    });
    final requester = _settings.requester!.searchRequester;
    final results = await (searchType == null
        ? requester.getAllSearchResults()
        : requester.getTypeSearchResults(keyword, searchType: searchType));
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(titleSpacing: 0, title: _buildSearchBar(context)),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              // TODO 根据搜索类别显示不同搜索结果页
              children: _tabs.map((tabName) {
                return _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty && _currentKeyword.isNotEmpty
                        ? const Center(child: Text('暂无搜索结果，换个词试试吧'))
                        : _buildSearchResults();
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 36,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '搜索', // 占位符
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (query) {
                _performSearch(
                    query, _tabSearchType[_tabs[_tabController.index]]);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
            },
          ),
          TextButton(
            onPressed: () {
              _performSearch(_searchController.text,
                  _tabSearchType[_tabs[_tabController.index]]);
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.pink,
      unselectedLabelColor: Colors.black,
      indicatorColor: Colors.pink,
      tabs: _tabs.map((name) => Tab(text: name)).toList(),
    );
  }

  Widget _buildSearchResults() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return GestureDetector(
          onTap: () => _jump(item, context),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    item.pic.startsWith('//') ? 'https:${item.pic}' : item.pic,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.broken_image));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.replaceAll(RegExp(r'<em[^>]*>|</em>'), ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.author,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '播放: ${item.play}  弹幕: ${item.videoReview}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _jump(SearchResult item, BuildContext context) {
    // TODO 其它类型的搜索结果跳转
    final videoRequester = _settings.requester!.videoRequester;
    if (item.type == 'video' && videoRequester is BlblVideoRequester) {
      videoRequester.getVideoInfo(item.bvid).then((videoInfo) {
        if (context.mounted) {
          context.push(VideoPage(
            cid: videoInfo['cid'],
            avid: item.aid,
            title: item.title,
            imgUrl: item.pic,
          ));
        }
      });
    } else {
      AppToast.showWarning('暂未实现该功能');
    }
  }
}

import 'package:flutter/material.dart';

import 'search_model.dart';
import 'search_service.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;

  const SearchPage({super.key, this.initialQuery = ''});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  String _currentQuery = '';
  late TabController _tabController;

  final List<String> _tabs = ['综合', '番剧', '直播', '用户', '影视', '图文'];
  final Map<String, String> _tabSearchType = {
    '综合': '',
    '番剧': 'media_bangumi',
    '直播': 'live',
    '用户': 'user',
    '影视': 'media_ft',
    '图文': 'article',
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    if (widget.initialQuery.isNotEmpty) {
      _currentQuery = widget.initialQuery;
      _performSearch(
          widget.initialQuery, _tabSearchType[_tabs[_tabController.index]]!);
    }
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
    _performSearch(_currentQuery, _tabSearchType[_tabs[index]]!);
  }

  Future<void> _performSearch(String query, String searchType) async {
    setState(() {
      _isLoading = true;
      _currentQuery = query;
    });
    try {
      final res = await (searchType.isEmpty
          ? SearchService.searchAll(query)
          : SearchService.searchType(query, searchType: searchType));
      if (res == null) return;
      final searchResponse = SearchResponse.fromJson(res.data);
      setState(() {
        _searchResults = searchResponse.data.result
            .where((item) => item.type == searchType)
            .toList();
      });
    } catch (e) {
      print('搜索失败: $e');
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: _tabs.map((tabName) {
                return _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty && _currentQuery.isNotEmpty
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
                    query, _tabSearchType[_tabs[_tabController.index]]!);
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
                  _tabSearchType[_tabs[_tabController.index]]!);
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
          onTap: () {
            // TODO route to detail page
          },
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
}

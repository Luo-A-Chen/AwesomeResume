import 'package:flutter/material.dart';
import 'package:flutter_app/api/nav_extension.dart';

import '../follow/follow_page.dart';
import '../home/home_page.dart';
import '../mine/mine_page.dart';
import '../settings/server_select_page.dart';
import '../settings/settings.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final _pageController = PageController();

  final _navItems = [
    PageItem(title: '首页', icon: Icons.home_outlined, page: const HomePage()),
    PageItem(
        title: '关注', icon: Icons.wind_power_outlined, page: const FollowPage()),
    PageItem(title: '我的', icon: Icons.person_outline, page: const MinePage()),
  ];

  var requester = Settings.instance.dataProvider;

  Future<void> _goSelectServer() async {
    await context.push(ServerSelectPage());
    setState(() {
      requester = Settings.instance.dataProvider;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (requester == null) return _selectServerView();
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _navItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: _changePage,
        type: BottomNavigationBarType.fixed,
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.title,
          );
        }).toList(),
      ),
    );
  }

  Widget _selectServerView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('请先选择服务器'),
            ElevatedButton(onPressed: _goSelectServer, child: Text('选择服务器'))
          ],
        ),
      ),
    );
  }

  void _changePage(int index) {
    setState(() {
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      _currentIndex = index;
    });
  }
}

class PageItem {
  final String title;
  final IconData icon;
  final Widget page;

  PageItem({required this.title, required this.icon, required this.page});
}

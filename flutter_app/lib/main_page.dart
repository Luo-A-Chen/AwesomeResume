import 'package:flutter/material.dart';
import 'package:flutter_app/api/nav_extension.dart';

import 'module/dynamic/dynamic_page.dart';
import 'module/home/home_page.dart';
import 'module/mine/mine_page.dart';
import 'module/settings/server_select_page.dart';
import 'module/settings/settings.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  initState() {
    super.initState();
  }

  final _navItems = [
    PageItem(title: '首页', icon: Icons.home, page: const HomePage()),
    PageItem(title: '动态', icon: Icons.wind_power, page: const DynamicPage()),
    PageItem(title: '我的', icon: Icons.person_outline, page: const MinePage()),
  ];

  var server = Settings.instance.server;

  Future<void> goToSlectServer() async {
    await context.push(ServerSelectPage());
    setState(() {
      server = Settings.instance.server;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (server == null) return noServerView();
    return Scaffold(
      body: PageView(
        key: Key('$_currentIndex'),
        controller: PageController(initialPage: _currentIndex),
        physics: const NeverScrollableScrollPhysics(),
        children: _navItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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

  Widget noServerView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('请先选择服务器'),
            ElevatedButton(onPressed: goToSlectServer, child: Text('选择服务器'))
          ],
        ),
      ),
    );
  }
}

class PageItem {
  final String title;
  final IconData icon;
  final Widget page;

  PageItem({required this.title, required this.icon, required this.page});
}

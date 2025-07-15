import 'package:flutter/material.dart';
import 'package:flutter_app/api/nav_extension.dart';

import '../settings/settings_page.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () =>context.push(SettingsPage()),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: Text('我的'),
      ),
    );
  }
}

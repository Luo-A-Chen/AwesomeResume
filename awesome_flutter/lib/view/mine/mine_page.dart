import 'package:flutter/material.dart';
import 'package:awesome_flutter/api/nav_extension.dart';

import '../settings/settings_page.dart';
import 'login_page.dart';

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
            onPressed: () => context.push(SettingsPage()),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(250, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            foregroundColor: Colors.white,
            backgroundColor: Colors.pinkAccent,
          ),
          onPressed: () {
            context.push(const LoginPage()).then((_) {
              setState(() {});
            });
          },
          child: const Text('登录'),
        ),
      ),
    );
  }
}

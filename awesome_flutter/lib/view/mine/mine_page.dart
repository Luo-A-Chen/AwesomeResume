import 'package:flutter/material.dart';
import 'package:awesome_flutter/api/nav_extension.dart';

import '../settings/settings_page.dart';
import 'auth_provider.dart';
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
          ),
          onPressed: AuthProvider().isLogIn
              ? null // 如果已登录，则按钮不可点击
              : () {
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

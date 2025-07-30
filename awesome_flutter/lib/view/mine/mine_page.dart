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
        child: AuthProvider().isLogIn
            ? ElevatedButton(
                onPressed: () {
                  setState(() {
                    AuthProvider().logout();
                  });
                },
                child: Text('退出登录'),
              )
            : ElevatedButton(
                onPressed: () {
                  context.push(const LoginPage()).then((_) {
                    setState(() {});
                  });
                },
                child: Text('登录'),
              ),
      ),
    );
  }
}

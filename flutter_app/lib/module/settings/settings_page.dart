import 'package:flutter/material.dart';
import 'package:flutter_app/api/nav_extension.dart';

import 'server_select_page.dart';
import 'settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var settings = Settings.instance;

    Future<void> goToSlectServer() async {
    await context.push(ServerSelectPage());
    setState(() {
      settings = Settings.instance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置'), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            title: Text('服务器'),
            subtitle: Text(Settings.instance.server?.name ?? '未设置'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: goToSlectServer,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../server/server.dart';
import 'settings.dart';

class ServerSelectPage extends StatelessWidget {
  const ServerSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择服务器')),
      body: ListView.builder(
        itemCount: Server.values.length,
        itemBuilder: (BuildContext context, int index) {
          final server = Server.values[index];
          final settings = Settings.instance;
          return ListTile(
              title: Text(server.name),
              subtitle: Text(server.baseUrl),
              trailing:
                  server == settings.server ? const Icon(Icons.check) : null,
              onTap: () {
                settings.setServer(server);
                Navigator.pop(context);
              });
        },
      ),
    );
  }
}

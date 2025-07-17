import 'package:flutter/material.dart';

import '../../requester/requester.dart';
import 'settings.dart';

class ServerSelectPage extends StatelessWidget {
  const ServerSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择服务器')),
      body: ListView.builder(
        itemCount: Requester.values.length,
        itemBuilder: (BuildContext context, int index) {
          final requester = Requester.values[index];
          final settings = Settings.instance;
          return ListTile(
              title: Text(requester.serverName),
              trailing: requester == settings.requester
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => settings.changeServer(requester));
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../data_provider/data_provider.dart';
import 'settings.dart';

class ServerSelectPage extends StatelessWidget {
  const ServerSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择服务器')),
      body: ListView.builder(
        itemCount: DataProvider.values.length,
        itemBuilder: (BuildContext context, int index) {
          final requester = DataProvider.values[index];
          final settings = Settings.instance;
          return ListTile(
              title: Text(requester.serverName),
              trailing: requester == settings.dataProvider
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => settings.changeServer(requester));
        },
      ),
    );
  }
}

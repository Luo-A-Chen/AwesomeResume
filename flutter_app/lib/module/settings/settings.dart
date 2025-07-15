import 'dart:convert';

import '../../api/local_storage.dart';
import 'server.dart';

class Settings {
  Server? _server;
  Server? get server => _server;

  static Settings instance = Settings._();
  Settings._();

  Settings._fromJson(Map json)
      : _server = Server.values
            .firstWhere((element) => element.name == json['server']);

  Future<void> setServer(Server server) async {
    _server = server;
    _server!.initNetRequester();
    saveToLocal();
  }

  /// 只在app启动时调用一次
  static loadFromLocal() async {
    final josnString = await LocalStorage.readJsonFileString('settings');
    if (josnString == null) return;
    final json = jsonDecode(josnString);
    instance = Settings._fromJson(json);
  }

  Future<void> saveToLocal() async {
    final jsonString = jsonEncode(toJson());
    await LocalStorage.saveStringToJsonFile('settings', jsonString);
  }

  Map toJson() {
    return {
      'server': server?.name,
    };
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../api/local_storage.dart';
import '../../data_provider/data_provider.dart';

class Settings {
  final ValueNotifier<Key> appKeyNotifier = ValueNotifier(Key('app'));
  DataProvider? _dataProvider;
  DataProvider? get dataProvider => _dataProvider;

  static Settings instance = Settings._();
  Settings._();

  Settings._fromJson(Map json)
      : _dataProvider = DataProvider.values
            .firstWhere((element) => element.serverName == json['server']);

  Future<void> changeServer(DataProvider requester) async {
    _dataProvider = requester; // 更新请求器
    await _dataProvider!.initHttp(); // 初始化网络请求配置
    restartApp(); // 重启app
    saveToLocal();
  }

  void restartApp() => appKeyNotifier.value = UniqueKey();

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
      'server': dataProvider?.serverName,
    };
  }
}

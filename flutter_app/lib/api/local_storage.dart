import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class LocalStorage {
  LocalStorage._();
  static SharedPreferences? sp;

  /// TODO 必须在运行软件前调用
  static initSP() async => sp = await SharedPreferences.getInstance();

  static Future<void> saveStringToJsonFile(String name, String string) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/$name.json');
    await file.writeAsString(string);
  }

  static Future<String?> readJsonFileString(String name) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/$name.json');
    if (!await file.exists()) return null;
    final contents = await file.readAsString();
    return contents;
  }
}

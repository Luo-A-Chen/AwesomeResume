import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'api/app_toast.dart';
import 'main_page.dart';
import 'module/settings/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.loadFromLocal(); // 从本地加载设置
  await Settings.instance.requester?.initHttpCinfig(); // 初始化网络请求
  final app = RestartableApp(keyNotifier: Settings.instance.appKeyNotifier);
  runApp(app);
}

class RestartableApp extends StatefulWidget {
  final ValueNotifier<Key> keyNotifier;

  const RestartableApp({super.key, required this.keyNotifier});

  @override
  State<RestartableApp> createState() => _RestartableAppState();
}

class _RestartableAppState extends State<RestartableApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.keyNotifier,
      builder: (context, key, _) {
        return MaterialApp(
          key: key,
          builder: FToastBuilder(),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFFFF5F8F), // 主题色
            scaffoldBackgroundColor:
                const Color.fromRGBO(238, 238, 238, 1), // 背景色
          ),
          // 语言设置
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(builder: (context) {
            AppToast.init(context);
            return const MainPage();
          }),
        );
      },
    );
  }
}

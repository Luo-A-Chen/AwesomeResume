import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart' as f_toast;
import 'package:window_manager/window_manager.dart';

import 'api/toast.dart';
import 'api/local_storage.dart';
import 'state/player_state.dart';
import 'view/bottom_nav/main_page.dart';
import 'view/settings/settings.dart';
import 'view/mine/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.initSP(); // 必须在运行软件前初始化本地存储
  await Settings.loadFromLocal(); // 从本地加载设置
  await Settings.instance.dataProvider?.initHttp(); // 初始化网络请求
  await AuthProvider().init(); // TODO 暂时只针对blbl
  await PlayerState.initState(); // 初始化播放器状态
  try {
    await windowManager.ensureInitialized();
  } catch (e) {
    // TODO 鸿蒙不支持
    print(e);
  }
// 初始化窗口管理
  runApp(RestartableApp(keyNotifier: Settings.instance.appKeyNotifier));
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
        final primaryColor = Color(0xffFB7299);
        return MaterialApp(
          key: key,
          builder: f_toast.FToastBuilder(),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: primaryColor,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              // 禁用滑动内容后appbar变色
              scrolledUnderElevation: 0,
            ),
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
            scaffoldBackgroundColor:
                const Color.fromRGBO(238, 238, 238, 1), // 背景色
            splashFactory: NoSplash.splashFactory, // 禁用涟漪效果
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // 按钮文字颜色
                backgroundColor: primaryColor, // 按钮背景颜色
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: primaryColor,
              type: BottomNavigationBarType.fixed,
            ),
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
            Toast.init(context);
            return const MainPage();
          }),
        );
      },
    );
  }
}

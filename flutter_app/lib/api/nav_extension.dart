import 'package:flutter/material.dart';

extension NavExtension on BuildContext {
  /// 跳转到新页面
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => page));
  }

  /// 返回上一个
  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// 替换当前页面
  Future<T?> pushReplacement<T>(Widget page) {
    return Navigator.of(this)
        .pushReplacement<T, dynamic>(MaterialPageRoute(builder: (_) => page));
  }

  /// 回到根页面
  void popUntil() {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  AppToast._();
  static final _fToast = FToast();

  static void init(BuildContext context) => _fToast.init(context);

  static Future serverUnimplemented() async {
    await Future.delayed(const Duration(milliseconds: 100));
    showWarning('当前服务器未实现该功能');
    throw UnimplementedError('当前服务器未实现该功能');
  }

  static void showWarning(String message) {
    _fToast.showToast(
      gravity: ToastGravity.CENTER,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              Text(message, style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/http.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider._() {
    // 初始化时自动检查登录状态
    init();
  }

  static final AuthProvider _instance = AuthProvider._();

  factory AuthProvider() => _instance;

  // 登录状态
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // 用户信息
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? get userInfo => _userInfo;

  // 二维码相关
  String? _qrcodeKey;
  String? _qrcodeUrl;
  String? get qrcodeUrl => _qrcodeUrl;

  Timer? pollTimer;
  bool _isPolling = false;

  // 二维码状态
  QRCodeStatus _qrStatus = QRCodeStatus.waiting;
  QRCodeStatus get qrStatus => _qrStatus;
  String _qrMessage = '请使用哔哩哔哩客户端扫码登录';
  String get qrMessage => _qrMessage;

  // Cookie存储
  String? _sessData;
  String? _biliJct;
  String? _dedeUserId;
  String? _dedeUserIdCkMd5;

  /// 初始化，检查本地登录状态
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sessData = prefs.getString('SESSDATA');
      _biliJct = prefs.getString('bili_jct');
      _dedeUserId = prefs.getString('DedeUserID');
      _dedeUserIdCkMd5 = prefs.getString('DedeUserID__ckMd5');

      if (_sessData != null && _biliJct != null) {
        // 验证登录状态
        await _checkLoginStatus();
      }
    } catch (e) {
      debugPrint('初始化登录状态失败: $e');
    }
  }

  /// 检查登录状态
  Future<void> _checkLoginStatus() async {
    try {
      final res = await Http.get(
        '/web-interface/nav',
        headers: {
          'Cookie':
              'SESSDATA=$_sessData; bili_jct=$_biliJct; DedeUserID=$_dedeUserId; DedeUserID__ckMd5=$_dedeUserIdCkMd5',
        },
      );

      final data = res.data;

      if (data['code'] == 0 && data['data']['isLogin'] == true) {
        _isLoggedIn = true;
        _userInfo = data['data'];
        notifyListeners();
      } else {
        await _clearLoginData();
      }
    } catch (e) {
      debugPrint('检查登录状态失败: $e');
      await _clearLoginData();
    }
  }

  /// 申请二维码
  Future<bool> generateQRCode() async {
    try {
      _updateQRStatus(QRCodeStatus.loading, '正在生成二维码...');

      final res = await Http.get(
        'https://passport.bilibili.com/x/passport-login/web/qrcode/generate',
      );
      final data = res.data;

      if (data['code'] == 0) {
        _qrcodeKey = data['data']['qrcode_key'];
        _qrcodeUrl = data['data']['url'];
        _updateQRStatus(QRCodeStatus.waiting, '请使用哔哩哔哩客户端扫码登录');

        // 开始轮询
        _startPolling();
        return true;
      } else {
        _updateQRStatus(QRCodeStatus.error, '生成二维码失败');
        return false;
      }
    } catch (e) {
      debugPrint('生成二维码失败: $e');
      _updateQRStatus(QRCodeStatus.error, '网络错误，请重试');
      return false;
    }
  }

  /// 开始轮询二维码状态
  void _startPolling() {
    if (_isPolling || _qrcodeKey == null) return;

    _isPolling = true;
    pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _pollQRCodeStatus();
    });
  }

  /// 轮询二维码状态
  Future<void> _pollQRCodeStatus() async {
    if (_qrcodeKey == null) return;

    try {
      final res = await Http.get(
        // 将 qrcode_key 作为 URL 参数传递
        'https://passport.bilibili.com/x/passport-login/web/qrcode/poll?qrcode_key=$_qrcodeKey',
        // 移除 headers 中传递 qrcode_key 的部分
        // headers: {'qrcode_key': _qrcodeKey!},
      );

      final redData = res.data;
      if (redData['code'] == 0) {
        final data = redData['data'];
        final code = data['code'];
        final message = data['message'];

        // 打印服务器返回的状态码和消息
        print('QR Poll Status: code=$code, message=$message');

        switch (code) {
          case 86101: // 未扫码
            _updateQRStatus(QRCodeStatus.waiting, '请使用哔哩哔哩客户端扫码登录');
            break;
          case 86090: // 已扫码未确认
            _updateQRStatus(QRCodeStatus.scanned, '扫描成功，请在手机上确认登录');
            break;
          case 0: // 登录成功
            await _handleLoginSuccess(data);
            break;
          case 86038: // 二维码已失效
            _updateQRStatus(QRCodeStatus.expired, '二维码已过期，请点击刷新');
            _stopPolling();
            break;
          default:
            _updateQRStatus(QRCodeStatus.error, message ?? '未知错误');
            break;
        }
      }
    } catch (e) {
      debugPrint('轮询二维码状态失败: $e');
    }
  }

  /// 处理登录成功
  Future<void> _handleLoginSuccess(Map<String, dynamic> data) async {
    try {
      _stopPolling();
      _updateQRStatus(QRCodeStatus.success, '登录成功');

      // 从响应中提取cookie信息
      final url = data['url'] as String?;
      if (url != null) {
        final uri = Uri.parse(url);
        _sessData = uri.queryParameters['SESSDATA'];
        _biliJct = uri.queryParameters['bili_jct'];
        _dedeUserId = uri.queryParameters['DedeUserID'];
        _dedeUserIdCkMd5 = uri.queryParameters['DedeUserID__ckMd5'];
      }

      // 保存到本地
      await _saveLoginData();

      // 获取用户信息
      await _checkLoginStatus();
    } catch (e) {
      debugPrint('处理登录成功失败: $e');
      _updateQRStatus(QRCodeStatus.error, '登录失败，请重试');
    }
  }

  /// 保存登录数据到本地
  Future<void> _saveLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_sessData != null) await prefs.setString('SESSDATA', _sessData!);
      if (_biliJct != null) await prefs.setString('bili_jct', _biliJct!);
      if (_dedeUserId != null) {
        await prefs.setString('DedeUserID', _dedeUserId!);
      }
      if (_dedeUserIdCkMd5 != null) {
        await prefs.setString('DedeUserID__ckMd5', _dedeUserIdCkMd5!);
      }
    } catch (e) {
      debugPrint('保存登录数据失败: $e');
    }
  }

  /// 清除登录数据
  Future<void> _clearLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('SESSDATA');
      await prefs.remove('bili_jct');
      await prefs.remove('DedeUserID');
      await prefs.remove('DedeUserID__ckMd5');

      _isLoggedIn = false;
      _userInfo = null;
      _sessData = null;
      _biliJct = null;
      _dedeUserId = null;
      _dedeUserIdCkMd5 = null;

      notifyListeners();
    } catch (e) {
      debugPrint('清除登录数据失败: $e');
    }
  }

  /// 更新二维码状态
  void _updateQRStatus(QRCodeStatus status, String message) {
    _qrStatus = status;
    _qrMessage = message;
    notifyListeners();
  }

  /// 停止轮询
  void _stopPolling() {
    _isPolling = false;
    pollTimer?.cancel();
    pollTimer = null;
  }

  /// 刷新二维码
  Future<void> refreshQRCode() async {
    _stopPolling();
    await generateQRCode();
  }

  /// 登出
  Future<void> logout() async {
    _stopPolling();
    await _clearLoginData();
  }

  /// 获取认证头
  Map<String, String>? getAuthHeaders() {
    if (!_isLoggedIn) return null;
    return {
      'Cookie':
          'SESSDATA=$_sessData; bili_jct=$_biliJct; DedeUserID=$_dedeUserId; DedeUserID__ckMd5=$_dedeUserIdCkMd5',
    };
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}

/// 二维码状态枚举
enum QRCodeStatus {
  loading, // 加载中
  waiting, // 等待扫码
  scanned, // 已扫码
  success, // 登录成功
  expired, // 已过期
  error, // 错误
}

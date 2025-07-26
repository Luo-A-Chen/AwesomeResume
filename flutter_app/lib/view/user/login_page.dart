import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // 获取AuthProvider实例
  final _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    // 页面加载时生成二维码
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider.generateQRCode();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: _authProvider,
        builder: (context, child) {
          // 登录成功后自动返回
          if (_authProvider.isLoggedIn) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
          }

          return OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;
              final qrSection = _buildQRSection(_authProvider);
              final inputSection = _buildInputSection();
              if (isLandscape) {
                return Row(
                  children: [
                    Expanded(child: SingleChildScrollView(child: qrSection)),
                    Expanded(child: SingleChildScrollView(child: inputSection)),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Column(children: [qrSection, inputSection]),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildQRSection(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '扫描二维码登录',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 32),

          // 二维码区域
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildQRCodeWidget(authProvider),
          ),

          const SizedBox(height: 16),

          // 状态提示文字
          Text(
            authProvider.qrMessage,
            style: TextStyle(
              fontSize: 14,
              color: _getMessageColor(authProvider.qrStatus),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // 刷新按钮（仅在过期或错误时显示）
          if (authProvider.qrStatus == QRCodeStatus.expired ||
              authProvider.qrStatus == QRCodeStatus.error)
            ElevatedButton(
              onPressed: () => authProvider.refreshQRCode(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A1D6),
                foregroundColor: Colors.white,
              ),
              child: const Text('刷新二维码'),
            ),

          const SizedBox(height: 24),

          // 说明文字
          const Column(
            children: [
              Text(
                '请使用哔哩哔哩客户端',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '扫码登录或扫码下载APP',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeWidget(AuthProvider authProvider) {
    switch (authProvider.qrStatus) {
      case QRCodeStatus.loading:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A1D6)),
          ),
        );

      case QRCodeStatus.expired:
      case QRCodeStatus.error:
        return GestureDetector(
          onTap: () => authProvider.refreshQRCode(),
          child: Container(
            color: Colors.grey.shade100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  size: 48,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                Text(
                  '点击刷新',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        if (authProvider.qrcodeUrl != null) {
          return GestureDetector(
            onTap: () => authProvider.refreshQRCode(),
            child: QrImageView(
              data: authProvider.qrcodeUrl!,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
            ),
          );
        } else {
          return GestureDetector(
            onTap: () => authProvider.generateQRCode(),
            child: Container(
              color: Colors.grey.shade100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 48,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击生成二维码',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    }
  }

  Color _getMessageColor(QRCodeStatus status) {
    switch (status) {
      case QRCodeStatus.success:
        return Colors.green;
      case QRCodeStatus.error:
      case QRCodeStatus.expired:
        return Colors.red;
      case QRCodeStatus.scanned:
        return const Color(0xFF00A1D6);
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 标签栏
          Row(
            children: [
              const Text(
                '密码登录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                '短信登录',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 手机号输入框
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: const Text(
                    '+86',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      hintText: '请输入手机号',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 密码输入框
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: '请输入密码',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              obscureText: true,
            ),
          ),

          const SizedBox(height: 24),

          // 登录按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 实现密码登录逻辑
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('密码登录功能暂未实现')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A1D6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                '登录/注册',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 其他登录方式
          const Text(
            '其他方式登录',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 16),

          // 第三方登录按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialLoginButton(
                icon: Icons.wechat,
                color: const Color(0xFF1AAD19),
                label: '微信登录',
              ),
              const SizedBox(width: 16),
              _buildSocialLoginButton(
                icon: Icons.account_circle,
                color: const Color(0xFFEB4F38),
                label: '微博登录',
              ),
              const SizedBox(width: 16),
              _buildSocialLoginButton(
                icon: Icons.account_circle_outlined,
                color: const Color(0xFF4285F4),
                label: 'QQ登录',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 协议文字
          const Text(
            '未注册过的手机号，我们将自动帮你注册账号\n登录或注册即代表你同意 用户协议 和 隐私政策',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label功能暂未实现')),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

import '../../../api/http.dart';
import '../../user/auth_provider.dart';
import '../dynamic.dart';

class DynamicProvider {
  DynamicProvider._();

  /// 获取关注用户动态列表
  ///
  /// 参数说明：
  /// - type: 动态类型，all表示全部
  /// - offset: 分页偏移量，第一次请求时为空
  static Future<DynamicsResponse> getFollowedDynamics({
    String type = 'all',
    String? offset,
  }) async {
    try {
      // 获取认证头部
      final authHeaders = AuthProvider().getAuthHeaders();

      final queryParams = {
        'type': type,
        if (offset != null) 'offset': offset,
        'page': 1, // API文档中提到page参数，但实际分页依赖offset
      };

      final res = await Http.get(
        'https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all',
        params: queryParams,
        headers: authHeaders,
      );
      final data = res.data;
      final code = data['code'];
      if (code != 0) {
        if (code == -101) {
          // TODO: 未登录时跳转登录
          throw Exception('未登录');
        }
        throw Exception(data['message']);
      }

      return DynamicsResponse.fromJson(data);
    } catch (e) {
      print('获取关注动态失败: $e');
      rethrow;
    }
  }

  /// 获取最常访问用户列表
  /// API文档中未找到直接获取最常访问用户的接口，这里先返回模拟数据
  static Future<List<FrequentUser>> getFrequentUsers() async {
    // TODO: 查找或实现获取最常访问用户的API
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
    return [
      FrequentUser(
          mid: 1,
          name: '最常',
          face: 'https://i0.hdslb.com/bfs/face/member/noface.jpg'),
      FrequentUser(
          mid: 2,
          name: '访问',
          face: 'https://i0.hdslb.com/bfs/face/member/noface.jpg'),
      FrequentUser(
          mid: 3,
          name: '用户',
          face: 'https://i0.hdslb.com/bfs/face/member/noface.jpg'),
      FrequentUser(
          mid: 4,
          name: '待开发',
          face: 'https://i0.hdslb.com/bfs/face/member/noface.jpg'),
    ];
  }
}

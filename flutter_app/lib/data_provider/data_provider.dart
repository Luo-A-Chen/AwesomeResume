import 'blbl_provider.dart';
import 'a_r_provider.dart';
import '../search/search_provider.dart';
import '../video/video_provider.dart';

abstract class DataProvider {
  final String serverName;
  VideoProvider? videoProvider;
  SearchProvider? searchProvider;

  /// 当切换到该服务器时，调用该方法配置HTTP
  Future initHttp();

  DataProvider({
    required this.serverName,
    this.videoProvider,
    this.searchProvider,
  });

  static final List<DataProvider> values = [
    ARProvider(),
    BlblProvider(),
  ];
}

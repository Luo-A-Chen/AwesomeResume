import 'data_provider.dart';

class ARProvider extends DataProvider {
  ARProvider() : super(serverName: 'AwesomeResume');

  @override
  Future<void> initHttp() async {
  }
}

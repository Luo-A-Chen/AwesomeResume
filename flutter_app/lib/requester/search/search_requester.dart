import '../../module/search/search_model.dart';

abstract class SearchRequester {
  Future<List<SearchResult>> getTypeSearchResults(
    String keyword, {
    num page = 1,
    String? order,
    num? duration,
    String? tids,
    required String searchType,
  });

  Future<List<SearchResult>> getAllSearchResults();
}

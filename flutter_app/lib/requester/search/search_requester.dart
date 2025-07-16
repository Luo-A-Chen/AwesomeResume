import '../../module/search/search_model.dart';

abstract class SearchRequester {
  Future<List<SearchResult>> getTypeSearchResults(
    String keyword, {
    int page = 1,
    int pageSize = 20,
    String order = 'totalrank',
    String duration = '0',
    String tids = '0',
    required String searchType,
  });

  Future<List<SearchResult>> getAllSearchResults();
}

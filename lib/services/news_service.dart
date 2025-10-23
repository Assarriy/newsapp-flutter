import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/models/news_response.dart';
import 'package:news_app/utils/constants.dart';

class NewsService {
  static const String _baseUrl = Constants.baseUrl;
  static final String _apiKey = Constants.apiKey;

  Future<NewsResponse> getTopHeadlines({
    String country = Constants.defaultCountry,
    String? category,
    String? q, // DITAMBAHKAN: Untuk fitur "Related News"
    int page = 1,
    int pageSize = 5, // DIPERBARUI: Default diubah ke 5 untuk pagination
  }) async {
    try {
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'country': country,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      // DITAMBAHKAN: Logika untuk parameter "q"
      if (q != null && q.isNotEmpty) {
        queryParams['q'] = q;
      }

      final uri = Uri.parse(
        '$_baseUrl${Constants.topHeadlines}',
      ).replace(queryParameters: queryParams);

      print('Requesting URL: $uri'); // Untuk debugging

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NewsResponse.fromJson(jsonData);
      } else {
        // DIPERBARUI: Error handling lebih baik
        final errorBody = json.decode(response.body);
        throw Exception('Failed to load news: ${errorBody['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<NewsResponse> searchNews({
    required String query,
    int page = 1,
    int pageSize = 20, // Biarkan 20 untuk halaman pencarian
    String? sortBy,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'q': query,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      final uri = Uri.parse(
        '$_baseUrl${Constants.everything}',
      ).replace(queryParameters: queryParams);

      print('Requesting URL: $uri'); // Untuk debugging

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NewsResponse.fromJson(jsonData);
      } else {
        // DIPERBARUI: Error handling lebih baik
        final errorBody = json.decode(response.body);
        throw Exception('Failed to search news: ${errorBody['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController {
  final NewsService _newsService;
  NewsController(this._newsService);

  // Variabel untuk berita utama dan kategori
  final _isLoading = true.obs;
  final _articles = <NewsArticle>[].obs;
  final _selectedCategory = 'general'.obs;
  final _error = ''.obs;

  // Variabel untuk fitur pencarian
  final TextEditingController searchController = TextEditingController();
  final _searchQuery = ''.obs;
  final _searchResults = <NewsArticle>[].obs;
  final _isSearchLoading = false.obs;
  final _hasSearched = false.obs;

  // --- Getters ---
  bool get isLoading => _isLoading.value;
  List<NewsArticle> get articles => _articles;
  String get selectedCategory => _selectedCategory.value;
  String get error => _error.value;
  List<String> get categories => Constants.categories;

  String get searchQuery => _searchQuery.value;
  List<NewsArticle> get searchResults => _searchResults;
  RxBool get isSearchLoading => _isSearchLoading;
  RxBool get hasSearched => _hasSearched;

  @override
  void onInit() {
    super.onInit();
    fetchTopHeadlines();

    // Listener untuk pencarian otomatis dengan debounce
    debounce(
      _searchQuery,
      (query) {
        if (query.isNotEmpty) {
          searchNews(query);
        }
      },
      time: const Duration(milliseconds: 800),
    );

    searchController.addListener(() {
      _searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // --- Fungsi-fungsi ---
  Future<void> fetchTopHeadlines({String? category}) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      final response = await _newsService.getTopHeadlines(
        category: category ?? _selectedCategory.value,
      );
      _articles.value = response.articles;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshNews() async {
    // Saat refresh, panggil kembali berita untuk kategori yang sedang dipilih
    await fetchTopHeadlines(category: _selectedCategory.value);
  }

  void selectCategory(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchTopHeadlines(category: category);
    }
  }

  Future<void> searchNews(String query) async {
    if (query.length < 2) {
      _searchResults.clear();
      return;
    }

    _isSearchLoading.value = true;
    _hasSearched.value = true;
    try {
      final response = await _newsService.searchNews(query: query);
      _searchResults.value = response.articles;
    } catch (e) {
      Get.snackbar('Error', 'Failed to search news: $e');
      _searchResults.clear();
    } finally {
      _isSearchLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    _searchResults.clear();
    _hasSearched.value = false;
  }
}
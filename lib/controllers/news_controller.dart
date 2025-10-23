import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController {
  final NewsService _newsService;
  NewsController(this._newsService);

  // Variabel untuk related news (Tetap ada)
  final _relatedArticles = <NewsArticle>[].obs;
  List<NewsArticle> get relatedArticles => _relatedArticles;

  // Variabel untuk berita utama dan kategori
  final _isLoading = true.obs;
  final _articles = <NewsArticle>[].obs;
  final _selectedCategory = 'general'.obs;
  final _error = ''.obs;

  // === TAMBAHKAN: Variabel baru untuk Pagination ===
  final _currentPage = 1.obs;
  final _isLoadMoreLoading = false.obs;
  final _canLoadMore = true.obs;
  // =============================================

  // Variabel untuk fitur pencarian (Tetap ada)
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

  // === TAMBAHKAN: Getter baru untuk Pagination ===
  bool get isLoadMoreLoading => _isLoadMoreLoading.value;
  bool get canLoadMore => _canLoadMore.value;
  // ===========================================

  @override
  void onInit() {
    super.onInit();
    fetchTopHeadlines();

    // Listener pencarian (Tetap ada)
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

  // --- PERBARUI FUNGSI INI ---
  Future<void> fetchTopHeadlines({String? category}) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      _currentPage.value = 1;     // Selalu reset ke halaman 1
      _canLoadMore.value = true;  // Aktifkan kembali load more

      final response = await _newsService.getTopHeadlines(
        category: category ?? _selectedCategory.value,
        page: _currentPage.value, // Gunakan halaman saat ini (yaitu 1)
        pageSize: 5,               // Ambil 5 berita
      );

      // Jika berita yang kembali kurang dari 5, nonaktifkan load more
      if (response.articles.length < 5) {
        _canLoadMore.value = false;
      }
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
  // --- Akhir Perubahan ---

  Future<void> refreshNews() async {
    // Fungsi ini sekarang akan memanggil fetchTopHeadlines versi baru
    await fetchTopHeadlines(category: _selectedCategory.value);
  }

  void selectCategory(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      // Fungsi ini sekarang akan memanggil fetchTopHeadlines versi baru
      fetchTopHeadlines(category: category);
    }
  }

  // === TAMBAHKAN: Fungsi baru untuk Load More ===
  Future<void> loadMoreArticles() async {
    // Jangan lakukan apa pun jika sedang memuat atau berita sudah habis
    if (_isLoadMoreLoading.value || !_canLoadMore.value) return;

    try {
      _isLoadMoreLoading.value = true;
      _currentPage.value++; // Naikkan nomor halaman

      final response = await _newsService.getTopHeadlines(
        category: _selectedCategory.value,
        page: _currentPage.value, // Ambil halaman berikutnya
        pageSize: 5,
      );

      // Jika tidak ada berita baru atau kurang dari 5, nonaktifkan tombol
      if (response.articles.isEmpty || response.articles.length < 5) {
        _canLoadMore.value = false;
      }

      // Tambahkan berita baru ke daftar yang sudah ada
      _articles.addAll(response.articles);
    } catch (e) {
      _currentPage.value--; // Kembalikan nomor halaman jika error
      Get.snackbar('Error', 'Failed to load more news: $e');
    } finally {
      _isLoadMoreLoading.value = false;
    }
  }
  // ============================================

  // Fungsi-fungsi ini tetap sama seperti kode lama Anda
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

  Future<void> fetchRelatedNews(String category, String currentArticleTitle) async {
    _relatedArticles.clear();
    try {
      final response = await _newsService.getTopHeadlines(
        category: category,
        pageSize: 6,
      );
      _relatedArticles.value = response.articles
          .where((article) =>
              article.title != currentArticleTitle && article.urlToImage != null)
          .take(4)
          .toList();
    } catch (e) {
      print('Gagal mengambil berita terkait: $e');
    }
  }

  void clearSearch() {
    searchController.clear();
    _searchResults.clear();
    _hasSearched.value = false;
  }
}
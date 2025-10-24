import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController { // <-- Brace { pembuka class
  final NewsService _newsService;
  NewsController(this._newsService);

  // Variabel untuk related news
  final _relatedArticles = <NewsArticle>[].obs;
  List<NewsArticle> get relatedArticles => _relatedArticles;

  // Variabel untuk berita utama dan kategori
  final _isLoading = true.obs;
  final _articles = <NewsArticle>[].obs;
  final _selectedCategory = 'general'.obs;
  final _error = ''.obs;

  // Variabel untuk Pagination
  final _currentPage = 1.obs;
  final _isLoadMoreLoading = false.obs;
  final _canLoadMore = true.obs;

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

  // Getters Pagination
  bool get isLoadMoreLoading => _isLoadMoreLoading.value;
  bool get canLoadMore => _canLoadMore.value;

  // Getters Pencarian
  String get searchQuery => _searchQuery.value;
  List<NewsArticle> get searchResults => _searchResults;
  RxBool get isSearchLoading => _isSearchLoading; // Dipertahankan untuk search page
  RxBool get hasSearched => _hasSearched;

  @override
  void onInit() {
    super.onInit();
    fetchTopHeadlines(); // Muat berita awal

    // Listener untuk pencarian otomatis
    debounce(
      _searchQuery,
      (query) {
        if (query.isNotEmpty) {
          searchNews(query);
        } else {
          // Bersihkan hasil jika query kosong
          _searchResults.clear();
          _hasSearched.value = false;
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

  // --- Fungsi Utama ---

  /// Mengambil berita utama (halaman 1) untuk kategori tertentu.
  Future<void> fetchTopHeadlines({String? category}) async {
    // Reset state sebelum memuat
    _isLoading.value = true;
    _error.value = '';
    _currentPage.value = 1;
    _canLoadMore.value = true;
    _articles.clear(); // Kosongkan daftar lama

    try {
      final response = await _newsService.getTopHeadlines(
        category: category ?? _selectedCategory.value,
        page: 1, // Selalu ambil halaman pertama
        pageSize: 5, // Ambil 5 berita
      );

      // Jika berita < 5, nonaktifkan load more
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

  /// Memuat halaman berita berikutnya untuk pagination.
  Future<void> loadMoreArticles() async {
    if (_isLoadMoreLoading.value || !_canLoadMore.value) return;

    _isLoadMoreLoading.value = true;
    try {
      _currentPage.value++; // Naikkan nomor halaman

      final response = await _newsService.getTopHeadlines(
        category: _selectedCategory.value,
        page: _currentPage.value, // Ambil halaman berikutnya
        pageSize: 5,
      );

      // Jika berita baru kosong atau < 5, nonaktifkan load more
      if (response.articles.isEmpty || response.articles.length < 5) {
        _canLoadMore.value = false;
      }

      _articles.addAll(response.articles); // Tambahkan ke daftar

    } catch (e) {
      _currentPage.value--; // Kembalikan halaman jika error
      Get.snackbar('Error', 'Failed to load more news: $e');
    } finally {
      _isLoadMoreLoading.value = false;
    }
  }

  /// Mengambil berita terkait berdasarkan judul artikel saat ini.
  Future<void> fetchRelatedNews(String currentArticleTitle) async {
    _relatedArticles.clear();
    try {
      // Ambil kata kunci dari judul
      String keyword = currentArticleTitle
          .split(' ')
          .firstWhere((word) => word.length > 4, orElse: () => 'news');

      print('Mencari berita terkait dengan kata kunci: "$keyword"');

      // Cari menggunakan parameter 'q'
      final response = await _newsService.getTopHeadlines(
        q: keyword,
        pageSize: 6, // Ambil lebih banyak untuk filtering
      );

      // Filter hasilnya
      _relatedArticles.value = response.articles
          .where((article) =>
              article.title != currentArticleTitle && article.urlToImage != null)
          .take(4) // Ambil maksimal 4
          .toList();

      print('Berita terkait ditemukan: ${_relatedArticles.length}');

    } catch (e) {
      print('Gagal mengambil berita terkait: $e');
      // Tidak perlu menampilkan snackbar error untuk related news
    }
  }

  /// Melakukan pencarian berita berdasarkan query.
  Future<void> searchNews(String query) async {
    if (query.length < 2) {
      _searchResults.clear();
      _hasSearched.value = false; // Belum dianggap mencari
      return;
    }

    _isSearchLoading.value = true;
    _hasSearched.value = true; // Sudah melakukan pencarian
    try {
      // Gunakan endpoint 'everything' untuk pencarian
      final response = await _newsService.searchNews(query: query, pageSize: 15); // Ambil lebih banyak untuk search
      _searchResults.value = response.articles;
    } catch (e) {
      Get.snackbar('Error', 'Failed to search news: $e');
      _searchResults.clear();
    } finally {
      _isSearchLoading.value = false;
    }
  }

  /// Membersihkan state pencarian.
  void clearSearch() {
    searchController.clear(); // Membersihkan text field
    _searchQuery.value = '';  // Membersihkan query observable
    _searchResults.clear(); // Membersihkan hasil
    _hasSearched.value = false; // Reset status pencarian
  }

  /// Memilih kategori baru dan memuat ulang berita.
  void selectCategory(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchTopHeadlines(category: category); // Ini akan me-reset pagination
    }
  }

  /// Memuat ulang berita untuk kategori saat ini (untuk RefreshIndicator).
  Future<void> refreshNews() async {
    // Panggil fetchTopHeadlines yang sudah diupdate
    await fetchTopHeadlines(category: _selectedCategory.value);
  }

} // <-- TAMBAHKAN BRACE PENUTUP INI
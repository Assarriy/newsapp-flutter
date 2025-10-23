import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/widgets/category_chip.dart';
import 'package:news_app/widgets/loading_shimmer.dart';
import 'package:news_app/widgets/news_card.dart';

class HomeView extends GetView<NewsController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Discover News',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded,
                color: AppColors.primaryText, size: 28),
            onPressed: () {
              // Bersihkan state pencarian sebelumnya sebelum navigasi
              controller.clearSearch();
              Get.toNamed(Routes.SEARCH);
            },
          ),
        ],
      ),
      body: SafeArea(
        // PERBAIKAN: Menggunakan Column untuk struktur layout yang benar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ## Bagian Judul Kategori ##
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Categories',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ## Daftar Kategori ##
            _buildCategorySection(),

            // ## Bagian Judul Latest News ##
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Latest News',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ## Daftar Latest News ##
            // PERBAIKAN: Menggunakan Expanded agar ListView bisa scroll
            Expanded(
              child: _buildLatestNewsSection(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk daftar kategori (horizontal)
  Widget _buildCategorySection() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(
            () => CategoryChip(
              label: category.capitalize ?? category,
              isSelected: controller.selectedCategory == category,
              onTap: () => controller.selectCategory(category),
            ),
          );
        },
      ),
    );
  }

  // Widget untuk daftar Latest News (vertical dengan pagination)
  Widget _buildLatestNewsSection() {
    return Obx(() {
      if (controller.isLoading && controller.articles.isEmpty) {
        return LoadingShimmer();
      }
      if (controller.error.isNotEmpty) {
        return _buildErrorWidget();
      }
      if (controller.articles.isEmpty) {
        return _buildEmptyWidget();
      }
      
      // PERBAIKAN: Menggunakan ListView.builder untuk pagination
      return RefreshIndicator(
        onRefresh: controller.refreshNews,
        backgroundColor: AppColors.accent,
        color: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          
          // Tambah 1 untuk tombol, hanya jika bisa memuat lebih banyak
          itemCount: controller.articles.length + (controller.canLoadMore ? 1 : 0),
          
          itemBuilder: (context, index) {
            
            // --- Logika untuk Tombol "Load More" ---
            if (index == controller.articles.length) {
              return Obx(() {
                if (controller.isLoadMoreLoading) {
                  // Tampilkan spinner saat sedang loading
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  );
                }
                // Tampilkan tombol "Load More"
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: ElevatedButton(
                      onPressed: controller.loadMoreArticles,
                      child: const Text('Load More'),
                    ),
                  ),
                );
              });
            }
            // --- Akhir Logika Tombol ---

            // Tampilkan NewsCard seperti biasa
            final article = controller.articles[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: NewsCard(
                article: article,
                onTap: () =>
                    Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
              ),
            );
          },
        ),
      );
    });
  }

  // Widget untuk tampilan Error
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 80, color: AppColors.secondaryText),
            const SizedBox(height: 20),
            const Text(
              'Something Went Wrong',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your internet connection.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.refreshNews,
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk tampilan data Kosong
  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.article_outlined,
                size: 80, color: AppColors.secondaryText),
            SizedBox(height: 20),
            Text(
              'No News Found',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText),
            ),
            SizedBox(height: 8),
            Text(
              'No articles were found for this category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
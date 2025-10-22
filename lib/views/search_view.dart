// lib/views/search_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/widgets/news_card.dart';

class SearchView extends GetView<NewsController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan controller yang sama dengan HomeView
    final NewsController controller = Get.find();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // Search bar kustom sebagai title
        title: _buildSearchBar(controller),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isSearchLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.accent));
        }
        if (controller.searchResults.isEmpty) {
          return _buildInitialOrEmptyView(controller);
        }
        return _buildResultsList(controller);
      }),
    );
  }

  // Widget untuk search bar di AppBar
  Widget _buildSearchBar(NewsController controller) {
    return TextField(
      controller: controller.searchController,
      autofocus: true,
      style: const TextStyle(color: AppColors.primaryText, fontSize: 18),
      decoration: InputDecoration(
        hintText: 'Search for news...',
        hintStyle: const TextStyle(color: AppColors.secondaryText),
        border: InputBorder.none,
        // Tombol 'clear' untuk menghapus teks
        suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.secondaryText),
                onPressed: () => controller.clearSearch(),
              )
            : const SizedBox.shrink()),
      ),
    );
  }

  // Widget untuk tampilan awal atau saat hasil tidak ditemukan
  Widget _buildInitialOrEmptyView(NewsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            controller.hasSearched.value
                ? Icons.search_off_rounded
                : Icons.search_rounded,
            size: 100,
            color: AppColors.secondaryText.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            controller.hasSearched.value
                ? 'No Results Found'
                : 'Search Any News',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan daftar hasil pencarian
  Widget _buildResultsList(NewsController controller) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: controller.searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final article = controller.searchResults[index];
        return NewsCard(
          article: article,
          onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
        );
      },
    );
  }
}
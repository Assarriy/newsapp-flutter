import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class NewsDetailView extends StatefulWidget {
  const NewsDetailView({super.key});

  @override
  State<NewsDetailView> createState() => _NewsDetailViewState();
}

class _NewsDetailViewState extends State<NewsDetailView> {
  final NewsArticle article = Get.arguments as NewsArticle;
  final NewsController controller = Get.find();

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil berita terkait saat halaman dibuka
    if (article.source?.name != null) {
      controller.fetchRelatedNews(
          article.source!.name!.toLowerCase().split(' ').first, article.title!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildArticleContent(),
          _buildRelatedNewsSection(),
        ],
      ),
      // Tombol Aksi Mengambang (Floating Action Button)
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  // WIDGET UNTUK APPBAR DENGAN EFEK PARALLAX
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gambar dengan efek parallax
            if (article.urlToImage != null)
              CachedNetworkImage(
                imageUrl: article.urlToImage!,
                fit: BoxFit.cover,
              )
            else
              Container(color: AppColors.cardBackground),

            // Gradient overlay agar judul terbaca jelas
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),

            // Judul di atas gambar
            Positioned(
              bottom: 60,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article.source?.name ?? 'News',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title ?? 'No Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 10.0, color: Colors.black54)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET UNTUK KONTEN UTAMA ARTIKEL
  SliverToBoxAdapter _buildArticleContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Author dan Tanggal
            Row(
              children: [
                const Icon(Icons.person_outline,
                    color: AppColors.secondaryText, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    article.source?.name ?? 'Unknown Author',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.secondaryText, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time_outlined,
                    color: AppColors.secondaryText, size: 18),
                const SizedBox(width: 8),
                if (article.publishedAt != null)
                  Text(
                    timeago.format(DateTime.parse(article.publishedAt!)),
                    style: const TextStyle(
                        color: AppColors.secondaryText, fontSize: 14),
                  ),
              ],
            ),
            const Divider(height: 40, color: AppColors.cardBackground),

            // Deskripsi dan Konten
            Text(
              (article.content ?? article.description ?? 'No content available.')
                  .split(' [+')
                  .first,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 17,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET UNTUK BAGIAN BERITA TERKAIT (RELATED NEWS)
  SliverToBoxAdapter _buildRelatedNewsSection() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.relatedArticles.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Related News',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...controller.relatedArticles.map((relatedArticle) {
                return GestureDetector(
                  onTap: () {
                    Get.offNamed(Routes.NEWS_DETAIL, arguments: relatedArticle);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: relatedArticle.urlToImage!,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            relatedArticle.title!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  // WIDGET UNTUK FLOATING ACTION BUTTON
  Widget _buildFloatingActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          onPressed: _shareArticle,
          heroTag: 'share_fab',
          backgroundColor: AppColors.cardBackground,
          child: const Icon(Icons.share_rounded, color: AppColors.primaryText),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: _openInBrowser,
          heroTag: 'browser_fab',
          backgroundColor: AppColors.accent,
          child:
              const Icon(Icons.open_in_browser_rounded, color: Colors.white),
        ),
      ],
    );
  }

  // --- Helper Functions ---
  void _shareArticle() {
    if (article.url != null) {
      Share.share(
          'Check out this news: ${article.title ?? ""}\n\n${article.url!}');
    }
  }

  void _openInBrowser() async {
    if (article.url != null) {
      final uri = Uri.parse(article.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
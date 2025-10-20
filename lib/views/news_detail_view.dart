import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:news_app/models/news_article.dart';
// Pastikan path ini benar dan AppColors sudah didefinisikan
import 'package:news_app/utils/app_colors.dart'; 

class NewsDetailView extends StatelessWidget {
  final NewsArticle article = Get.arguments as NewsArticle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar yang dinamis dengan gambar
          _buildSliverAppBar(),

          // Konten berita
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta data: Sumber dan tanggal
                  _buildArticleMeta(),
                  const SizedBox(height: 16),

                  // Judul Berita
                  Text(
                    article.title ?? 'No Title',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.3, // Jarak antar baris
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Deskripsi
                  if (article.description != null && article.description!.isNotEmpty) ...[
                    Text(
                      article.description!,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Konten utama
                  if (article.content != null && article.content!.isNotEmpty) ...[
                     Text(
                      // Menghapus bagian aneh seperti "[+1234 chars]" dari content
                      article.content!.split(' [+').first,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 17,
                        height: 1.7,
                        wordSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // Tombol "Baca Selengkapnya"
                  if (article.url != null) _buildReadMoreButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white, // Warna untuk back button dan icons
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gambar Berita
            if (article.urlToImage != null)
              CachedNetworkImage(
                imageUrl: article.urlToImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade800),
                errorWidget: (context, url, error) => _buildImagePlaceholder(),
              )
            else
              _buildImagePlaceholder(),
            
            // Gradient overlay untuk membuat teks lebih mudah dibaca
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        title: Text(
          article.source?.name ?? '',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        titlePadding: const EdgeInsets.only(left: 48, right: 48, bottom: 16),
      ),
      actions: [
        // Tombol Share dan Menu dengan background agar terlihat jelas
        Container(
          margin: const EdgeInsets.only(right: 12.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: _shareArticle,
                tooltip: 'Share',
              ),
              _buildPopupMenu(),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade800,
      child: Icon(Icons.image_not_supported_rounded, size: 60, color: Colors.grey.shade600),
    );
  }

  Widget _buildArticleMeta() {
    return Row(
      children: [
        if (article.source?.name != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accent, // Menggunakan warna aksen merah
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              article.source!.name!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (article.publishedAt != null)
          Text(
            timeago.format(DateTime.parse(article.publishedAt!)),
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
      ],
    );
  }

  Widget _buildReadMoreButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 20),
        label: Text(
          'Read Full Article',
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: _openInBrowser,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
      color: Color(0xFF2C2C2C), // Warna background menu
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'copy_link') _copyLink();
        if (value == 'open_browser') _openInBrowser();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'copy_link',
          child: Row(children: const [
            Icon(Icons.link_rounded, color: Colors.white70),
            SizedBox(width: 10),
            Text('Copy Link', style: TextStyle(color: Colors.white)),
          ]),
        ),
        PopupMenuItem(
          value: 'open_browser',
          child: Row(children: const [
            Icon(Icons.open_in_browser_rounded, color: Colors.white70),
            SizedBox(width: 10),
            Text('Open in Browser', style: TextStyle(color: Colors.white)),
          ]),
        ),
      ],
    );
  }

  // --- Helper Functions ---
  
  void _shareArticle() {
    if (article.url != null) {
      Share.share(
        '${article.title ?? 'Check out this news'}\n\n${article.url!}',
        subject: article.title,
      );
    }
  }

  void _copyLink() {
    if (article.url != null) {
      Clipboard.setData(ClipboardData(text: article.url!));
      Get.snackbar(
        'Success',
        'Link copied to clipboard!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF2C2C2C),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }

  void _openInBrowser() async {
    if (article.url != null) {
      final uri = Uri.parse(article.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error', 'Could not open the link',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.accent,
          colorText: Colors.white,
        );
      }
    }
  }
}
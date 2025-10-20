import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:news_app/models/news_article.dart';
// Pastikan path ke file AppColors Anda sudah benar
import 'package:news_app/utils/app_colors.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsCard({Key? key, required this.article, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16), // Efek ripple mengikuti bentuk container
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C), // Warna abu-abu gelap untuk kartu
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Kolom untuk teks (Judul dan meta)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Berita
                  Text(
                    article.title ?? 'No Title',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Meta data (Sumber dan waktu)
                  Row(
                    children: [
                      // Ikon untuk sumber
                      Icon(Icons.source_outlined, color: AppColors.secondaryText, size: 14),
                      const SizedBox(width: 4),
                      // Nama Sumber
                      Flexible( // Agar teks tidak overflow jika nama sumber terlalu panjang
                        child: Text(
                          article.source?.name ?? 'Unknown Source',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Text(" • ", style: TextStyle(color: AppColors.secondaryText)),
                      // Waktu publish
                      if (article.publishedAt != null)
                        Text(
                          timeago.format(DateTime.parse(article.publishedAt!), locale: 'en_short'),
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Gambar Berita
            _buildArticleImage(),
          ],
        ),
      ),
    );
  }

  // Widget terpisah untuk membangun gambar
  Widget _buildArticleImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: article.urlToImage != null
          ? CachedNetworkImage(
              imageUrl: article.urlToImage!,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 110,
                height: 110,
                color: Colors.grey.shade800,
              ),
              errorWidget: (context, url, error) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  // Widget placeholder jika tidak ada gambar
  Widget _buildImagePlaceholder() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade600,
        size: 40,
      ),
    );
  }
}
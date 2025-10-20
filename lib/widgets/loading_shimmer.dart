import 'package:flutter/material.dart';

class LoadingShimmer extends StatefulWidget {
  @override
  _LoadingShimmerState createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // Warna untuk shimmer effect di dark mode
  static const _shimmerBaseColor = Color(0xFF2C2C2C); // Abu-abu sangat gelap
  static const _shimmerHighlightColor = Color(0xFF3A3A3A); // Abu-abu sedikit lebih terang

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // ShaderMask akan menerapkan gradien ke semua widget di bawahnya
        return ShaderMask(
          blendMode: BlendMode.srcATop, // Terapkan gradien di atas warna child
          shaderCallback: (bounds) {
            final animationValue = _controller.value;
            // Menerjemahkan nilai animasi (0.0 - 1.0) menjadi gerakan gradien
            final slideA = 2 * animationValue - 1; 
            final slideB = slideA + 1.5;

            return LinearGradient(
              colors: const [
                _shimmerBaseColor,
                _shimmerHighlightColor,
                _shimmerBaseColor,
              ],
              stops: const [0.3, 0.5, 0.7],
              begin: Alignment(slideA, 0), // Gradien bergerak horizontal
              end: Alignment(slideB, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      // Child ini adalah layout statis dari placeholder kita
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: 5,
        itemBuilder: (context, index) => _buildPlaceholderItem(),
      ),
    );
  }

  // Widget untuk satu item placeholder
  Widget _buildPlaceholderItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder untuk gambar
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _shimmerBaseColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder untuk judul (2 baris)
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _shimmerBaseColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width * 0.7, // Baris kedua lebih pendek
            decoration: BoxDecoration(
              color: _shimmerBaseColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
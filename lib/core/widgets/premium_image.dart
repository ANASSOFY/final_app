import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PremiumImage extends StatelessWidget {
  const PremiumImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    final content = imageUrl.trim().isEmpty
        ? const _ImageFallback()
        : CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: fit,
            fadeInDuration: const Duration(milliseconds: 220),
            fadeOutDuration: const Duration(milliseconds: 120),
            memCacheWidth: memCacheWidth,
            memCacheHeight: memCacheHeight,
            placeholder: (context, url) => const _ImageShimmer(),
            errorWidget: (context, url, error) => const _ImageFallback(),
          );

    if (borderRadius == BorderRadius.zero) {
      return RepaintBoundary(child: content);
    }

    return RepaintBoundary(
      child: ClipRRect(borderRadius: borderRadius, child: content),
    );
  }
}

class _ImageShimmer extends StatefulWidget {
  const _ImageShimmer();

  @override
  State<_ImageShimmer> createState() => _ImageShimmerState();
}

class _ImageShimmerState extends State<_ImageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.2 + (_controller.value * 2.4), -0.4),
              end: Alignment(0.2 + (_controller.value * 2.4), 0.4),
              colors: const [
                Color(0xFFE7DDCF),
                Color(0xFFF9F2E8),
                Color(0xFFE7DDCF),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9DFC8),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 42,
        color: Color(0xFF9E8F7A),
      ),
    );
  }
}

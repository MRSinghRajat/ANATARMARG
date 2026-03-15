import 'dart:ui' show BlendMode;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/services/compressed_image_cache.dart';

/// URLs that have already failed to load. Once in this set, we show fallback
/// and never retry (avoids continuous fetch loops for missing covers).
final Set<String> _failedImageUrls = {};

/// Network image with compressed disk cache (max 1024px, bounded size).
/// Uses CachedNetworkImage + maxWidthDiskCache/maxHeightDiskCache so stored images are resized.
/// When [cacheFailure] is true, a failed load is remembered and [fallback] is shown on
/// subsequent builds without retrying the URL.
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  /// When true, failed URLs are not retried; [fallback] is shown instead.
  final bool cacheFailure;
  /// Shown when load fails (and when [cacheFailure] and URL was already known to fail).
  final Widget? fallback;

  /// Max size of cached image on disk (keeps storage low). Default 1024.
  static const int maxDiskCacheSize = 1024;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.errorBuilder,
    this.cacheFailure = false,
    this.fallback,
  });

  Widget _buildErrorWidget(BuildContext context, Object? error) {
    if (fallback != null) return fallback!;
    final custom = errorBuilder?.call(context, error ?? Object(), null);
    if (custom != null) return custom;
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Image.asset(
          AppConfig.appLogoPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF1A1510)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cacheFailure && _failedImageUrls.contains(imageUrl)) {
      return _buildErrorWidget(context, null);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      maxWidthDiskCache: maxDiskCacheSize,
      maxHeightDiskCache: maxDiskCacheSize,
      cacheManager: CompressedImageCache.instance.cacheManager,
      placeholder: (_, __) => Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Image.asset(
            AppConfig.appLogoPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      errorWidget: (_, __, error) {
        if (cacheFailure) _failedImageUrls.add(imageUrl);
        return _buildErrorWidget(context, error);
      },
    );
  }
}

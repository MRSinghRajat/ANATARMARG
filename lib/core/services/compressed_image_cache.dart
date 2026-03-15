import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Bounded image cache that stores images **compressed** (resized to max 1024px).
/// Use with CachedNetworkImage + maxWidthDiskCache/maxHeightDiskCache so disk cache stays small.
class CompressedImageCache {
  CompressedImageCache._();
  static final CompressedImageCache instance = CompressedImageCache._();

  static const String _cacheKey = 'antarmargImages';

  /// Bounded + ImageCacheManager so we can use maxWidthDiskCache/maxHeightDiskCache.
  /// Max 100 files, evict after 7 days. Actual stored size is reduced by resize (1024px).
  late final CacheManager cacheManager = _BoundedImageCacheManager();

  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    CachedNetworkImageProvider.defaultCacheManager = cacheManager;
  }

  Future<void> clearCache() async {
    await cacheManager.emptyCache();
    await DefaultCacheManager().emptyCache();
  }
}

/// Bounded cache with ImageCacheManager so disk cache stores resized (compressed) images.
class _BoundedImageCacheManager extends CacheManager with ImageCacheManager {
  _BoundedImageCacheManager()
      : super(
          Config(
            'antarmargImages',
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 100,
          ),
        );
}

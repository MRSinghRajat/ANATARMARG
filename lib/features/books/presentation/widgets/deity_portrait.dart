import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_network_image.dart';

/// Bundled deity art in `assets/images/deities/{slug}.webp`.
/// Keep in sync with files on disk and with Aangan [deityConfigs].
const kBundledDeitySlugs = <String>{
  'durga',
  'ganesha',
  'hanuman',
  'indra',
  'kartikeya',
  'krishna',
  'lakshmi',
  'narasimha',
  'rama',
  'saraswati',
  'shiva',
  'vishnu',
};

String? bundledDeityAssetPath(String? slug) {
  if (slug == null || slug.isEmpty) return null;
  final id = slug.trim().toLowerCase();
  if (!kBundledDeitySlugs.contains(id)) return null;
  return 'assets/images/deities/$id.webp';
}

/// Network portrait with a bundled-asset fallback when URL is empty or fails.
class DeityPortrait extends StatelessWidget {
  const DeityPortrait({
    super.key,
    this.imageUrl,
    this.slug,
    this.fit = BoxFit.cover,
    this.color,
    this.colorBlendMode,
    this.fallback,
  });

  final String? imageUrl;
  final String? slug;
  final BoxFit fit;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final asset = bundledDeityAssetPath(slug);
    final assetImage = asset == null
        ? null
        : Image.asset(
            asset,
            fit: fit,
            color: color,
            colorBlendMode: colorBlendMode,
          );
    final url = imageUrl?.trim() ?? '';
    if (url.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: url,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        fallback: assetImage ?? fallback,
        errorBuilder: (_, __, ___) => assetImage ?? fallback ?? const SizedBox.shrink(),
      );
    }
    return assetImage ?? fallback ?? const SizedBox.shrink();
  }
}

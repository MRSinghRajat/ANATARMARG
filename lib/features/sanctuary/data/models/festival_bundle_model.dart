import 'package:flutter/material.dart';
import 'sanctuary_customization_model.dart';

/// Time-of-day / mood for festival background (replaces default morning aurora).
enum FestivalTimeOfDay {
  morning,
  day,
  evening,
  night,
}

/// Type of overlay animation for the festival.
enum FestivalEffectType {
  none,
  holiSplash,    // Colorful splashes, swirls, daytime
  diwaliLights,  // Diya glow, sparkles, cracker bursts
  ganesh,        // Modak motifs, gentle bokeh
  navratri,      // Dandiya colors, rhythmic glow
  sankranti,     // Kite shapes, sky blue
  eid,           // Crescent, stars, night
}

/// One premium festival bundle: theme + motion + effects combined.
class FestivalBundle {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final bool isPremium;
  final FestivalTimeOfDay timeOfDay;
  final List<Color> primaryColors;
  final SanctuaryCustomization customizationOverride;
  final FestivalEffectType effectType;

  const FestivalBundle({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    this.isPremium = true,
    required this.timeOfDay,
    required this.primaryColors,
    required this.customizationOverride,
    required this.effectType,
  });
}

/// All predefined Indian festival bundles for Aangan.
class FestivalBundles {
  static const List<FestivalBundle> all = [
    holi,
    diwali,
    ganeshChaturthi,
    navratri,
    makarSankranti,
    eid,
  ];

  /// Holi: Colorful Om, colored splash/swirl, daytime UI.
  static const FestivalBundle holi = FestivalBundle(
    id: 'holi',
    name: 'Holi',
    emoji: '🎨',
    description: 'Colourful Om, splash swirl & daytime',
    isPremium: true,
    timeOfDay: FestivalTimeOfDay.day,
    primaryColors: [
      Color(0xFFFF6B6B), // red
      Color(0xFF4ECDC4), // teal
      Color(0xFFFFE66D), // yellow
      Color(0xFF95E1D3), // mint
      Color(0xFFDDA0DD), // plum
    ],
    customizationOverride: SanctuaryCustomization(
      omStyle: OmStyle.watercolor,
      ringColor: RingColor.rainbow,
      animationStyle: SanctuaryAnimationStyle.pulse,
      backgroundStyle: BackgroundStyle.cosmicGradient,
      glowColor: GlowColor.multicolor,
      particleStyle: ParticleStyle.sparkles,
    ),
    effectType: FestivalEffectType.holiSplash,
  );

  /// Diwali: Lighting effect in Om, sparkles, crackers animation.
  static const FestivalBundle diwali = FestivalBundle(
    id: 'diwali',
    name: 'Diwali',
    emoji: '🪔',
    description: 'Diya glow, sparkles & crackers',
    isPremium: true,
    timeOfDay: FestivalTimeOfDay.evening,
    primaryColors: [
      Color(0xFFFFD700), // gold
      Color(0xFFFFA500), // orange
      Color(0xFFF4C430), // saffron
      Color(0xFF1A0A0A), // dark
    ],
    customizationOverride: SanctuaryCustomization(
      omStyle: OmStyle.diya,
      ringColor: RingColor.gold,
      animationStyle: SanctuaryAnimationStyle.pulse,
      backgroundStyle: BackgroundStyle.cosmicGradient,
      glowColor: GlowColor.gold,
      particleStyle: ParticleStyle.sparkles,
      specialEffect: SpecialEffect.divineLight,
    ),
    effectType: FestivalEffectType.diwaliLights,
  );

  /// Ganesh Chaturthi: Modak motifs, gentle bokeh.
  static const FestivalBundle ganeshChaturthi = FestivalBundle(
    id: 'ganesh',
    name: 'Ganesh Chaturthi',
    emoji: '🐘',
    description: 'Modak motifs & gentle glow',
    isPremium: true,
    timeOfDay: FestivalTimeOfDay.day,
    primaryColors: [
      Color(0xFFE8D5B7),
      Color(0xFFD4AF37),
      Color(0xFF8B4513),
    ],
    customizationOverride: SanctuaryCustomization(
      omStyle: OmStyle.ornate,
      ringColor: RingColor.gold,
      animationStyle: SanctuaryAnimationStyle.gentle,
      glowColor: GlowColor.gold,
    ),
    effectType: FestivalEffectType.ganesh,
  );

  /// Navratri: Dandiya colors, rhythmic glow.
  static const FestivalBundle navratri = FestivalBundle(
    id: 'navratri',
    name: 'Navratri',
    emoji: '🕉️',
    description: 'Dandiya colours & rhythmic glow',
    isPremium: true,
    timeOfDay: FestivalTimeOfDay.evening,
    primaryColors: [
      Color(0xFF800080), // purple
      Color(0xFFFF00FF), // fuchsia
      Color(0xFF4B0082), // indigo
    ],
    customizationOverride: SanctuaryCustomization(
      omStyle: OmStyle.divine,
      ringColor: RingColor.purple,
      animationStyle: SanctuaryAnimationStyle.pulse,
      glowColor: GlowColor.purple,
    ),
    effectType: FestivalEffectType.navratri,
  );

  /// Makar Sankranti: Kites, sky blue.
  static const FestivalBundle makarSankranti = FestivalBundle(
    id: 'sankranti',
    name: 'Makar Sankranti',
    emoji: '🪁',
    description: 'Kite shapes & sky blue',
    isPremium: true,
    timeOfDay: FestivalTimeOfDay.day,
    primaryColors: [
      Color(0xFF87CEEB), // sky blue
      Color(0xFFFFD700), // yellow
      Color(0xFFF4A460), // sandy
    ],
    customizationOverride: SanctuaryCustomization(
      omStyle: OmStyle.aurora,
      ringColor: RingColor.sapphire,
      animationStyle: SanctuaryAnimationStyle.gentle,
      glowColor: GlowColor.blue,
    ),
    effectType: FestivalEffectType.sankranti,
  );

  /// Eid: Crescent, stars, night.
  static const FestivalBundle eid = FestivalBundle(
    id: 'eid',
    name: 'Eid',
    emoji: '🌙',
    description: 'Crescent, stars & night sky',
    isPremium: true,
    timeOfDay: FestivalTimeOfDay.night,
    primaryColors: [
      Color(0xFF2C3E50),
      Color(0xFF3498DB),
      Color(0xFFECF0F1),
    ],
    customizationOverride: SanctuaryCustomization(
      omStyle: OmStyle.ethereal,
      ringColor: RingColor.silver,
      animationStyle: SanctuaryAnimationStyle.meditative,
      backgroundStyle: BackgroundStyle.cosmicGradient,
      glowColor: GlowColor.white,
    ),
    effectType: FestivalEffectType.eid,
  );

  static FestivalBundle? byId(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

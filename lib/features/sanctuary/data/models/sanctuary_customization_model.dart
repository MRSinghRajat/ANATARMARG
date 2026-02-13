import 'package:flutter/material.dart';

/// Represents all customization options for the Om Sanctuary.
/// This is used in both Aangan (customization hub) and Ashram (display).
class SanctuaryCustomization {
  final OmStyle omStyle;
  final RingStyle ringStyle;
  final RingColor ringColor;
  final SanctuaryAnimationStyle animationStyle;
  final BackgroundStyle backgroundStyle;
  final GlowColor glowColor;
  final DeityImage? deityImage;
  final FrameStyle frameStyle;
  final SpecialEffect specialEffect;
  final ParticleStyle particleStyle;

  const SanctuaryCustomization({
    this.omStyle = OmStyle.classic,
    this.ringStyle = RingStyle.singleRing,
    this.ringColor = RingColor.gold,
    this.animationStyle = SanctuaryAnimationStyle.gentle,
    this.backgroundStyle = BackgroundStyle.geometricLines,
    this.glowColor = GlowColor.gold,
    this.deityImage,
    this.frameStyle = FrameStyle.none,
    this.specialEffect = SpecialEffect.none,
    this.particleStyle = ParticleStyle.none,
  });

  /// Default configuration for new users
  static const SanctuaryCustomization defaultConfig = SanctuaryCustomization();

  Map<String, dynamic> toJson() => {
    'omStyle': omStyle.name,
    'ringStyle': ringStyle.name,
    'ringColor': ringColor.name,
    'animationStyle': animationStyle.name,
    'backgroundStyle': backgroundStyle.name,
    'glowColor': glowColor.name,
    'deityImage': deityImage?.name,
    'frameStyle': frameStyle.name,
    'specialEffect': specialEffect.name,
    'particleStyle': particleStyle.name,
  };

  factory SanctuaryCustomization.fromJson(Map<String, dynamic> json) {
    return SanctuaryCustomization(
      omStyle: OmStyle.values.firstWhere(
        (e) => e.name == json['omStyle'],
        orElse: () => OmStyle.classic,
      ),
      ringStyle: RingStyle.values.firstWhere(
        (e) => e.name == json['ringStyle'],
        orElse: () => RingStyle.singleRing,
      ),
      ringColor: RingColor.values.firstWhere(
        (e) => e.name == json['ringColor'],
        orElse: () => RingColor.gold,
      ),
      animationStyle: SanctuaryAnimationStyle.values.firstWhere(
        (e) => e.name == json['animationStyle'],
        orElse: () => SanctuaryAnimationStyle.gentle,
      ),
      backgroundStyle: BackgroundStyle.values.firstWhere(
        (e) => e.name == json['backgroundStyle'],
        orElse: () => BackgroundStyle.geometricLines,
      ),
      glowColor: GlowColor.values.firstWhere(
        (e) => e.name == json['glowColor'],
        orElse: () => GlowColor.gold,
      ),
      deityImage: json['deityImage'] != null
          ? DeityImage.values.firstWhere(
              (e) => e.name == json['deityImage'],
              orElse: () => DeityImage.ganesha,
            )
          : null,
      frameStyle: FrameStyle.values.firstWhere(
        (e) => e.name == json['frameStyle'],
        orElse: () => FrameStyle.none,
      ),
      specialEffect: SpecialEffect.values.firstWhere(
        (e) => e.name == json['specialEffect'],
        orElse: () => SpecialEffect.none,
      ),
      particleStyle: ParticleStyle.values.firstWhere(
        (e) => e.name == json['particleStyle'],
        orElse: () => ParticleStyle.none,
      ),
    );
  }

  SanctuaryCustomization copyWith({
    OmStyle? omStyle,
    RingStyle? ringStyle,
    RingColor? ringColor,
    SanctuaryAnimationStyle? animationStyle,
    BackgroundStyle? backgroundStyle,
    GlowColor? glowColor,
    DeityImage? deityImage,
    bool clearDeityImage = false,
    FrameStyle? frameStyle,
    SpecialEffect? specialEffect,
    ParticleStyle? particleStyle,
  }) {
    return SanctuaryCustomization(
      omStyle: omStyle ?? this.omStyle,
      ringStyle: ringStyle ?? this.ringStyle,
      ringColor: ringColor ?? this.ringColor,
      animationStyle: animationStyle ?? this.animationStyle,
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      glowColor: glowColor ?? this.glowColor,
      deityImage: clearDeityImage ? null : (deityImage ?? this.deityImage),
      frameStyle: frameStyle ?? this.frameStyle,
      specialEffect: specialEffect ?? this.specialEffect,
      particleStyle: particleStyle ?? this.particleStyle,
    );
  }
}

// ============ ENUMS WITH METADATA ============

/// Om symbol styles
enum OmStyle {
  classic,      // Default ॐ
  satvik,       // Lighter, more elegant
  divine,       // With subtle rays
  minimalist,   // Thin strokes
  ornate,       // Decorative borders
}

extension OmStyleMeta on OmStyle {
  String get displayName {
    switch (this) {
      case OmStyle.classic: return 'Classic Om';
      case OmStyle.satvik: return 'Satvik Om';
      case OmStyle.divine: return 'Divine Om';
      case OmStyle.minimalist: return 'Minimalist';
      case OmStyle.ornate: return 'Ornate Om';
    }
  }

  String get emoji => '🕉️';

  // TODO: Add pricing later - all free for now
  int get coinCost => 0;

  ItemRarity get rarity => ItemRarity.common;

  bool get isDefault => this == OmStyle.classic;
}

/// Ring styles around the Om
enum RingStyle {
  singleRing,       // Default - one rotating ring
  doubleRing,       // Two rings rotating opposite
  tripleRing,       // Three concentric rings
  mandala,          // Intricate mandala pattern
  lotus,            // Lotus petal pattern
  cosmic,           // Dotted cosmic ring
  chakra,           // Chakra-inspired pattern
  none,             // No ring
}

extension RingStyleMeta on RingStyle {
  String get displayName {
    switch (this) {
      case RingStyle.singleRing: return 'Single Ring';
      case RingStyle.doubleRing: return 'Double Ring';
      case RingStyle.tripleRing: return 'Triple Ring';
      case RingStyle.mandala: return 'Mandala';
      case RingStyle.lotus: return 'Lotus Petals';
      case RingStyle.cosmic: return 'Cosmic Dots';
      case RingStyle.chakra: return 'Chakra Ring';
      case RingStyle.none: return 'No Ring';
    }
  }

  String get emoji {
    switch (this) {
      case RingStyle.singleRing: return '⭕';
      case RingStyle.doubleRing: return '◎';
      case RingStyle.tripleRing: return '◉';
      case RingStyle.mandala: return '❋';
      case RingStyle.lotus: return '🪷';
      case RingStyle.cosmic: return '✨';
      case RingStyle.chakra: return '☸️';
      case RingStyle.none: return '○';
    }
  }

  // TODO: Add pricing later - all free for now
  int get coinCost => 0;

  ItemRarity get rarity => ItemRarity.common;

  bool get isDefault => this == RingStyle.singleRing;
}

/// Ring/accent colors
enum RingColor {
  gold,         // Default - warm gold
  silver,       // Cool silver
  saffron,      // Traditional saffron
  teal,         // Spiritual teal
  purple,       // Royal purple
  rose,         // Rose gold
  emerald,      // Emerald green
  rainbow,      // Rainbow gradient
}

extension RingColorMeta on RingColor {
  String get displayName {
    switch (this) {
      case RingColor.gold: return 'Divine Gold';
      case RingColor.silver: return 'Moon Silver';
      case RingColor.saffron: return 'Sacred Saffron';
      case RingColor.teal: return 'Ocean Teal';
      case RingColor.purple: return 'Royal Purple';
      case RingColor.rose: return 'Rose Gold';
      case RingColor.emerald: return 'Emerald';
      case RingColor.rainbow: return 'Rainbow';
    }
  }

  String get emoji {
    switch (this) {
      case RingColor.gold: return '🌟';
      case RingColor.silver: return '🌙';
      case RingColor.saffron: return '🧡';
      case RingColor.teal: return '💎';
      case RingColor.purple: return '💜';
      case RingColor.rose: return '🌸';
      case RingColor.emerald: return '💚';
      case RingColor.rainbow: return '🌈';
    }
  }

  Color get primaryColor {
    switch (this) {
      case RingColor.gold: return const Color(0xFFD4AF37);
      case RingColor.silver: return const Color(0xFFC0C0C0);
      case RingColor.saffron: return const Color(0xFFFF9933);
      case RingColor.teal: return const Color(0xFF14B8A6);
      case RingColor.purple: return const Color(0xFF9C27B0);
      case RingColor.rose: return const Color(0xFFE91E63);
      case RingColor.emerald: return const Color(0xFF10B981);
      case RingColor.rainbow: return const Color(0xFFD4AF37); // Base color
    }
  }

  Color get secondaryColor {
    switch (this) {
      case RingColor.gold: return const Color(0xFFF4E4B6);
      case RingColor.silver: return const Color(0xFFE8E8E8);
      case RingColor.saffron: return const Color(0xFFFFD699);
      case RingColor.teal: return const Color(0xFF5EEAD4);
      case RingColor.purple: return const Color(0xFFCE93D8);
      case RingColor.rose: return const Color(0xFFF8BBD9);
      case RingColor.emerald: return const Color(0xFF6EE7B7);
      case RingColor.rainbow: return const Color(0xFFFF6B6B);
    }
  }

  List<Color> get gradientColors {
    if (this == RingColor.rainbow) {
      return [
        const Color(0xFFFF6B6B),
        const Color(0xFFFFE66D),
        const Color(0xFF4ECB71),
        const Color(0xFF4ECDC4),
        const Color(0xFF45B7D1),
        const Color(0xFF9B59B6),
      ];
    }
    return [primaryColor, secondaryColor];
  }

  // TODO: Add pricing later - all free for now
  int get coinCost => 0;

  ItemRarity get rarity => ItemRarity.common;

  bool get isDefault => this == RingColor.gold;
}

/// Animation styles for sanctuary
enum SanctuaryAnimationStyle {
  gentle,       // Default - slow rotation
  pulse,        // Pulsing rings
  breathe,      // Breathing effect
  meditative,   // Very slow, calming
  energetic,    // Fast, dynamic
  particles,    // Floating particles
  stillness,    // No animation
}

extension SanctuaryAnimationStyleMeta on SanctuaryAnimationStyle {
  String get displayName {
    switch (this) {
      case SanctuaryAnimationStyle.gentle: return 'Gentle Flow';
      case SanctuaryAnimationStyle.pulse: return 'Sacred Pulse';
      case SanctuaryAnimationStyle.breathe: return 'Breathe';
      case SanctuaryAnimationStyle.meditative: return 'Meditative';
      case SanctuaryAnimationStyle.energetic: return 'Energetic';
      case SanctuaryAnimationStyle.particles: return 'Divine Particles';
      case SanctuaryAnimationStyle.stillness: return 'Stillness';
    }
  }

  String get emoji {
    switch (this) {
      case SanctuaryAnimationStyle.gentle: return '🌊';
      case SanctuaryAnimationStyle.pulse: return '💫';
      case SanctuaryAnimationStyle.breathe: return '🌬️';
      case SanctuaryAnimationStyle.meditative: return '🧘';
      case SanctuaryAnimationStyle.energetic: return '⚡';
      case SanctuaryAnimationStyle.particles: return '✨';
      case SanctuaryAnimationStyle.stillness: return '🪨';
    }
  }

  // TODO: Add pricing later - all free for now
  int get coinCost => 0;

  ItemRarity get rarity => ItemRarity.common;

  bool get isDefault => this == SanctuaryAnimationStyle.gentle;
}

/// Background styles
enum BackgroundStyle {
  geometricLines,   // Default - diagonal gold lines
  stars,            // Starfield
  lotusPattern,     // Subtle lotus
  cosmicGradient,   // Deep space gradient
  templeArch,       // Temple architecture
  plain,            // Solid dark
  sacredGeometry,   // Flower of life
  mountains,        // Himalayan silhouette
}

extension BackgroundStyleMeta on BackgroundStyle {
  String get displayName {
    switch (this) {
      case BackgroundStyle.geometricLines: return 'Sacred Lines';
      case BackgroundStyle.stars: return 'Starfield';
      case BackgroundStyle.lotusPattern: return 'Lotus Garden';
      case BackgroundStyle.cosmicGradient: return 'Cosmic Night';
      case BackgroundStyle.templeArch: return 'Temple';
      case BackgroundStyle.plain: return 'Minimal';
      case BackgroundStyle.sacredGeometry: return 'Sacred Geometry';
      case BackgroundStyle.mountains: return 'Himalayas';
    }
  }

  String get emoji {
    switch (this) {
      case BackgroundStyle.geometricLines: return '📐';
      case BackgroundStyle.stars: return '⭐';
      case BackgroundStyle.lotusPattern: return '🪷';
      case BackgroundStyle.cosmicGradient: return '🌌';
      case BackgroundStyle.templeArch: return '🛕';
      case BackgroundStyle.plain: return '⬛';
      case BackgroundStyle.sacredGeometry: return '✡️';
      case BackgroundStyle.mountains: return '🏔️';
    }
  }

  // TODO: Add pricing later - all free for now
  int get coinCost => 0;

  ItemRarity get rarity => ItemRarity.common;

  bool get isDefault => this == BackgroundStyle.geometricLines;
}

/// Glow/aura colors for Om
enum GlowColor {
  gold,
  white,
  saffron,
  blue,
  purple,
  multicolor,
}

extension GlowColorMeta on GlowColor {
  String get displayName {
    switch (this) {
      case GlowColor.gold: return 'Golden Aura';
      case GlowColor.white: return 'Pure Light';
      case GlowColor.saffron: return 'Saffron Glow';
      case GlowColor.blue: return 'Divine Blue';
      case GlowColor.purple: return 'Mystic Purple';
      case GlowColor.multicolor: return 'Chakra Aura';
    }
  }

  String get emoji {
    switch (this) {
      case GlowColor.gold: return '🌟';
      case GlowColor.white: return '🤍';
      case GlowColor.saffron: return '🧡';
      case GlowColor.blue: return '💙';
      case GlowColor.purple: return '💜';
      case GlowColor.multicolor: return '🌈';
    }
  }

  Color get color {
    switch (this) {
      case GlowColor.gold: return const Color(0xFFD4AF37);
      case GlowColor.white: return const Color(0xFFFFFFFF);
      case GlowColor.saffron: return const Color(0xFFFF9933);
      case GlowColor.blue: return const Color(0xFF4FC3F7);
      case GlowColor.purple: return const Color(0xFFBA68C8);
      case GlowColor.multicolor: return const Color(0xFFD4AF37);
    }
  }

  // TODO: Add pricing later - all free for now
  int get coinCost => 0;

  ItemRarity get rarity => ItemRarity.common;

  bool get isDefault => this == GlowColor.gold;
}

/// Indian deity images (premium replacements for Om)
enum DeityImage {
  ganesha,
  shiva,
  krishna,
  lakshmi,
  hanuman,
  durga,
  saraswati,
  vishnu,
}

extension DeityImageMeta on DeityImage {
  String get displayName {
    switch (this) {
      case DeityImage.ganesha: return 'Lord Ganesha';
      case DeityImage.shiva: return 'Lord Shiva';
      case DeityImage.krishna: return 'Lord Krishna';
      case DeityImage.lakshmi: return 'Goddess Lakshmi';
      case DeityImage.hanuman: return 'Lord Hanuman';
      case DeityImage.durga: return 'Goddess Durga';
      case DeityImage.saraswati: return 'Goddess Saraswati';
      case DeityImage.vishnu: return 'Lord Vishnu';
    }
  }

  String get emoji {
    switch (this) {
      case DeityImage.ganesha: return '🐘';
      case DeityImage.shiva: return '🔱';
      case DeityImage.krishna: return '🦚';
      case DeityImage.lakshmi: return '🪷';
      case DeityImage.hanuman: return '🐒';
      case DeityImage.durga: return '🦁';
      case DeityImage.saraswati: return '🎸';
      case DeityImage.vishnu: return '🪈';
    }
  }

  String get description {
    switch (this) {
      case DeityImage.ganesha: return 'Remover of obstacles';
      case DeityImage.shiva: return 'The destroyer and transformer';
      case DeityImage.krishna: return 'The divine playful one';
      case DeityImage.lakshmi: return 'Goddess of wealth and prosperity';
      case DeityImage.hanuman: return 'Symbol of strength and devotion';
      case DeityImage.durga: return 'The invincible one';
      case DeityImage.saraswati: return 'Goddess of knowledge and arts';
      case DeityImage.vishnu: return 'The preserver';
    }
  }

  // TODO: Add pricing later - all free for now
  int get coinCost => 0;

  // Keep legendary rarity for display purposes
  ItemRarity get rarity => ItemRarity.legendary;

  bool get isDefault => false;
}

/// Frame styles - different shapes beyond circles
enum FrameStyle {
  none,           // No frame
  hexagon,        // Hexagonal frame
  octagon,        // Octagonal frame
  diamond,        // Diamond/rhombus shape
  lotus,          // Lotus flower frame
  yantra,         // Sri Yantra inspired
  sun,            // Sun rays frame
  moon,           // Crescent moon frame
  temple,         // Temple arch frame
  tribal,         // Tribal/ethnic patterns
}

extension FrameStyleMeta on FrameStyle {
  String get displayName {
    switch (this) {
      case FrameStyle.none: return 'No Frame';
      case FrameStyle.hexagon: return 'Hexagon';
      case FrameStyle.octagon: return 'Octagon';
      case FrameStyle.diamond: return 'Diamond';
      case FrameStyle.lotus: return 'Lotus Frame';
      case FrameStyle.yantra: return 'Sri Yantra';
      case FrameStyle.sun: return 'Sun Rays';
      case FrameStyle.moon: return 'Crescent Moon';
      case FrameStyle.temple: return 'Temple Arch';
      case FrameStyle.tribal: return 'Tribal Pattern';
    }
  }

  String get emoji {
    switch (this) {
      case FrameStyle.none: return '○';
      case FrameStyle.hexagon: return '⬡';
      case FrameStyle.octagon: return '⯃';
      case FrameStyle.diamond: return '◇';
      case FrameStyle.lotus: return '🪷';
      case FrameStyle.yantra: return '✡️';
      case FrameStyle.sun: return '☀️';
      case FrameStyle.moon: return '🌙';
      case FrameStyle.temple: return '🛕';
      case FrameStyle.tribal: return '🔶';
    }
  }

  // TODO: Add pricing later - all free for now
  int get coinCost => 0;

  ItemRarity get rarity => ItemRarity.common;

  bool get isDefault => this == FrameStyle.none;
}

/// Special effects that add unique visual elements
enum SpecialEffect {
  none,           // No effect
  fireAura,       // Flames around the Om
  waterRipples,   // Water ripple effect
  lightningBolts, // Electric sparks
  divineLight,    // Rays of divine light
  cosmicSwirl,    // Galaxy swirl effect
  floatingPetals, // Floating flower petals
  holySmoke,      // Incense smoke effect
  chakraGlow,     // 7 chakra colors cycling
  goldenShower,   // Golden light particles falling
  auraWaves,      // Pulsing aura waves
}

extension SpecialEffectMeta on SpecialEffect {
  String get displayName {
    switch (this) {
      case SpecialEffect.none: return 'No Effect';
      case SpecialEffect.fireAura: return 'Fire Aura';
      case SpecialEffect.waterRipples: return 'Water Ripples';
      case SpecialEffect.lightningBolts: return 'Lightning';
      case SpecialEffect.divineLight: return 'Divine Light';
      case SpecialEffect.cosmicSwirl: return 'Cosmic Swirl';
      case SpecialEffect.floatingPetals: return 'Flower Petals';
      case SpecialEffect.holySmoke: return 'Holy Smoke';
      case SpecialEffect.chakraGlow: return 'Chakra Glow';
      case SpecialEffect.goldenShower: return 'Golden Shower';
      case SpecialEffect.auraWaves: return 'Aura Waves';
    }
  }

  String get emoji {
    switch (this) {
      case SpecialEffect.none: return '○';
      case SpecialEffect.fireAura: return '🔥';
      case SpecialEffect.waterRipples: return '💧';
      case SpecialEffect.lightningBolts: return '⚡';
      case SpecialEffect.divineLight: return '✨';
      case SpecialEffect.cosmicSwirl: return '🌀';
      case SpecialEffect.floatingPetals: return '🌸';
      case SpecialEffect.holySmoke: return '💨';
      case SpecialEffect.chakraGlow: return '🌈';
      case SpecialEffect.goldenShower: return '🌟';
      case SpecialEffect.auraWaves: return '〰️';
    }
  }

  // TODO: Add pricing later - all free for now
  int get coinCost => 0;

  ItemRarity get rarity => ItemRarity.rare;

  bool get isDefault => this == SpecialEffect.none;
}

/// Particle styles - floating elements around the sanctuary
enum ParticleStyle {
  none,           // No particles
  stars,          // Twinkling stars
  fireflies,      // Glowing fireflies
  sakura,         // Cherry blossom petals
  snow,           // Gentle snowfall
  embers,         // Floating embers
  bubbles,        // Mystical bubbles
  leaves,         // Autumn leaves
  sparkles,       // Magic sparkles
  orbs,           // Floating light orbs
  feathers,       // Divine feathers
}

extension ParticleStyleMeta on ParticleStyle {
  String get displayName {
    switch (this) {
      case ParticleStyle.none: return 'No Particles';
      case ParticleStyle.stars: return 'Stars';
      case ParticleStyle.fireflies: return 'Fireflies';
      case ParticleStyle.sakura: return 'Cherry Blossoms';
      case ParticleStyle.snow: return 'Snowfall';
      case ParticleStyle.embers: return 'Embers';
      case ParticleStyle.bubbles: return 'Bubbles';
      case ParticleStyle.leaves: return 'Autumn Leaves';
      case ParticleStyle.sparkles: return 'Sparkles';
      case ParticleStyle.orbs: return 'Light Orbs';
      case ParticleStyle.feathers: return 'Feathers';
    }
  }

  String get emoji {
    switch (this) {
      case ParticleStyle.none: return '○';
      case ParticleStyle.stars: return '⭐';
      case ParticleStyle.fireflies: return '🪲';
      case ParticleStyle.sakura: return '🌸';
      case ParticleStyle.snow: return '❄️';
      case ParticleStyle.embers: return '🔥';
      case ParticleStyle.bubbles: return '🫧';
      case ParticleStyle.leaves: return '🍂';
      case ParticleStyle.sparkles: return '✨';
      case ParticleStyle.orbs: return '🔮';
      case ParticleStyle.feathers: return '🪶';
    }
  }

  // TODO: Add pricing later - all free for now
  int get coinCost => 0;

  ItemRarity get rarity => ItemRarity.common;

  bool get isDefault => this == ParticleStyle.none;
}

/// Item rarity levels
enum ItemRarity {
  common,
  rare,
  epic,
  legendary,
}

extension ItemRarityMeta on ItemRarity {
  String get displayName {
    switch (this) {
      case ItemRarity.common: return 'Common';
      case ItemRarity.rare: return 'Rare';
      case ItemRarity.epic: return 'Epic';
      case ItemRarity.legendary: return 'Legendary';
    }
  }

  Color get color {
    switch (this) {
      case ItemRarity.common: return const Color(0xFF9E9E9E);
      case ItemRarity.rare: return const Color(0xFF2196F3);
      case ItemRarity.epic: return const Color(0xFF9C27B0);
      case ItemRarity.legendary: return const Color(0xFFFFD700);
    }
  }
}

/// Customization category for shop tabs
enum CustomizationCategory {
  omStyles,
  ringStyles,
  ringColors,
  frameStyles,
  animations,
  backgrounds,
  glowColors,
  specialEffects,
  particles,
  deityImages,
}

extension CustomizationCategoryMeta on CustomizationCategory {
  String get displayName {
    switch (this) {
      case CustomizationCategory.omStyles: return 'Om';
      case CustomizationCategory.ringStyles: return 'Rings';
      case CustomizationCategory.ringColors: return 'Colors';
      case CustomizationCategory.frameStyles: return 'Frames';
      case CustomizationCategory.animations: return 'Motion';
      case CustomizationCategory.backgrounds: return 'BG';
      case CustomizationCategory.glowColors: return 'Glow';
      case CustomizationCategory.specialEffects: return 'Effects';
      case CustomizationCategory.particles: return 'Particles';
      case CustomizationCategory.deityImages: return 'Deities';
    }
  }

  String get emoji {
    switch (this) {
      case CustomizationCategory.omStyles: return '🕉️';
      case CustomizationCategory.ringStyles: return '⭕';
      case CustomizationCategory.ringColors: return '🎨';
      case CustomizationCategory.frameStyles: return '⬡';
      case CustomizationCategory.animations: return '✨';
      case CustomizationCategory.backgrounds: return '🖼️';
      case CustomizationCategory.glowColors: return '💫';
      case CustomizationCategory.specialEffects: return '🔥';
      case CustomizationCategory.particles: return '⭐';
      case CustomizationCategory.deityImages: return '🙏';
    }
  }
}

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

/// Center symbol styles — Om and beyond
enum OmStyle {
  // --- OM STYLES ---
  classic,      // Default ॐ
  satvik,       // Lighter, more elegant ॐ
  divine,       // With subtle rays ॐ
  minimalist,   // Thin strokes ॐ
  ornate,       // Decorative borders ॐ
  neon,         // Glowing neon outline ॐ
  galaxy,       // Starfield filled ॐ
  golden3d,     // Embossed 3D gold ॐ
  flame,        // Fire-outlined ॐ
  crystal,      // Ice crystal style ॐ
  zen,          // Zen calligraphy ॐ
  shadow,       // Deep layered shadow ॐ
  holographic,  // Rainbow shimmer ॐ
  runic,        // Ancient script ॐ
  watercolor,   // Soft watercolor bleed ॐ
  glitch,       // Digital glitch ॐ
  aurora,       // Northern lights fill ॐ
  voidStyle,    // Dark with bright outline ॐ
  sacred,       // Decorated with dots ॐ
  cosmic,       // Space nebula fill ॐ
  matrix,       // Digital rain ॐ
  ethereal,     // Semi-transparent ghostly ॐ
  tribal,       // Bold tribal strokes ॐ
  chakraOm,     // 7 chakra colored ॐ
  lotusOm,      // Om emerging from lotus ॐ
  // --- SACRED SYMBOLS ---
  swastik,      // Sacred Swastik 卐
  trishul,      // Shiva's Trishul 🔱
  shriSymbol,   // Shri / श्री
  rangoli,      // Rangoli flower ✿
  lotusSymbol,  // Lotus 🪷
  kalash,       // Sacred pot ≋
  damaru,       // Damaru drum ⏃
  shankha,      // Conch shell ☊
  sudarshan,    // Sudarshan Chakra ☸
  diya,         // Diya lamp 🪔
  namaste,      // Namaste 🙏
  aum,          // AUM text
  mandalaSymbol, // Mandala ❋
  yantraSymbol, // Sri Yantra ✡
  bindu,        // Sacred dot ●
}

extension OmStyleMeta on OmStyle {
  String get displayName {
    switch (this) {
      case OmStyle.classic: return 'Classic Om';
      case OmStyle.satvik: return 'Satvik Om';
      case OmStyle.divine: return 'Divine Om';
      case OmStyle.minimalist: return 'Minimalist';
      case OmStyle.ornate: return 'Ornate Om';
      case OmStyle.neon: return 'Neon Glow';
      case OmStyle.galaxy: return 'Galaxy';
      case OmStyle.golden3d: return 'Golden 3D';
      case OmStyle.flame: return 'Flame Om';
      case OmStyle.crystal: return 'Crystal';
      case OmStyle.zen: return 'Zen';
      case OmStyle.shadow: return 'Shadow';
      case OmStyle.holographic: return 'Holographic';
      case OmStyle.runic: return 'Runic';
      case OmStyle.watercolor: return 'Watercolor';
      case OmStyle.glitch: return 'Glitch';
      case OmStyle.aurora: return 'Aurora';
      case OmStyle.voidStyle: return 'Void';
      case OmStyle.sacred: return 'Sacred';
      case OmStyle.cosmic: return 'Cosmic';
      case OmStyle.matrix: return 'Matrix';
      case OmStyle.ethereal: return 'Ethereal';
      case OmStyle.tribal: return 'Tribal';
      case OmStyle.chakraOm: return 'Chakra Om';
      case OmStyle.lotusOm: return 'Lotus Om';
      // Sacred Symbols
      case OmStyle.swastik: return 'Swastik';
      case OmStyle.trishul: return 'Trishul';
      case OmStyle.shriSymbol: return 'Shri';
      case OmStyle.rangoli: return 'Rangoli';
      case OmStyle.lotusSymbol: return 'Lotus';
      case OmStyle.kalash: return 'Kalash';
      case OmStyle.damaru: return 'Damaru';
      case OmStyle.shankha: return 'Shankha';
      case OmStyle.sudarshan: return 'Sudarshan';
      case OmStyle.diya: return 'Diya';
      case OmStyle.namaste: return 'Namaste';
      case OmStyle.aum: return 'AUM';
      case OmStyle.mandalaSymbol: return 'Mandala';
      case OmStyle.yantraSymbol: return 'Yantra';
      case OmStyle.bindu: return 'Bindu';
    }
  }

  String get emoji {
    switch (this) {
      case OmStyle.classic: return '🕉️';
      case OmStyle.satvik: return '🙏';
      case OmStyle.divine: return '✨';
      case OmStyle.minimalist: return '〰️';
      case OmStyle.ornate: return '👑';
      case OmStyle.neon: return '💡';
      case OmStyle.galaxy: return '🌌';
      case OmStyle.golden3d: return '🏆';
      case OmStyle.flame: return '🔥';
      case OmStyle.crystal: return '❄️';
      case OmStyle.zen: return '🎋';
      case OmStyle.shadow: return '🌑';
      case OmStyle.holographic: return '🌈';
      case OmStyle.runic: return '📜';
      case OmStyle.watercolor: return '🎨';
      case OmStyle.glitch: return '⚡';
      case OmStyle.aurora: return '🌅';
      case OmStyle.voidStyle: return '🕳️';
      case OmStyle.sacred: return '📿';
      case OmStyle.cosmic: return '🪐';
      case OmStyle.matrix: return '💻';
      case OmStyle.ethereal: return '👻';
      case OmStyle.tribal: return '🗿';
      case OmStyle.chakraOm: return '🧘';
      case OmStyle.lotusOm: return '🪷';
      // Sacred Symbols
      case OmStyle.swastik: return '卐';
      case OmStyle.trishul: return '🔱';
      case OmStyle.shriSymbol: return '🙏';
      case OmStyle.rangoli: return '✿';
      case OmStyle.lotusSymbol: return '🪷';
      case OmStyle.kalash: return '🏺';
      case OmStyle.damaru: return '🥁';
      case OmStyle.shankha: return '🐚';
      case OmStyle.sudarshan: return '☸️';
      case OmStyle.diya: return '🪔';
      case OmStyle.namaste: return '🙏';
      case OmStyle.aum: return '🕉️';
      case OmStyle.mandalaSymbol: return '❋';
      case OmStyle.yantraSymbol: return '✡️';
      case OmStyle.bindu: return '⦿';
    }
  }

  /// The actual text symbol to render in the center
  String get symbol {
    switch (this) {
      case OmStyle.swastik: return '卐';
      case OmStyle.trishul: return '🔱';
      case OmStyle.shriSymbol: return 'श्री';
      case OmStyle.rangoli: return '✿';
      case OmStyle.lotusSymbol: return '🪷';
      case OmStyle.kalash: return '🏺';
      case OmStyle.damaru: return '⏃';
      case OmStyle.shankha: return '🐚';
      case OmStyle.sudarshan: return '☸';
      case OmStyle.diya: return '🪔';
      case OmStyle.namaste: return '🙏';
      case OmStyle.aum: return 'ॐ'; // Same char, styled as AUM calligraphy
      case OmStyle.mandalaSymbol: return '❋';
      case OmStyle.yantraSymbol: return '✡';
      case OmStyle.bindu: return '●';
      default: return 'ॐ'; // All Om-based styles use the Om character
    }
  }

  int get coinCost => 0;

  ItemRarity get rarity {
    switch (this) {
      case OmStyle.classic:
      case OmStyle.satvik:
      case OmStyle.divine:
      case OmStyle.minimalist:
      case OmStyle.ornate:
        return ItemRarity.common;
      case OmStyle.neon:
      case OmStyle.zen:
      case OmStyle.shadow:
      case OmStyle.sacred:
      case OmStyle.watercolor:
      case OmStyle.tribal:
      case OmStyle.swastik:
      case OmStyle.rangoli:
      case OmStyle.lotusSymbol:
      case OmStyle.bindu:
      case OmStyle.namaste:
        return ItemRarity.rare;
      case OmStyle.galaxy:
      case OmStyle.golden3d:
      case OmStyle.crystal:
      case OmStyle.holographic:
      case OmStyle.aurora:
      case OmStyle.cosmic:
      case OmStyle.ethereal:
      case OmStyle.trishul:
      case OmStyle.shriSymbol:
      case OmStyle.kalash:
      case OmStyle.diya:
      case OmStyle.aum:
      case OmStyle.mandalaSymbol:
        return ItemRarity.epic;
      case OmStyle.flame:
      case OmStyle.runic:
      case OmStyle.glitch:
      case OmStyle.voidStyle:
      case OmStyle.matrix:
      case OmStyle.chakraOm:
      case OmStyle.lotusOm:
      case OmStyle.damaru:
      case OmStyle.shankha:
      case OmStyle.sudarshan:
      case OmStyle.yantraSymbol:
        return ItemRarity.legendary;
    }
  }

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
  fibonacci,        // Fibonacci spiral
  dna,              // Double helix
  galaxy,           // Galaxy spiral
  zodiac,           // Zodiac symbols
  waves,            // Sound wave rings
  fire,             // Fire ring
  auroraRing,       // Northern lights ring
  infinity,         // Figure-8 path
  sacred,           // Flower of life
  pulseRing,        // Pulsing dots
  orbit,            // Orbital paths
  prism,            // Prism light refraction
  quantum,          // Quantum dots
  tornado,          // Spiral tornado
  ripple,           // Water ripple rings
  constellation,    // Star connections
  matrixRing,       // Digital code ring
  diamond,          // Diamond facets
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
      case RingStyle.fibonacci: return 'Fibonacci';
      case RingStyle.dna: return 'DNA Helix';
      case RingStyle.galaxy: return 'Galaxy Spiral';
      case RingStyle.zodiac: return 'Zodiac';
      case RingStyle.waves: return 'Sound Waves';
      case RingStyle.fire: return 'Fire Ring';
      case RingStyle.auroraRing: return 'Aurora Ring';
      case RingStyle.infinity: return 'Infinity';
      case RingStyle.sacred: return 'Flower of Life';
      case RingStyle.pulseRing: return 'Pulse Dots';
      case RingStyle.orbit: return 'Orbital';
      case RingStyle.prism: return 'Prism';
      case RingStyle.quantum: return 'Quantum';
      case RingStyle.tornado: return 'Tornado';
      case RingStyle.ripple: return 'Ripple';
      case RingStyle.constellation: return 'Constellation';
      case RingStyle.matrixRing: return 'Matrix';
      case RingStyle.diamond: return 'Diamond';
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
      case RingStyle.fibonacci: return '🐚';
      case RingStyle.dna: return '🧬';
      case RingStyle.galaxy: return '🌀';
      case RingStyle.zodiac: return '♈';
      case RingStyle.waves: return '🌊';
      case RingStyle.fire: return '🔥';
      case RingStyle.auroraRing: return '🌅';
      case RingStyle.infinity: return '♾️';
      case RingStyle.sacred: return '✡️';
      case RingStyle.pulseRing: return '💫';
      case RingStyle.orbit: return '🪐';
      case RingStyle.prism: return '🔷';
      case RingStyle.quantum: return '⚛️';
      case RingStyle.tornado: return '🌪️';
      case RingStyle.ripple: return '💧';
      case RingStyle.constellation: return '⭐';
      case RingStyle.matrixRing: return '💻';
      case RingStyle.diamond: return '💎';
    }
  }

  int get coinCost => 0;

  ItemRarity get rarity {
    switch (this) {
      case RingStyle.singleRing:
      case RingStyle.doubleRing:
      case RingStyle.tripleRing:
      case RingStyle.none:
      case RingStyle.ripple:
      case RingStyle.waves:
        return ItemRarity.common;
      case RingStyle.mandala:
      case RingStyle.lotus:
      case RingStyle.cosmic:
      case RingStyle.chakra:
      case RingStyle.pulseRing:
      case RingStyle.orbit:
      case RingStyle.diamond:
        return ItemRarity.rare;
      case RingStyle.fibonacci:
      case RingStyle.dna:
      case RingStyle.galaxy:
      case RingStyle.auroraRing:
      case RingStyle.sacred:
      case RingStyle.prism:
      case RingStyle.constellation:
        return ItemRarity.epic;
      case RingStyle.zodiac:
      case RingStyle.fire:
      case RingStyle.infinity:
      case RingStyle.quantum:
      case RingStyle.tornado:
      case RingStyle.matrixRing:
        return ItemRarity.legendary;
    }
  }

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
  ruby,         // Deep red
  sapphire,     // Royal blue
  amber,        // Warm amber
  obsidian,     // Dark with highlights
  opal,         // Iridescent shifting
  sunset,       // Orange-pink
  northern,     // Aurora green-blue
  crimson,      // Deep crimson
  cyan,         // Electric cyan
  ivory,        // Soft ivory
  coral,        // Coral pink
  midnight,     // Deep navy blue
  lavender,     // Soft lavender
  peach,        // Warm peach
  jade,         // Deep jade green
  magenta,      // Bright magenta
  bronze,       // Warm bronze
  champagne,    // Pale champagne
  plasma,       // Electric purple-blue
  cherry,       // Cherry red
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
      case RingColor.ruby: return 'Ruby Red';
      case RingColor.sapphire: return 'Sapphire Blue';
      case RingColor.amber: return 'Amber Glow';
      case RingColor.obsidian: return 'Obsidian';
      case RingColor.opal: return 'Opal Shimmer';
      case RingColor.sunset: return 'Sunset';
      case RingColor.northern: return 'Northern Light';
      case RingColor.crimson: return 'Crimson';
      case RingColor.cyan: return 'Electric Cyan';
      case RingColor.ivory: return 'Ivory';
      case RingColor.coral: return 'Coral';
      case RingColor.midnight: return 'Midnight';
      case RingColor.lavender: return 'Lavender';
      case RingColor.peach: return 'Peach';
      case RingColor.jade: return 'Jade';
      case RingColor.magenta: return 'Magenta';
      case RingColor.bronze: return 'Bronze';
      case RingColor.champagne: return 'Champagne';
      case RingColor.plasma: return 'Plasma';
      case RingColor.cherry: return 'Cherry';
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
      case RingColor.ruby: return '♦️';
      case RingColor.sapphire: return '🔵';
      case RingColor.amber: return '🔶';
      case RingColor.obsidian: return '🖤';
      case RingColor.opal: return '🦋';
      case RingColor.sunset: return '🌇';
      case RingColor.northern: return '🌌';
      case RingColor.crimson: return '❤️';
      case RingColor.cyan: return '🩵';
      case RingColor.ivory: return '🤍';
      case RingColor.coral: return '🪸';
      case RingColor.midnight: return '🌑';
      case RingColor.lavender: return '💟';
      case RingColor.peach: return '🍑';
      case RingColor.jade: return '🍀';
      case RingColor.magenta: return '🩷';
      case RingColor.bronze: return '🥉';
      case RingColor.champagne: return '🥂';
      case RingColor.plasma: return '⚡';
      case RingColor.cherry: return '🍒';
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
      case RingColor.rainbow: return const Color(0xFFD4AF37);
      case RingColor.ruby: return const Color(0xFFE31B23);
      case RingColor.sapphire: return const Color(0xFF0F52BA);
      case RingColor.amber: return const Color(0xFFFFBF00);
      case RingColor.obsidian: return const Color(0xFF3D3D3D);
      case RingColor.opal: return const Color(0xFFA8C8F0);
      case RingColor.sunset: return const Color(0xFFFF6B35);
      case RingColor.northern: return const Color(0xFF00C9A7);
      case RingColor.crimson: return const Color(0xFFDC143C);
      case RingColor.cyan: return const Color(0xFF00E5FF);
      case RingColor.ivory: return const Color(0xFFFFF8DC);
      case RingColor.coral: return const Color(0xFFFF6F61);
      case RingColor.midnight: return const Color(0xFF191970);
      case RingColor.lavender: return const Color(0xFFB57EDC);
      case RingColor.peach: return const Color(0xFFFFCBA4);
      case RingColor.jade: return const Color(0xFF00A36C);
      case RingColor.magenta: return const Color(0xFFFF00FF);
      case RingColor.bronze: return const Color(0xFFCD7F32);
      case RingColor.champagne: return const Color(0xFFF7E7CE);
      case RingColor.plasma: return const Color(0xFF7B2FBE);
      case RingColor.cherry: return const Color(0xFFDE3163);
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
      case RingColor.ruby: return const Color(0xFFFF6B6B);
      case RingColor.sapphire: return const Color(0xFF7EB8FF);
      case RingColor.amber: return const Color(0xFFFFE082);
      case RingColor.obsidian: return const Color(0xFF808080);
      case RingColor.opal: return const Color(0xFFE8D5F5);
      case RingColor.sunset: return const Color(0xFFFFB88C);
      case RingColor.northern: return const Color(0xFF69FFF2);
      case RingColor.crimson: return const Color(0xFFFF6B8A);
      case RingColor.cyan: return const Color(0xFF80F0FF);
      case RingColor.ivory: return const Color(0xFFFFFFF0);
      case RingColor.coral: return const Color(0xFFFFB3AB);
      case RingColor.midnight: return const Color(0xFF4169E1);
      case RingColor.lavender: return const Color(0xFFE6D3F8);
      case RingColor.peach: return const Color(0xFFFFE5D0);
      case RingColor.jade: return const Color(0xFF66CDAA);
      case RingColor.magenta: return const Color(0xFFFF88FF);
      case RingColor.bronze: return const Color(0xFFD4A76A);
      case RingColor.champagne: return const Color(0xFFFFF5E1);
      case RingColor.plasma: return const Color(0xFFB366FF);
      case RingColor.cherry: return const Color(0xFFFF85A1);
    }
  }

  List<Color> get gradientColors {
    if (this == RingColor.rainbow) {
      return [
        const Color(0xFFFF6B6B), const Color(0xFFFFE66D),
        const Color(0xFF4ECB71), const Color(0xFF4ECDC4),
        const Color(0xFF45B7D1), const Color(0xFF9B59B6),
      ];
    }
    if (this == RingColor.opal) {
      return [
        const Color(0xFFA8C8F0), const Color(0xFFE8D5F5),
        const Color(0xFFF5D5E8), const Color(0xFFA8C8F0),
      ];
    }
    if (this == RingColor.plasma) {
      return [
        const Color(0xFF7B2FBE), const Color(0xFF00E5FF),
        const Color(0xFFB366FF),
      ];
    }
    if (this == RingColor.northern) {
      return [
        const Color(0xFF00C9A7), const Color(0xFF00E5FF),
        const Color(0xFF69FFF2),
      ];
    }
    return [primaryColor, secondaryColor];
  }

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
  hypnotic,     // Spiraling hypnotic
  aurora,       // Northern lights shifting
  heartbeat,    // Heart rhythm pulse
  tidal,        // Ocean tidal rhythm
  cosmic,       // Cosmic expansion
  spiral,       // Spiraling in/out
  pendulum,     // Pendulum swing
  vibrate,      // Subtle vibration
  floatMotion,  // Floating/hovering
  bounce,       // Gentle bounce
  orbit,        // Orbital motion
  twinkle,      // Twinkling stars
  wave,         // Wave motion
  morph,        // Shape morphing
  ripple,       // Ripple expand
  cascade,      // Cascading fall
  flow,         // Flowing stream
  zenMode,      // Ultra-slow zen
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
      case SanctuaryAnimationStyle.hypnotic: return 'Hypnotic';
      case SanctuaryAnimationStyle.aurora: return 'Aurora';
      case SanctuaryAnimationStyle.heartbeat: return 'Heartbeat';
      case SanctuaryAnimationStyle.tidal: return 'Tidal';
      case SanctuaryAnimationStyle.cosmic: return 'Cosmic';
      case SanctuaryAnimationStyle.spiral: return 'Spiral';
      case SanctuaryAnimationStyle.pendulum: return 'Pendulum';
      case SanctuaryAnimationStyle.vibrate: return 'Vibrate';
      case SanctuaryAnimationStyle.floatMotion: return 'Float';
      case SanctuaryAnimationStyle.bounce: return 'Bounce';
      case SanctuaryAnimationStyle.orbit: return 'Orbit';
      case SanctuaryAnimationStyle.twinkle: return 'Twinkle';
      case SanctuaryAnimationStyle.wave: return 'Wave';
      case SanctuaryAnimationStyle.morph: return 'Morph';
      case SanctuaryAnimationStyle.ripple: return 'Ripple';
      case SanctuaryAnimationStyle.cascade: return 'Cascade';
      case SanctuaryAnimationStyle.flow: return 'Flow';
      case SanctuaryAnimationStyle.zenMode: return 'Zen Mode';
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
      case SanctuaryAnimationStyle.hypnotic: return '🌀';
      case SanctuaryAnimationStyle.aurora: return '🌌';
      case SanctuaryAnimationStyle.heartbeat: return '💓';
      case SanctuaryAnimationStyle.tidal: return '🏖️';
      case SanctuaryAnimationStyle.cosmic: return '🪐';
      case SanctuaryAnimationStyle.spiral: return '🌪️';
      case SanctuaryAnimationStyle.pendulum: return '🕐';
      case SanctuaryAnimationStyle.vibrate: return '📳';
      case SanctuaryAnimationStyle.floatMotion: return '🎈';
      case SanctuaryAnimationStyle.bounce: return '⚾';
      case SanctuaryAnimationStyle.orbit: return '🛸';
      case SanctuaryAnimationStyle.twinkle: return '⭐';
      case SanctuaryAnimationStyle.wave: return '〰️';
      case SanctuaryAnimationStyle.morph: return '🔮';
      case SanctuaryAnimationStyle.ripple: return '💧';
      case SanctuaryAnimationStyle.cascade: return '🏔️';
      case SanctuaryAnimationStyle.flow: return '🏞️';
      case SanctuaryAnimationStyle.zenMode: return '☯️';
    }
  }

  int get coinCost => 0;

  ItemRarity get rarity {
    switch (this) {
      case SanctuaryAnimationStyle.gentle:
      case SanctuaryAnimationStyle.pulse:
      case SanctuaryAnimationStyle.breathe:
      case SanctuaryAnimationStyle.stillness:
      case SanctuaryAnimationStyle.bounce:
      case SanctuaryAnimationStyle.wave:
        return ItemRarity.common;
      case SanctuaryAnimationStyle.meditative:
      case SanctuaryAnimationStyle.energetic:
      case SanctuaryAnimationStyle.particles:
      case SanctuaryAnimationStyle.floatMotion:
      case SanctuaryAnimationStyle.twinkle:
      case SanctuaryAnimationStyle.ripple:
      case SanctuaryAnimationStyle.flow:
        return ItemRarity.rare;
      case SanctuaryAnimationStyle.hypnotic:
      case SanctuaryAnimationStyle.aurora:
      case SanctuaryAnimationStyle.tidal:
      case SanctuaryAnimationStyle.spiral:
      case SanctuaryAnimationStyle.pendulum:
      case SanctuaryAnimationStyle.cascade:
      case SanctuaryAnimationStyle.zenMode:
        return ItemRarity.epic;
      case SanctuaryAnimationStyle.heartbeat:
      case SanctuaryAnimationStyle.cosmic:
      case SanctuaryAnimationStyle.vibrate:
      case SanctuaryAnimationStyle.orbit:
      case SanctuaryAnimationStyle.morph:
        return ItemRarity.legendary;
    }
  }

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
  infinityFrame,  // Infinity symbol
  chakraFrame,    // 7 chakra points
  galaxyFrame,    // Galaxy spiral frame
  vine,           // Growing vine pattern
  dragon,         // Dragon circling
  phoenix,        // Phoenix wings
  mandalaFrame,   // Complex mandala border
  crystalFrame,   // Crystal facets
  shield,         // Shield shape
  wings,          // Angel wings
  thirdEye,       // Eye of providence
  trishul,        // Trident frame
  conch,          // Conch shell spiral
  dharmaWheel,    // Buddhist dharma wheel
  flameFrame,     // Fire circle
  pentagon,       // Pentagon shape
  star,           // Star frame
  decagon,        // 10-sided polygon
  vesica,         // Vesica piscis
  spiral,         // Spiral frame
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
      case FrameStyle.infinityFrame: return 'Infinity';
      case FrameStyle.chakraFrame: return 'Chakra Points';
      case FrameStyle.galaxyFrame: return 'Galaxy';
      case FrameStyle.vine: return 'Sacred Vine';
      case FrameStyle.dragon: return 'Dragon';
      case FrameStyle.phoenix: return 'Phoenix';
      case FrameStyle.mandalaFrame: return 'Mandala';
      case FrameStyle.crystalFrame: return 'Crystal';
      case FrameStyle.shield: return 'Shield';
      case FrameStyle.wings: return 'Angel Wings';
      case FrameStyle.thirdEye: return 'Third Eye';
      case FrameStyle.trishul: return 'Trishul';
      case FrameStyle.conch: return 'Conch Shell';
      case FrameStyle.dharmaWheel: return 'Dharma Wheel';
      case FrameStyle.flameFrame: return 'Flame Circle';
      case FrameStyle.pentagon: return 'Pentagon';
      case FrameStyle.star: return 'Star';
      case FrameStyle.decagon: return 'Decagon';
      case FrameStyle.vesica: return 'Vesica Piscis';
      case FrameStyle.spiral: return 'Spiral';
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
      case FrameStyle.infinityFrame: return '♾️';
      case FrameStyle.chakraFrame: return '🧘';
      case FrameStyle.galaxyFrame: return '🌀';
      case FrameStyle.vine: return '🌿';
      case FrameStyle.dragon: return '🐉';
      case FrameStyle.phoenix: return '🦅';
      case FrameStyle.mandalaFrame: return '❋';
      case FrameStyle.crystalFrame: return '💎';
      case FrameStyle.shield: return '🛡️';
      case FrameStyle.wings: return '🕊️';
      case FrameStyle.thirdEye: return '👁️';
      case FrameStyle.trishul: return '🔱';
      case FrameStyle.conch: return '🐚';
      case FrameStyle.dharmaWheel: return '☸️';
      case FrameStyle.flameFrame: return '🔥';
      case FrameStyle.pentagon: return '⬠';
      case FrameStyle.star: return '⭐';
      case FrameStyle.decagon: return '🔟';
      case FrameStyle.vesica: return '👁️';
      case FrameStyle.spiral: return '🌀';
    }
  }

  int get coinCost => 0;

  ItemRarity get rarity {
    switch (this) {
      case FrameStyle.none:
      case FrameStyle.hexagon:
      case FrameStyle.octagon:
      case FrameStyle.diamond:
      case FrameStyle.pentagon:
      case FrameStyle.decagon:
      case FrameStyle.star:
        return ItemRarity.common;
      case FrameStyle.lotus:
      case FrameStyle.sun:
      case FrameStyle.moon:
      case FrameStyle.temple:
      case FrameStyle.tribal:
      case FrameStyle.shield:
      case FrameStyle.conch:
      case FrameStyle.vesica:
      case FrameStyle.spiral:
        return ItemRarity.rare;
      case FrameStyle.yantra:
      case FrameStyle.infinityFrame:
      case FrameStyle.mandalaFrame:
      case FrameStyle.crystalFrame:
      case FrameStyle.wings:
      case FrameStyle.dharmaWheel:
      case FrameStyle.flameFrame:
      case FrameStyle.chakraFrame:
        return ItemRarity.epic;
      case FrameStyle.galaxyFrame:
      case FrameStyle.vine:
      case FrameStyle.dragon:
      case FrameStyle.phoenix:
      case FrameStyle.thirdEye:
      case FrameStyle.trishul:
        return ItemRarity.legendary;
    }
  }

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

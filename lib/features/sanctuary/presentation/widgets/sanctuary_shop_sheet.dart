import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/coin_service.dart';
import '../../data/models/sanctuary_customization_model.dart';
import '../../data/services/sanctuary_customization_service.dart';

/// Shop item data class
class ShopItem {
  final String id;
  final String name;
  final String emoji;
  final int cost;
  final ItemRarity rarity;
  final bool isDefault;
  final Color? previewColor;
  final String? description;
  final String categoryKey;

  const ShopItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cost,
    required this.rarity,
    required this.isDefault,
    required this.categoryKey,
    this.previewColor,
    this.description,
  });
}

/// Callback for preview changes
typedef PreviewCallback = void Function(SanctuaryCustomization preview);

/// Draggable bottom sheet containing the sanctuary customization shop.
/// Features:
/// - Preview mode when selecting items
/// - Apply button popup
/// - Fixed drag handle (only drag via handle)
/// - Scrollable items inside
class SanctuaryShopSheet extends StatefulWidget {
  final ScrollController scrollController;
  final PreviewCallback? onPreviewChange;
  final VoidCallback? onPreviewClear;
  
  const SanctuaryShopSheet({
    super.key,
    required this.scrollController,
    this.onPreviewChange,
    this.onPreviewClear,
  });

  @override
  State<SanctuaryShopSheet> createState() => _SanctuaryShopSheetState();
}

class _SanctuaryShopSheetState extends State<SanctuaryShopSheet>
    with SingleTickerProviderStateMixin {
  final CoinService _coinService = CoinService();
  final SanctuaryCustomizationService _customizationService = SanctuaryCustomizationService();
  
  late TabController _tabController;
  
  // Preview state
  ShopItem? _previewItem;
  CustomizationCategory? _previewCategory;
  bool _showApplyButton = false;
  
  // View mode: false = shop, true = my collection
  bool _showMyCollection = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: CustomizationCategory.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ashramBackgroundDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: AppColors.ashramAccentGold.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Fixed Header Section (drag handle, title, tabs) - NOT scrollable
          _buildFixedHeader(),
          
          // Scrollable Shop Content
          Expanded(
            child: Stack(
              children: [
                // Main content - either shop or collection
                _showMyCollection
                    ? _buildMyCollectionView()
                    : TabBarView(
                        controller: _tabController,
                        children: CustomizationCategory.values.map((category) {
                          return _buildCategoryGrid(category);
                        }).toList(),
                      ),
                
                // Apply Button Overlay
                if (_showApplyButton && _previewItem != null)
                  _buildApplyOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ashramBackgroundDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header with title and coin balance
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildHeader(),
          ),
          const SizedBox(height: 16),
          
          // Category tabs
          _buildCategoryTabs(),
          const SizedBox(height: 8),
          
          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFF4E4B6), Color(0xFFD4AF37)],
              ).createShader(bounds),
              child: Text(
                _showMyCollection ? 'My Collection' : 'Customize Sanctuary',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _previewItem != null 
                  ? 'Previewing: ${_previewItem!.name}'
                  : _showMyCollection
                      ? 'Switch between your owned items'
                      : 'Tap to preview, then apply',
              style: GoogleFonts.tenorSans(
                fontSize: 11,
                color: _previewItem != null 
                    ? AppColors.ashramAccentGold
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        
        // View toggle and Coin balance
        Row(
          children: [
            // View toggle button
            GestureDetector(
              onTap: () {
                setState(() {
                  _showMyCollection = !_showMyCollection;
                  // Clear preview when switching views
                  _previewItem = null;
                  _previewCategory = null;
                  _showApplyButton = false;
                });
                widget.onPreviewClear?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _showMyCollection
                        ? [
                            AppColors.ashramSaffron.withValues(alpha: 0.3),
                            AppColors.ashramSaffron.withValues(alpha: 0.1),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _showMyCollection
                        ? AppColors.ashramSaffron.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showMyCollection ? Icons.store : Icons.inventory_2,
                      size: 14,
                      color: _showMyCollection 
                          ? AppColors.ashramSaffron
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showMyCollection ? 'Shop' : 'Owned',
                      style: GoogleFonts.tenorSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _showMyCollection 
                            ? AppColors.ashramSaffron
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Coin balance
            StreamBuilder<int>(
              stream: _coinService.coinStream,
              initialData: _coinService.currentBalance,
              builder: (context, snapshot) {
                final coins = snapshot.data ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.ashramAccentGold.withValues(alpha: 0.2),
                        AppColors.ashramAccentGold.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.ashramAccentGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        coins.toString(),
                        style: GoogleFonts.tenorSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ashramAccentGold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMyCollectionView() {
    // Get all currently equipped items
    final current = _customizationService.currentCustomization;
    
    // Group owned items by category
    final Map<CustomizationCategory, List<ShopItem>> ownedByCategory = {};
    
    for (final category in CustomizationCategory.values) {
      final items = _getItemsForCategory(category);
      final owned = items.where((item) => 
        _customizationService.isItemPurchased(item.categoryKey, item.id) ||
        item.cost == 0 ||
        item.isDefault
      ).toList();
      if (owned.isNotEmpty) {
        ownedByCategory[category] = owned;
      }
    }
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: ownedByCategory.length + 1, // +1 for currently equipped section
      itemBuilder: (context, index) {
        if (index == 0) {
          // Currently equipped section
          return _buildCurrentlyEquippedSection(current);
        }
        
        final categoryIndex = index - 1;
        final category = ownedByCategory.keys.elementAt(categoryIndex);
        final items = ownedByCategory[category]!;
        
        return _buildCollectionCategory(category, items);
      },
    );
  }

  Widget _buildCurrentlyEquippedSection(SanctuaryCustomization current) {
    // Get currently equipped items as a horizontal list
    final equipped = <ShopItem>[];
    
    // Om Style
    equipped.add(ShopItem(
      id: current.omStyle.name,
      name: current.omStyle.displayName,
      emoji: current.omStyle.emoji,
      cost: 0,
      rarity: current.omStyle.rarity,
      isDefault: current.omStyle.isDefault,
      categoryKey: 'omStyle',
    ));
    
    // Ring Style
    equipped.add(ShopItem(
      id: current.ringStyle.name,
      name: current.ringStyle.displayName,
      emoji: current.ringStyle.emoji,
      cost: 0,
      rarity: current.ringStyle.rarity,
      isDefault: current.ringStyle.isDefault,
      categoryKey: 'ringStyle',
    ));
    
    // Ring Color
    equipped.add(ShopItem(
      id: current.ringColor.name,
      name: current.ringColor.displayName,
      emoji: current.ringColor.emoji,
      cost: 0,
      rarity: current.ringColor.rarity,
      isDefault: current.ringColor.isDefault,
      categoryKey: 'ringColor',
      previewColor: current.ringColor.primaryColor,
    ));
    
    // Background
    equipped.add(ShopItem(
      id: current.backgroundStyle.name,
      name: current.backgroundStyle.displayName,
      emoji: current.backgroundStyle.emoji,
      cost: 0,
      rarity: current.backgroundStyle.rarity,
      isDefault: current.backgroundStyle.isDefault,
      categoryKey: 'backgroundStyle',
    ));
    
    // Glow
    equipped.add(ShopItem(
      id: current.glowColor.name,
      name: current.glowColor.displayName,
      emoji: current.glowColor.emoji,
      cost: 0,
      rarity: current.glowColor.rarity,
      isDefault: current.glowColor.isDefault,
      categoryKey: 'glowColor',
      previewColor: current.glowColor.color,
    ));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.ashramAccentGold.withValues(alpha: 0.3),
                      AppColors.ashramAccentGold.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.ashramAccentGold),
                    const SizedBox(width: 4),
                    Text(
                      'CURRENTLY EQUIPPED',
                      style: GoogleFonts.tenorSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ashramAccentGold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: equipped.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = equipped[index];
              return SizedBox(
                width: 70,
                child: _buildMiniItemCard(item, isEquipped: true),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.05),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCollectionCategory(CustomizationCategory category, List<ShopItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                category.displayName.toUpperCase(),
                style: GoogleFonts.tenorSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${items.length} items',
                style: GoogleFonts.tenorSans(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final isEquipped = _customizationService.isItemSelected(item.categoryKey, item.id);
              return SizedBox(
                width: 70,
                child: _buildMiniItemCard(item, isEquipped: isEquipped),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMiniItemCard(ShopItem item, {bool isEquipped = false}) {
    return GestureDetector(
      onTap: () {
        // Quick tap to switch to this item
        _onItemTap(item, CustomizationCategory.values.firstWhere(
          (c) => _categoryKeyMatches(c, item.categoryKey),
          orElse: () => CustomizationCategory.omStyles,
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isEquipped
                ? [
                    AppColors.ashramAccentGold.withValues(alpha: 0.2),
                    AppColors.ashramAccentGold.withValues(alpha: 0.05),
                  ]
                : [
                    const Color(0xFF1A2837).withValues(alpha: 0.6),
                    const Color(0xFF2A3847).withValues(alpha: 0.3),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEquipped
                ? AppColors.ashramAccentGold.withValues(alpha: 0.5)
                : item.rarity.color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isEquipped)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.ashramAccentGold,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.check, size: 8, color: Colors.black),
              ),
            item.previewColor != null
                ? Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.previewColor!.withValues(alpha: 0.3),
                      border: Border.all(color: item.previewColor!, width: 2),
                    ),
                  )
                : Text(item.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              item.name,
              style: GoogleFonts.tenorSans(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool _categoryKeyMatches(CustomizationCategory category, String key) {
    switch (category) {
      case CustomizationCategory.omStyles: return key == 'omStyle';
      case CustomizationCategory.ringStyles: return key == 'ringStyle';
      case CustomizationCategory.ringColors: return key == 'ringColor';
      case CustomizationCategory.frameStyles: return key == 'frameStyle';
      case CustomizationCategory.animations: return key == 'animationStyle';
      case CustomizationCategory.backgrounds: return key == 'backgroundStyle';
      case CustomizationCategory.glowColors: return key == 'glowColor';
      case CustomizationCategory.specialEffects: return key == 'specialEffect';
      case CustomizationCategory.particles: return key == 'particleStyle';
      case CustomizationCategory.deityImages: return key == 'deityImage';
    }
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 36,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.ashramAccentGold,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppColors.ashramAccentGold,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
        labelStyle: GoogleFonts.tenorSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.tenorSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: CustomizationCategory.values.map((category) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.emoji, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(category.displayName),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryGrid(CustomizationCategory category) {
    final items = _getItemsForCategory(category);
    
    return GridView.builder(
      // Use a separate scroll controller for items (not the sheet's controller)
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildShopItemCard(items[index], category);
      },
    );
  }

  List<ShopItem> _getItemsForCategory(CustomizationCategory category) {
    switch (category) {
      case CustomizationCategory.omStyles:
        return OmStyle.values.map((style) => ShopItem(
          id: style.name,
          name: style.displayName,
          emoji: style.emoji,
          cost: style.coinCost,
          rarity: style.rarity,
          isDefault: style.isDefault,
          categoryKey: 'omStyle',
        )).toList();
      
      case CustomizationCategory.ringStyles:
        return RingStyle.values.map((style) => ShopItem(
          id: style.name,
          name: style.displayName,
          emoji: style.emoji,
          cost: style.coinCost,
          rarity: style.rarity,
          isDefault: style.isDefault,
          categoryKey: 'ringStyle',
        )).toList();
      
      case CustomizationCategory.ringColors:
        return RingColor.values.map((color) => ShopItem(
          id: color.name,
          name: color.displayName,
          emoji: color.emoji,
          cost: color.coinCost,
          rarity: color.rarity,
          isDefault: color.isDefault,
          categoryKey: 'ringColor',
          previewColor: color.primaryColor,
        )).toList();
      
      case CustomizationCategory.frameStyles:
        return FrameStyle.values.map((style) => ShopItem(
          id: style.name,
          name: style.displayName,
          emoji: style.emoji,
          cost: style.coinCost,
          rarity: style.rarity,
          isDefault: style.isDefault,
          categoryKey: 'frameStyle',
        )).toList();
      
      case CustomizationCategory.animations:
        return SanctuaryAnimationStyle.values.map((style) => ShopItem(
          id: style.name,
          name: style.displayName,
          emoji: style.emoji,
          cost: style.coinCost,
          rarity: style.rarity,
          isDefault: style.isDefault,
          categoryKey: 'animationStyle',
        )).toList();
      
      case CustomizationCategory.backgrounds:
        return BackgroundStyle.values.map((style) => ShopItem(
          id: style.name,
          name: style.displayName,
          emoji: style.emoji,
          cost: style.coinCost,
          rarity: style.rarity,
          isDefault: style.isDefault,
          categoryKey: 'backgroundStyle',
        )).toList();
      
      case CustomizationCategory.glowColors:
        return GlowColor.values.map((color) => ShopItem(
          id: color.name,
          name: color.displayName,
          emoji: color.emoji,
          cost: color.coinCost,
          rarity: color.rarity,
          isDefault: color.isDefault,
          categoryKey: 'glowColor',
          previewColor: color.color,
        )).toList();
      
      case CustomizationCategory.specialEffects:
        return SpecialEffect.values.map((effect) => ShopItem(
          id: effect.name,
          name: effect.displayName,
          emoji: effect.emoji,
          cost: effect.coinCost,
          rarity: effect.rarity,
          isDefault: effect.isDefault,
          categoryKey: 'specialEffect',
        )).toList();
      
      case CustomizationCategory.particles:
        return ParticleStyle.values.map((style) => ShopItem(
          id: style.name,
          name: style.displayName,
          emoji: style.emoji,
          cost: style.coinCost,
          rarity: style.rarity,
          isDefault: style.isDefault,
          categoryKey: 'particleStyle',
        )).toList();
      
      case CustomizationCategory.deityImages:
        return DeityImage.values.map((deity) => ShopItem(
          id: deity.name,
          name: deity.displayName,
          emoji: deity.emoji,
          cost: deity.coinCost,
          rarity: deity.rarity,
          isDefault: false,
          categoryKey: 'deityImage',
          description: deity.description,
        )).toList();
    }
  }

  Widget _buildShopItemCard(ShopItem item, CustomizationCategory category) {
    final isPurchased = _customizationService.isItemPurchased(item.categoryKey, item.id);
    final isSelected = _customizationService.isItemSelected(item.categoryKey, item.id);
    final isPreview = _previewItem?.id == item.id && _previewCategory == category;
    final canAfford = _coinService.currentBalance >= item.cost;
    
    return GestureDetector(
      onTap: () => _onItemTap(item, category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPreview
                ? [
                    AppColors.ashramSaffron.withValues(alpha: 0.3),
                    AppColors.ashramSaffron.withValues(alpha: 0.1),
                  ]
                : isSelected
                    ? [
                        AppColors.ashramAccentGold.withValues(alpha: 0.2),
                        AppColors.ashramAccentGold.withValues(alpha: 0.05),
                      ]
                    : [
                        const Color(0xFF1A2837).withValues(alpha: 0.6),
                        const Color(0xFF2A3847).withValues(alpha: 0.3),
                      ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPreview
                ? AppColors.ashramSaffron.withValues(alpha: 0.8)
                : isSelected
                    ? AppColors.ashramAccentGold.withValues(alpha: 0.5)
                    : item.rarity.color.withValues(alpha: 0.2),
            width: isPreview ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji/Preview
                  Expanded(
                    child: Center(
                      child: _buildItemPreview(item),
                    ),
                  ),
                  
                  // Item name
                  Text(
                    item.name,
                    style: GoogleFonts.tenorSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  
                  // Status indicator
                  _buildStatusIndicator(item, isPurchased, isSelected, canAfford),
                ],
              ),
            ),
            
            // Selected checkmark
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.ashramAccentGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 10,
                    color: Colors.black,
                  ),
                ),
              ),
            
            // Preview indicator
            if (isPreview)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.ashramSaffron,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PREVIEW',
                    style: GoogleFonts.tenorSans(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemPreview(ShopItem item) {
    if (item.previewColor != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: item.previewColor!.withValues(alpha: 0.3),
          border: Border.all(
            color: item.previewColor!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: item.previewColor!.withValues(alpha: 0.4),
              blurRadius: 10,
            ),
          ],
        ),
      );
    }
    
    return Text(
      item.emoji,
      style: const TextStyle(fontSize: 32),
    );
  }

  Widget _buildStatusIndicator(ShopItem item, bool isPurchased, bool isSelected, bool canAfford) {
    if (isSelected) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 10, color: AppColors.ashramAccentGold),
          const SizedBox(width: 2),
          Text(
            'Active',
            style: GoogleFonts.tenorSans(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: AppColors.ashramAccentGold,
            ),
          ),
        ],
      );
    }
    
    if (isPurchased || item.cost == 0) {
      return Text(
        'Owned',
        style: GoogleFonts.tenorSans(
          fontSize: 8,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('💎', style: TextStyle(fontSize: 8)),
        const SizedBox(width: 2),
        Text(
          item.cost.toString(),
          style: GoogleFonts.tenorSans(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: canAfford ? AppColors.ashramAccentGold : Colors.red.shade300,
          ),
        ),
      ],
    );
  }

  void _onItemTap(ShopItem item, CustomizationCategory category) {
    final isPurchased = _customizationService.isItemPurchased(item.categoryKey, item.id);
    final isSelected = _customizationService.isItemSelected(item.categoryKey, item.id);
    final canAfford = _coinService.currentBalance >= item.cost;
    
    // If already selected, do nothing
    if (isSelected) return;
    
    // Set preview
    setState(() {
      _previewItem = item;
      _previewCategory = category;
      _showApplyButton = true;
    });
    
    // Trigger preview callback
    _triggerPreview(item, category);
  }

  void _triggerPreview(ShopItem item, CustomizationCategory category) {
    final current = _customizationService.currentCustomization;
    SanctuaryCustomization preview = current;
    
    switch (item.categoryKey) {
      case 'omStyle':
        preview = current.copyWith(omStyle: OmStyle.values.firstWhere((e) => e.name == item.id));
        break;
      case 'ringStyle':
        preview = current.copyWith(ringStyle: RingStyle.values.firstWhere((e) => e.name == item.id));
        break;
      case 'ringColor':
        preview = current.copyWith(ringColor: RingColor.values.firstWhere((e) => e.name == item.id));
        break;
      case 'animationStyle':
        preview = current.copyWith(animationStyle: SanctuaryAnimationStyle.values.firstWhere((e) => e.name == item.id));
        break;
      case 'backgroundStyle':
        preview = current.copyWith(backgroundStyle: BackgroundStyle.values.firstWhere((e) => e.name == item.id));
        break;
      case 'glowColor':
        preview = current.copyWith(glowColor: GlowColor.values.firstWhere((e) => e.name == item.id));
        break;
      case 'deityImage':
        preview = current.copyWith(deityImage: DeityImage.values.firstWhere((e) => e.name == item.id));
        break;
      case 'frameStyle':
        preview = current.copyWith(frameStyle: FrameStyle.values.firstWhere((e) => e.name == item.id));
        break;
      case 'specialEffect':
        preview = current.copyWith(specialEffect: SpecialEffect.values.firstWhere((e) => e.name == item.id));
        break;
      case 'particleStyle':
        preview = current.copyWith(particleStyle: ParticleStyle.values.firstWhere((e) => e.name == item.id));
        break;
    }
    
    widget.onPreviewChange?.call(preview);
  }

  Widget _buildApplyOverlay() {
    final item = _previewItem!;
    final isPurchased = _customizationService.isItemPurchased(item.categoryKey, item.id);
    final canAfford = _coinService.currentBalance >= item.cost;
    final canApply = isPurchased || item.cost == 0 || canAfford;
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.ashramBackgroundDark.withValues(alpha: 0.95),
              AppColors.ashramBackgroundDark,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Cancel button
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelPreview,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.tenorSans(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Apply button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: canApply ? () => _applyItem(item) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canApply 
                        ? AppColors.ashramAccentGold
                        : Colors.grey.shade700,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: canApply ? 4 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isPurchased || item.cost == 0 
                            ? 'Apply' 
                            : canAfford 
                                ? 'Buy & Apply'
                                : 'Not Enough Coins',
                        style: GoogleFonts.tenorSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isPurchased && item.cost > 0 && canAfford) ...[
                        const SizedBox(width: 8),
                        const Text('💎', style: TextStyle(fontSize: 12)),
                        Text(
                          item.cost.toString(),
                          style: GoogleFonts.tenorSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cancelPreview() {
    setState(() {
      _previewItem = null;
      _previewCategory = null;
      _showApplyButton = false;
    });
    
    // Restore original customization
    widget.onPreviewChange?.call(_customizationService.currentCustomization);
    widget.onPreviewClear?.call();
  }

  Future<void> _applyItem(ShopItem item) async {
    final isPurchased = _customizationService.isItemPurchased(item.categoryKey, item.id);
    
    // Purchase if needed
    if (!isPurchased && item.cost > 0) {
      final success = await _coinService.spendCoins(item.cost);
      if (!success) {
        _showInsufficientFundsMessage();
        return;
      }
      await _customizationService.purchaseItem(item.categoryKey, item.id);
    }
    
    // Apply the customization
    await _applyCustomization(item);
    
    // Clear preview state
    setState(() {
      _previewItem = null;
      _previewCategory = null;
      _showApplyButton = false;
    });
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('${item.name} applied!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _applyCustomization(ShopItem item) async {
    switch (item.categoryKey) {
      case 'omStyle':
        await _customizationService.applyCustomization(
          omStyle: OmStyle.values.firstWhere((e) => e.name == item.id),
        );
        break;
      case 'ringStyle':
        await _customizationService.applyCustomization(
          ringStyle: RingStyle.values.firstWhere((e) => e.name == item.id),
        );
        break;
      case 'ringColor':
        await _customizationService.applyCustomization(
          ringColor: RingColor.values.firstWhere((e) => e.name == item.id),
        );
        break;
      case 'animationStyle':
        await _customizationService.applyCustomization(
          animationStyle: SanctuaryAnimationStyle.values.firstWhere((e) => e.name == item.id),
        );
        break;
      case 'backgroundStyle':
        await _customizationService.applyCustomization(
          backgroundStyle: BackgroundStyle.values.firstWhere((e) => e.name == item.id),
        );
        break;
      case 'glowColor':
        await _customizationService.applyCustomization(
          glowColor: GlowColor.values.firstWhere((e) => e.name == item.id),
        );
        break;
      case 'deityImage':
        await _customizationService.applyCustomization(
          deityImage: DeityImage.values.firstWhere((e) => e.name == item.id),
        );
        break;
      case 'frameStyle':
        await _customizationService.applyCustomization(
          frameStyle: FrameStyle.values.firstWhere((e) => e.name == item.id),
        );
        break;
      case 'specialEffect':
        await _customizationService.applyCustomization(
          specialEffect: SpecialEffect.values.firstWhere((e) => e.name == item.id),
        );
        break;
      case 'particleStyle':
        await _customizationService.applyCustomization(
          particleStyle: ParticleStyle.values.firstWhere((e) => e.name == item.id),
        );
        break;
    }
  }

  void _showInsufficientFundsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Text('💎', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Not enough coins! Complete Ashram tasks to earn more.'),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/coin_display.dart';
import '../../../../shared/widgets/room_with_character.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/services/guide_animation_service.dart';
import '../../../gamification/data/models/item_model.dart';
import '../../../gamification/data/repositories/item_repository.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final ItemRepository _itemRepository = ItemRepository();
  final CoinService _coinService = CoinService();
  List<ItemModel> _items = [];
  bool _isLoadingItems = true;
  int _selectedTab = 0; // 0: House, 1: Items, 2: Skins, 3: Owned

  @override
  void initState() {
    super.initState();
    _coinService.initialize();
    _loadItems();
    GuideAnimationService().setState(GuideState.sitting);
  }

  Future<void> _loadItems() async {
    setState(() => _isLoadingItems = true);
    try {
      final items = await _itemRepository.getAllItems();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoadingItems = false;
        });
      }
    } catch (e) {
      // Fallback: retry getAllItems (generates defaults on error)
      try {
        final items = await _itemRepository.getAllItems();
        if (mounted) {
          setState(() {
            _items = items;
            _isLoadingItems = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _items = [];
            _isLoadingItems = false;
          });
        }
      }
    }
  }

  Future<void> _purchaseItem(ItemModel item) async {
    if (_coinService.currentBalance < item.coinCost) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough coins!'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
      return;
    }

    final success = await _coinService.spendCoins(item.coinCost);
    if (success) {
      await _itemRepository.unlockItem(item.id);
      GuideAnimationService().receiveItem(item.type.name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('${item.name} purchased!'),
              ],
            ),
            backgroundColor: AppColors.successColor,
          ),
        );
      }

      _loadItems();
    }
  }

  Future<void> _grantTestCoins() async {
    await _coinService.grantTestCoins(500);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.diamond, color: Colors.white),
              SizedBox(width: 8),
              Text('+500 test coins added!'),
            ],
          ),
          backgroundColor: AppColors.coinGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full background
            Positioned.fill(
              child: Container(color: AppColors.primaryBackground),
            ),
            // Room + Character (same size as Aangan)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: RoomWithCharacter.roomHeight(context),
              child: const RoomWithCharacter(
                characterSize: 600,
                characterPadding: EdgeInsets.only(top: 30),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(context),
            ),
            // Draggable bottom half - Items screen (pull up for full screen, pull down to half)
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.25,
              maxChildSize: 0.98,
              snap: true,
              snapSizes: const [0.25, 0.5, 0.98],
              builder: (context, scrollController) =>
                  _buildBottomSheet(context, scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.secondaryBackground.withOpacity(0.95),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Ashram',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText)),
          Row(
            children: [
              StreamBuilder<int>(
                stream: _coinService.coinStream,
                initialData: _coinService.currentBalance,
                builder: (context, snapshot) {
                  return CoinDisplay(coinCount: snapshot.data ?? 0);
                },
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Get 500 test coins',
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.coinGreen),
                  onPressed: _grantTestCoins,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(
      BuildContext context, ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Drag handle - inside scrollable so sheet responds to drag from anywhere
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 0),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          // Tabs
          SliverToBoxAdapter(child: _buildTabs()),
          // Tab content as slivers
          ..._buildTabSlivers(context),
        ],
      ),
    );
  }

  List<Widget> _buildTabSlivers(BuildContext context) {
    if (_isLoadingItems) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 64, color: AppColors.tertiaryText.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text('Loading items...',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _loadItems,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    switch (_selectedTab) {
      case 0:
        return _buildHouseTabSlivers(context);
      case 1:
        return _buildItemsTabSlivers(context);
      case 2:
        return _buildSkinsTabSlivers(context);
      case 3:
        return _buildOwnedTabSlivers(context);
      default:
        return _buildHouseTabSlivers(context);
    }
  }

  List<Widget> _buildHouseTabSlivers(BuildContext context) {
    final furnitureItems =
        _items.where((i) => i.type == ItemType.furniture).toList();
    final shelterItems =
        _items.where((i) => i.type == ItemType.shelter).toList();

    return [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            Text(
              'Furniture',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                primary: false,
                itemCount: furnitureItems.length,
                itemBuilder: (context, index) {
                  return _buildItemCard(context, furnitureItems[index]);
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Houses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                primary: false,
                itemCount: shelterItems.length,
                itemBuilder: (context, index) {
                  return _buildItemCard(context, shelterItems[index]);
                },
              ),
            ),
          ]),
        ),
      ),
    ];
  }

  List<Widget> _buildItemsTabSlivers(BuildContext context) {
    final foodItems = _items.where((i) => i.type == ItemType.food).toList();
    final clothesItems =
        _items.where((i) => i.type == ItemType.clothes).toList();

    return [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            Text(
              'Food',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                return _buildItemCard(context, foodItems[index]);
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Clothes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: clothesItems.length,
              itemBuilder: (context, index) {
                return _buildItemCard(context, clothesItems[index]);
              },
            ),
          ]),
        ),
      ),
    ];
  }

  List<Widget> _buildSkinsTabSlivers(BuildContext context) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.tertiaryText.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Character Skins',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Character appearance evolves with wisdom',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Normal Skin',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'The default skin for your sadhu',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Equipped',
                  style: TextStyle(
                    color: AppColors.successColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildOwnedTabSlivers(BuildContext context) {
    final ownedItems = _items.where((i) => i.isUnlocked).toList();

    if (ownedItems.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppColors.tertiaryText.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No items owned yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Purchase items from the shop',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _buildItemCard(context, ownedItems[index], showOwned: true);
            },
            childCount: ownedItems.length,
          ),
        ),
      ),
    ];
  }

  Widget _buildTabs() {
    final tabs = ['House', 'Items', 'Skins', 'Owned'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = _selectedTab == index;

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.warmOrange.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppColors.warmOrange
                        : AppColors.tertiaryText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, ItemModel item,
      {bool showOwned = false}) {
    final canAfford = _coinService.currentBalance >= item.coinCost;
    final rarityColor = _getRarityColor(item.rarity);

    return Card(
      child: InkWell(
        onTap: showOwned || item.isUnlocked
            ? null
            : () {
                if (canAfford) {
                  _purchaseItem(item);
                }
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image/Icon
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: rarityColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getItemIcon(item.type),
                    size: 48,
                    color: rarityColor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Item Name
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Rarity Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.rarity.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: rarityColor,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Price or Owned
              if (showOwned || item.isUnlocked)
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.successColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Owned',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(
                      Icons.diamond,
                      size: 16,
                      color: canAfford
                          ? AppColors.coinGreen
                          : AppColors.tertiaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.coinCost}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: canAfford
                            ? AppColors.coinGreen
                            : AppColors.tertiaryText,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return AppColors.commonColor;
      case ItemRarity.rare:
        return AppColors.rareColor;
      case ItemRarity.epic:
        return AppColors.epicColor;
    }
  }

  IconData _getItemIcon(ItemType type) {
    switch (type) {
      case ItemType.food:
        return Icons.restaurant;
      case ItemType.clothes:
        return Icons.checkroom;
      case ItemType.furniture:
        return Icons.chair;
      case ItemType.shelter:
        return Icons.home;
    }
  }
}

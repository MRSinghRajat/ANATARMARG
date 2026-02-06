import 'package:flutter/material.dart';
import 'package:rive/rive.dart'; // Standard Rive import
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/aangan_repository.dart';
import '../widgets/bell_widget.dart';
import '../widgets/nature_visitor_widget.dart';
// Shop Integration
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/services/guide_animation_service.dart';
import '../../../../shared/widgets/coin_display.dart';
import '../../../gamification/data/models/item_model.dart';
import '../../../gamification/data/repositories/item_repository.dart';


class AanganScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBeginTap;

  const AanganScreen({
    super.key,
    this.onBeginTap,
  });

  @override
  ConsumerState<AanganScreen> createState() => _AanganScreenState();
}

class _AanganScreenState extends ConsumerState<AanganScreen> with TickerProviderStateMixin {
  late Future<AanganContent> _contentFuture;
  final AanganRepository _repository = AanganRepository();

  // Customization / Shop State
  final ItemRepository _itemRepository = ItemRepository();
  final CoinService _coinService = CoinService();
  List<ItemModel> _items = [];
  bool _isLoadingItems = true;
  int _selectedTab = 0; // 0: House, 1: Items, 2: Skins, 3: Owned

  // Sadhu Interaction Control
  final List<RiveAnimationController> _sadhuControllers = [];
  Artboard? _sadhuArtboard;
  
  // Nature Visitor Control
  final GlobalKey<NatureVisitorWidgetState> _visitorKey = GlobalKey<NatureVisitorWidgetState>();

  void _triggerSadhuCelebration() async {
    // 1. Sadhu Jumps
    if (_sadhuArtboard != null) {
      for (int i = 0; i < 3; i++) {
          final controller = OneShotAnimation('jump', autoplay: true);
          _sadhuArtboard!.addController(controller);
          await Future.delayed(const Duration(milliseconds: 1200)); 
      }
    }
    
    // 2. Bird Flies In (Spawns)
    _visitorKey.currentState?.spawn();
  }
  
  // ... (initState)

  // ... (build start)
  


  @override
  void initState() {
    super.initState();
    _contentFuture = _repository.getDailyContent();
    
    // Initialize Shop/Customization Logic
    _coinService.initialize();
    _loadItems();
    // GuideAnimationService().setState(GuideState.sitting); // Optional: Sync state
  }

  Future<void> _loadItems() async {
    // setState(() => _isLoadingItems = true); // Avoid rebuild loops if called multiple times
    try {
      final items = await _itemRepository.getAllItems();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoadingItems = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _items = [];
          _isLoadingItems = false;
        });
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background - The 3D Room
          const RiveAnimation.asset(
            'assets/rive/roomanimation.riv',
            fit: BoxFit.cover,
          ),

          // 2. Dynamic Environment Overlay (Day/Night cycle)
          FutureBuilder<AanganContent>(
            future: _contentFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildEnvironmentOverlay(snapshot.data!.timeContext);
              }
              return const SizedBox(); // Transparent by default
            },
          ),



          // 3. Character - Sadhu (Centered)
          // 3. Character - Sadhu (Centered)
          // 3. Character - Sadhu (Centered)
          Center(
            child: GestureDetector(
              onTap: () {
                 if (_sadhuArtboard != null) {
                   _sadhuArtboard!.addController(OneShotAnimation('blink', autoplay: true));
                 }
              },
              child: SizedBox(
                width: 600,
                height: 600,
                child: RiveAnimation.asset(
                  'assets/rive/sadhu_character.riv',
                  fit: BoxFit.contain,
                  // animations: const ['blink', 'idle'], // Default idle loops
                  controllers: _sadhuControllers, // Dynamic controllers for interaction
                  onInit: (artboard) {
                    _sadhuArtboard = artboard;
                    // Add default idle/blink loops
                    _sadhuControllers.add(SimpleAnimation('idle'));
                    // Note: If 'blink' is a loop, this keeps it blinking periodically.
                    // We added interaction to force a blink on tap.
                    _sadhuControllers.add(SimpleAnimation('blink'));
                  },
                ),
              ),
            ),
          ),
          
          // 4. Sacred Rope (Top Right - Hanging from Ceiling)
          const Positioned(
            top: 0, 
            right: 20, 
            child: SafeArea(
              top: false, // Don't avoid status bar, let it hang from edge
              child: BellWidget(),
            ),
          ),
          


          // 4b. Nature Visitor (Bird) - Temporarily Removed
          // Positioned(
          //   bottom: 160, 
          //   right: 40, 
          //   child: NatureVisitorWidget(key: _visitorKey),
          // ),

          // 5. UI Layer - Dynamic Data
          FutureBuilder<AanganContent>(
            future: _contentFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              
              if (snapshot.hasError) {
                 return _buildContent(
                   context,
                   'Welcome back 🌱',
                   'Today we practice kindness.',
                   "Let's begin 🌿",
                   "Take one slow breath",
                 );
              }

              final data = snapshot.data!;
              return _buildContent(
                context,
                data.greeting,
                '', // Intention removed
                '', // Button removed
                data.quietText,
              );
            },
          ),
          

          // 6. Customization Sheet (Bottom Drawer)
          DraggableScrollableSheet(
            initialChildSize: 0.4, 
            minChildSize: 0.1,
            maxChildSize: 0.95, 
            snap: true,
            snapSizes: const [0.1, 0.4, 0.95],
            builder: (context, scrollController) =>
                _buildBottomSheet(context, scrollController),
          ),

          // 7. Dust Overlay (Removed)
          /* Positioned.fill(
             child: DustCleaningWidget(
               onCleaned: _triggerSadhuCelebration,
             ), 
          ), */
        ],
      ),
    );
  }

  // --- Customization UI Helpers ---

  Widget _buildBottomSheet(
      BuildContext context, ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.95), // Semi-transparent
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
      child: Column(
        children: [
          // 1. Drag Handle & Sticky Header (Tabs + Coins)
          // Attached to the Sheet's scrollController
          SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 0),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Coins (Top Right)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end, // Move to End
                      children: [
                        // Title Removed
                        StreamBuilder<int>(
                          stream: _coinService.coinStream,
                          initialData: _coinService.currentBalance,
                          builder: (context, snapshot) {
                            return CoinDisplay(coinCount: snapshot.data ?? 0);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  
                  // Sticky Tabs (Now part of the fixed header)
                  _buildTabs(),
                ],
              ),
            ),
          ),

          // 2. Scrollable Content (List Only)
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Tabs Removed from here (moved up)
                
                // Content
                ..._buildTabSlivers(context),
              ],
            ),
          ),
        ],
      ),
    );
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
                    fontSize: 12,
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
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('No items loaded')),
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
  
  // -- Tab Content Builders (Direct Port from ShopScreen) --
  
  List<Widget> _buildHouseTabSlivers(BuildContext context) {
    final furnitureItems =
        _items.where((i) => i.type == ItemType.furniture).toList();
    final shelterItems =
        _items.where((i) => i.type == ItemType.shelter).toList();

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Furniture',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: furnitureItems.length,
            itemBuilder: (context, index) {
              return _buildItemCard(context, furnitureItems[index]);
            },
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Houses',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                   fontSize: 18,
                ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: shelterItems.length,
            itemBuilder: (context, index) {
              return _buildItemCard(context, shelterItems[index]);
            },
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 50)),
    ];
  }

  List<Widget> _buildItemsTabSlivers(BuildContext context) {
    final foodItems = _items.where((i) => i.type == ItemType.food).toList();
    final clothesItems =
        _items.where((i) => i.type == ItemType.clothes).toList();

    return [
      // Food Section
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Food',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                   fontSize: 18,
                ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildItemCard(context, foodItems[index]),
            childCount: foodItems.length,
          ),
        ),
      ),

      // Clothes Section
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Clothes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                   fontSize: 18,
                ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildItemCard(context, clothesItems[index]),
            childCount: clothesItems.length,
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 50)),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Default Skin Equipped',
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
                 Icon(Icons.inventory_2_outlined,
                    size: 64, color: AppColors.tertiaryText.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text('No items owned yet'),
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
      const SliverToBoxAdapter(child: SizedBox(height: 50)),
    ];
  }
  
  Widget _buildItemCard(BuildContext context, ItemModel item,
      {bool showOwned = false}) {
    final canAfford = _coinService.currentBalance >= item.coinCost;
    final rarityColor = _getRarityColor(item.rarity);

    return Container(
      width: 140, // Slightly narrower for Sheet
      margin: const EdgeInsets.symmetric(horizontal: 4), 
      child: Card(
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
                      size: 32, // Smaller icon
                      color: rarityColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.rarity.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: rarityColor,
                    ),
                  ),
                ),
                if (showOwned || item.isUnlocked)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: AppColors.successColor),
                      SizedBox(width: 4),
                      Text('Owned', style: TextStyle(
                        fontSize: 10, color: AppColors.successColor, fontWeight: FontWeight.bold)),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.diamond, size: 14, color: canAfford ? AppColors.coinGreen : AppColors.tertiaryText),
                      const SizedBox(width: 4),
                      Text('${item.coinCost}', style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold,
                        color: canAfford ? AppColors.coinGreen : AppColors.tertiaryText)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common: return AppColors.commonColor;
      case ItemRarity.rare: return AppColors.rareColor;
      case ItemRarity.epic: return AppColors.epicColor;
    }
  }

  IconData _getItemIcon(ItemType type) {
    switch (type) {
      case ItemType.food: return Icons.restaurant;
      case ItemType.clothes: return Icons.checkroom;
      case ItemType.furniture: return Icons.chair;
      case ItemType.shelter: return Icons.home;
    }
  }

  Widget _buildEnvironmentOverlay(AanganTimeContext context) {
    Color overlayColor = Colors.transparent;
    BlendMode blendMode = BlendMode.srcOver;

    switch (context) {
      case AanganTimeContext.morning:
        overlayColor = const Color(0xFFFFEDA0).withOpacity(0.1); 
        blendMode = BlendMode.overlay;
        break;
      case AanganTimeContext.day:
        overlayColor = Colors.transparent;
        break;
      case AanganTimeContext.evening:
         // Adjusted for Rive background visibility
        overlayColor = const Color(0xFFFF9800).withOpacity(0.15); 
        blendMode = BlendMode.hardLight;
        break;
      case AanganTimeContext.night:
        overlayColor = const Color(0xFF1A237E).withOpacity(0.4); 
        blendMode = BlendMode.multiply;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: overlayColor,
        backgroundBlendMode: blendMode,
      ),
    );
  }

  Widget _buildContent(BuildContext context, String greeting, String intention, String buttonText, String quietText) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            // Zone 1: Greeting
            const SizedBox(height: 20),
            // Zone 1: Greeting - Removed
            if (greeting.isNotEmpty)
              Text(
                greeting,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryText.withOpacity(0.9),
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            
            if (intention.isNotEmpty || buttonText.isNotEmpty)
               const Spacer(),
            
            // Zone 2: Intention (Sankalpa) - Elegant Typography
            if (intention.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  intention,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Serif', // Fallback or use specific font if available
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            if (buttonText.isNotEmpty)
              const SizedBox(height: 48),

            // Zone 3: CTA
            if (buttonText.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                   if (widget.onBeginTap != null) {
                     widget.onBeginTap!();
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 6,
                  shadowColor: AppColors.warmOrange.withOpacity(0.4),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
              ),

            // Zone 4: Removed
          ],
        ),
      ),
    );
  }
}

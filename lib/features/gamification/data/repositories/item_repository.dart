import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/item_model.dart';

class ItemRepository {
  static final ItemRepository _instance = ItemRepository._internal();
  factory ItemRepository() => _instance;
  ItemRepository._internal();

  final _itemsController = StreamController<List<ItemModel>>.broadcast();

  Stream<List<ItemModel>> get itemsStream => _itemsController.stream;

  Future<List<ItemModel>> getAllItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString('user_items');

      if (itemsJson != null && itemsJson.isNotEmpty) {
        final List<dynamic> itemsList = jsonDecode(itemsJson);
        if (itemsList.isNotEmpty) {
          final items = itemsList
              .map((i) => ItemModel.fromJson(i as Map<String, dynamic>))
              .toList();
          _itemsController.add(items);
          return items;
        }
      }

      // Generate default items
      final defaultItems = _generateDefaultItems();
      await _saveItems(defaultItems);
      _itemsController.add(defaultItems);
      return defaultItems;
    } catch (e) {
      // Fallback on any error (corrupt JSON, etc.)
      final defaultItems = _generateDefaultItems();
      await _saveItems(defaultItems);
      _itemsController.add(defaultItems);
      return defaultItems;
    }
  }

  List<ItemModel> _generateDefaultItems() {
    return [
      // Food Items
      ItemModel(
        id: 'food_1',
        name: 'Simple Meal',
        type: ItemType.food,
        rarity: ItemRarity.common,
        coinCost: 50,
        imagePath: 'assets/images/food_simple.png',
        description: 'A simple meal for the sadhu',
      ),
      ItemModel(
        id: 'food_2',
        name: 'Traditional Thali',
        type: ItemType.food,
        rarity: ItemRarity.rare,
        coinCost: 200,
        imagePath: 'assets/images/food_thali.png',
        description: 'A complete traditional meal',
      ),
      ItemModel(
        id: 'food_3',
        name: 'Sacred Prashad',
        type: ItemType.food,
        rarity: ItemRarity.epic,
        coinCost: 500,
        imagePath: 'assets/images/food_prashad.png',
        description: 'Blessed food offering',
      ),

      // Clothes Items
      ItemModel(
        id: 'clothes_1',
        name: 'Simple Robe',
        type: ItemType.clothes,
        rarity: ItemRarity.common,
        coinCost: 100,
        imagePath: 'assets/images/clothes_robe.png',
        description: 'A simple saffron robe',
      ),
      ItemModel(
        id: 'clothes_2',
        name: 'Traditional Dhoti',
        type: ItemType.clothes,
        rarity: ItemRarity.rare,
        coinCost: 300,
        imagePath: 'assets/images/clothes_dhoti.png',
        description: 'Traditional Indian garment',
      ),

      // Furniture Items
      ItemModel(
        id: 'furniture_1',
        name: 'Low Shelf',
        type: ItemType.furniture,
        rarity: ItemRarity.common,
        coinCost: 180,
        imagePath: 'assets/images/furniture_shelf.png',
        description: 'A simple wooden shelf for books',
      ),
      ItemModel(
        id: 'furniture_2',
        name: 'Big Bookshelf',
        type: ItemType.furniture,
        rarity: ItemRarity.rare,
        coinCost: 400,
        imagePath: 'assets/images/furniture_bookshelf.png',
        description: 'A large bookshelf for scriptures',
      ),
      ItemModel(
        id: 'furniture_3',
        name: 'Prayer Mat',
        type: ItemType.furniture,
        rarity: ItemRarity.common,
        coinCost: 150,
        imagePath: 'assets/images/furniture_mat.png',
        description: 'A simple prayer mat',
      ),

      // Shelter Upgrades
      ItemModel(
        id: 'shelter_1',
        name: 'Modern House',
        type: ItemType.shelter,
        rarity: ItemRarity.rare,
        coinCost: 500,
        imagePath: 'assets/images/shelter_modern.png',
        description: 'Upgrade to a modern house',
      ),
      ItemModel(
        id: 'shelter_2',
        name: 'Traditional Indian Home',
        type: ItemType.shelter,
        rarity: ItemRarity.epic,
        coinCost: 1000,
        imagePath: 'assets/images/shelter_traditional.png',
        description: 'A beautiful traditional Indian home',
      ),
    ];
  }

  Future<void> unlockItem(String itemId) async {
    final items = await getAllItems();
    final updatedItems = items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
      return item;
    }).toList();

    await _saveItems(updatedItems);
    _itemsController.add(updatedItems);
  }

  Future<void> _saveItems(List<ItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString('user_items', itemsJson);
  }

  List<ItemModel> getItemsByType(ItemType type) {
    // This will be async in real implementation
    return [];
  }

  List<ItemModel> getItemsByRarity(ItemRarity rarity) {
    // This will be async in real implementation
    return [];
  }

  void dispose() {
    _itemsController.close();
  }
}

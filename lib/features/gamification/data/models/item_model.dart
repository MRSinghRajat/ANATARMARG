enum ItemType {
  food,
  clothes,
  furniture,
  shelter,
}

enum ItemRarity {
  common,
  rare,
  epic,
}

extension ShopItemRarityCopy on ItemRarity {
  String get displayName {
    switch (this) {
      case ItemRarity.common:
        return 'Traditional';
      case ItemRarity.rare:
        return 'Festival';
      case ItemRarity.epic:
        return 'Sacred';
    }
  }
}

class ItemModel {
  final String id;
  final String name;
  final ItemType type;
  final ItemRarity rarity;
  final int coinCost;
  final String imagePath;
  final String description;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.coinCost,
    required this.imagePath,
    required this.description,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ItemType.furniture,
      ),
      rarity: ItemRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => ItemRarity.common,
      ),
      coinCost: json['coinCost'] as int,
      imagePath: json['imagePath'] as String,
      description: json['description'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'rarity': rarity.name,
      'coinCost': coinCost,
      'imagePath': imagePath,
      'description': description,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  ItemModel copyWith({
    String? id,
    String? name,
    ItemType? type,
    ItemRarity? rarity,
    int? coinCost,
    String? imagePath,
    String? description,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      coinCost: coinCost ?? this.coinCost,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

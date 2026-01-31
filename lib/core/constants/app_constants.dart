class AppConstants {
  // App Information
  static const String appName = 'Antar Marg';
  static const String appTagline = 'The Inner Path';
  
  // Books
  static const List<String> availableBooks = [
    'Mahabharata',
    'Ramayan',
    'Bhagavad Gita',
  ];
  
  // Daily Tasks
  static const List<String> dailyTaskTypes = [
    'water',
    'prayer',
    'food',
  ];
  
  // Task Names
  static const Map<String, String> taskNames = {
    'water': 'Water Task',
    'prayer': 'Prayer Task',
    'food': 'Food Task',
  };
  
  // Task Descriptions
  static const Map<String, String> taskDescriptions = {
    'water': 'Read scripture to provide water for the sadhu',
    'prayer': 'Read scripture to enable the sadhu\'s prayer',
    'food': 'Read scripture to provide food for the sadhu',
  };
  
  // Item Types
  static const List<String> itemTypes = [
    'food',
    'clothes',
    'furniture',
    'shelter',
  ];
  
  // Item Rarity
  static const List<String> itemRarities = [
    'common',
    'rare',
    'epic',
  ];
}

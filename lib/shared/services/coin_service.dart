import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class CoinService {
  static final CoinService _instance = CoinService._internal();
  factory CoinService() => _instance;
  CoinService._internal();

  final _coinController = StreamController<int>.broadcast();
  int _currentBalance = 0;
  int _lifetimeEarned = 0;

  Stream<int> get coinStream => _coinController.stream;
  int get currentBalance => _currentBalance;
  int get lifetimeEarned => _lifetimeEarned;

  /// Starting coins for first-run / testing (when no balance saved yet)
  static const int _startingCoinsForTest = 500;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBalance = prefs.getInt('coin_balance');
    if (savedBalance == null) {
      _currentBalance = _startingCoinsForTest;
      _lifetimeEarned = _startingCoinsForTest;
      await prefs.setInt('coin_balance', _currentBalance);
      await prefs.setInt('lifetime_coins', _lifetimeEarned);
    } else {
      _currentBalance = savedBalance;
      _lifetimeEarned = prefs.getInt('lifetime_coins') ?? 0;
    }
    _coinController.add(_currentBalance);
  }

  /// Grant test coins for development (e.g. in Ashram)
  Future<void> grantTestCoins(int amount) async {
    await addCoins(amount, reason: 'test');
  }

  Future<void> addCoins(int amount, {String? reason}) async {
    _currentBalance += amount;
    _lifetimeEarned += amount;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coin_balance', _currentBalance);
    await prefs.setInt('lifetime_coins', _lifetimeEarned);

    _coinController.add(_currentBalance);
  }

  Future<bool> spendCoins(int amount) async {
    if (_currentBalance >= amount) {
      _currentBalance -= amount;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('coin_balance', _currentBalance);

      _coinController.add(_currentBalance);
      return true;
    }
    return false;
  }

  void dispose() {
    _coinController.close();
  }
}

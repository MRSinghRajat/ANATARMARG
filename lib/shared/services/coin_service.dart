import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/supabase_config.dart';
import '../../core/services/supabase_service.dart';

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

  /// Starting coins for first-run (when no balance saved yet). Use 500 for testing; production can use 0.
  static const int _startingCoinsForTest = 500;

  String get _userPrefix {
    final uid = SupabaseService().currentUserId;
    return (uid != null && uid.isNotEmpty) ? uid : 'guest';
  }

  String get _prefBalance => 'coin_balance_$_userPrefix';
  String get _prefLifetime => 'lifetime_coins_$_userPrefix';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = SupabaseService().currentUserId;
    final prefix = _userPrefix;

    if (uid != null && uid.isNotEmpty) {
      try {
        final client = SupabaseService().client;
        if (client != null) {
          final res = await client
              .from(SupabaseConfig.avatarsTable)
              .select('karma_balance')
              .eq('user_id', uid)
              .maybeSingle();
          if (res != null && res is Map) {
            final k = res['karma_balance'];
            final fromServer = (k is int) ? k : (k is num) ? k.toInt() : 0;
            final savedBalance = prefs.getInt('coin_balance_$prefix');
            if (fromServer > 0) {
              _currentBalance = fromServer;
              _lifetimeEarned = fromServer;
            } else if (savedBalance != null && savedBalance > 0) {
              _currentBalance = savedBalance;
              _lifetimeEarned = prefs.getInt('lifetime_coins_$prefix') ?? savedBalance;
              await client.from(SupabaseConfig.avatarsTable).upsert({
                'user_id': uid,
                'karma_balance': _currentBalance,
                'updated_at': DateTime.now().toUtc().toIso8601String(),
              }, onConflict: 'user_id');
            } else {
              _currentBalance = 0;
              _lifetimeEarned = 0;
            }
            await prefs.setInt('coin_balance_$prefix', _currentBalance);
            await prefs.setInt('lifetime_coins_$prefix', _lifetimeEarned);
            _coinController.add(_currentBalance);
            return;
          }
          final savedBalance = prefs.getInt('coin_balance_$prefix');
          if (savedBalance != null && savedBalance > 0) {
            _currentBalance = savedBalance;
            _lifetimeEarned = prefs.getInt('lifetime_coins_$prefix') ?? savedBalance;
            try {
              await client.from(SupabaseConfig.avatarsTable).upsert({
                'user_id': uid,
                'karma_balance': _currentBalance,
                'updated_at': DateTime.now().toUtc().toIso8601String(),
              }, onConflict: 'user_id');
            } catch (_) {}
            await prefs.setInt('coin_balance_$prefix', _currentBalance);
            await prefs.setInt('lifetime_coins_$prefix', _lifetimeEarned);
            _coinController.add(_currentBalance);
            return;
          }
          _currentBalance = 0;
          _lifetimeEarned = 0;
          await prefs.setInt('coin_balance_$prefix', 0);
          await prefs.setInt('lifetime_coins_$prefix', 0);
          _coinController.add(_currentBalance);
          return;
        }
      } catch (e) {
        print('CoinService: error loading karma from Supabase: $e');
      }
    }

    final savedBalance = prefs.getInt('coin_balance_$prefix');
    if (savedBalance == null) {
      _currentBalance = _startingCoinsForTest;
      _lifetimeEarned = _startingCoinsForTest;
      await prefs.setInt('coin_balance_$prefix', _currentBalance);
      await prefs.setInt('lifetime_coins_$prefix', _lifetimeEarned);
    } else {
      _currentBalance = savedBalance;
      _lifetimeEarned = prefs.getInt('lifetime_coins_$prefix') ?? 0;
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
    final prefix = _userPrefix;
    await prefs.setInt('coin_balance_$prefix', _currentBalance);
    await prefs.setInt('lifetime_coins_$prefix', _lifetimeEarned);

    final uid = SupabaseService().currentUserId;
    if (uid != null && uid.isNotEmpty) {
      try {
        final client = SupabaseService().client;
        if (client != null) {
          await client.from(SupabaseConfig.avatarsTable).upsert({
            'user_id': uid,
            'karma_balance': _currentBalance,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }, onConflict: 'user_id');
        }
      } catch (e) {
        print('CoinService: error syncing karma to Supabase: $e');
      }
    }

    _coinController.add(_currentBalance);
  }

  Future<bool> spendCoins(int amount) async {
    if (_currentBalance >= amount) {
      _currentBalance -= amount;

      final prefs = await SharedPreferences.getInstance();
      final prefix = _userPrefix;
      await prefs.setInt('coin_balance_$prefix', _currentBalance);

      final uid = SupabaseService().currentUserId;
      if (uid != null && uid.isNotEmpty) {
        try {
          final client = SupabaseService().client;
          if (client != null) {
            await client.from(SupabaseConfig.avatarsTable).upsert({
              'user_id': uid,
              'karma_balance': _currentBalance,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            }, onConflict: 'user_id');
          }
        } catch (e) {
          print('CoinService: error syncing karma to Supabase: $e');
        }
      }

      _coinController.add(_currentBalance);
      return true;
    }
    return false;
  }

  /// If user has spiritual level but karma is 0 (e.g. migrated data), set minimum karma from level and sync.
  Future<void> ensureMinimumKarmaForLevel(int level) async {
    if (level < 1) return;
    const karmaPerLevel = 50;
    final minimum = level * karmaPerLevel;
    if (_currentBalance >= minimum) return;
    _currentBalance = minimum;
    _lifetimeEarned = _lifetimeEarned < minimum ? minimum : _lifetimeEarned;
    final prefs = await SharedPreferences.getInstance();
    final prefix = _userPrefix;
    await prefs.setInt(_prefBalance, _currentBalance);
    await prefs.setInt(_prefLifetime, _lifetimeEarned);
    final uid = SupabaseService().currentUserId;
    if (uid != null && uid.isNotEmpty) {
      try {
        final client = SupabaseService().client;
        if (client != null) {
          await client.from(SupabaseConfig.avatarsTable).upsert({
            'user_id': uid,
            'karma_balance': _currentBalance,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }, onConflict: 'user_id');
        }
      } catch (e) {
        print('CoinService: error syncing karma to Supabase: $e');
      }
    }
    _coinController.add(_currentBalance);
  }

  /// Zero in-memory balance, then reload for the current (or guest) user prefix.
  Future<void> resetSession() async {
    _currentBalance = 0;
    _lifetimeEarned = 0;
    _coinController.add(0);
    await initialize();
  }

  void dispose() {
    _coinController.close();
  }
}

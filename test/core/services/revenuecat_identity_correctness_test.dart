import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:antarmarg/core/services/revenuecat_service.dart';
import 'package:antarmarg/shared/services/premium_service.dart';

Map<String, dynamic> _entitlementInfoJson({
  required String entitlementId,
  required bool isActive,
  String productId = 'yearly',
}) {
  final now = DateTime.utc(2026, 1, 1, 0, 0, 0).toIso8601String();
  return {
    'identifier': entitlementId,
    'isActive': isActive,
    'willRenew': true,
    'latestPurchaseDate': now,
    'originalPurchaseDate': now,
    'productIdentifier': productId,
    'isSandbox': true,
    'ownershipType': 'PURCHASED',
    'store': 'APP_STORE',
    'periodType': 'NORMAL',
    'expirationDate': isActive ? DateTime.utc(2027, 1, 1).toIso8601String() : null,
    'unsubscribeDetectedAt': null,
    'billingIssueDetectedAt': null,
    'productPlanIdentifier': null,
    'verification': 'NOT_REQUESTED',
  };
}

Map<String, dynamic> _customerInfoJson({
  required String originalAppUserId,
  required String entitlementId,
  required bool isEntitled,
}) {
  final now = DateTime.utc(2026, 1, 1, 0, 0, 0).toIso8601String();
  final ent = _entitlementInfoJson(
    entitlementId: entitlementId,
    isActive: isEntitled,
  );
  return {
    'entitlements': {
      'all': {entitlementId: ent},
      'active': isEntitled ? {entitlementId: ent} : <String, dynamic>{},
      'verification': 'NOT_REQUESTED',
    },
    'allPurchaseDates': <String, dynamic>{},
    'activeSubscriptions': <dynamic>[],
    'allPurchasedProductIdentifiers': <dynamic>[],
    'nonSubscriptionTransactions': <dynamic>[],
    'firstSeen': now,
    'originalAppUserId': originalAppUserId,
    'allExpirationDates': <String, dynamic>{},
    'requestDate': now,
    'latestExpirationDate': null,
    'originalPurchaseDate': null,
    'originalApplicationVersion': null,
    'managementURL': null,
  };
}

Future<void> _sendCustomerInfoUpdated({
  required Map<String, dynamic> customerInfoJson,
}) async {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final codec = const StandardMethodCodec();
  final call = MethodCall('Purchases-CustomerInfoUpdated', customerInfoJson);
  final completer = Completer<void>();
  messenger.handlePlatformMessage(
    'purchases_flutter',
    codec.encodeMethodCall(call),
    (_) => completer.complete(),
  );
  await completer.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('purchases_flutter');
  const entitlementId = 'Antar marg Pro';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(
      fileInput: 'REVENUECAT_API_KEY=appl_test_key\nREVENUECAT_ENTITLEMENT_ID=$entitlementId\n',
    );
  });

  tearDown(() async {
    channel.setMockMethodCallHandler(null);
    // Reset test override (important if a test sets it).
    PremiumService.isReleaseBuild = () => kReleaseMode;
    RevenueCatService.instance.dispose();
  });

  group('L05 RevenueCat identity correctness', () {
    test('SDK init calls setupPurchases and leaves identity guest until synced', () async {
      var setupCalls = 0;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'setLogLevel') return null;
        if (call.method == 'setupPurchases') {
          setupCalls += 1;
          return null;
        }
        if (call.method == 'getOfferings') {
          return {'all': <String, dynamic>{}, 'current': null};
        }
        throw MissingPluginException('Unhandled ${call.method}');
      });

      final service = RevenueCatService.instance;
      await service.initialize();

      expect(setupCalls, 1);
      expect(service.isInitialized, isTrue);
      expect(service.identityState, RevenueCatIdentityState.guest);
      expect(service.hasSyncedUser, isFalse);
      expect(await service.isPremium(), isFalse, reason: 'Guest should be fail-closed for premium.');
    });

    test('A→B switch: serialized logIn ignores delayed result for A', () async {
      final service = RevenueCatService.instance;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'setLogLevel') return null;
        if (call.method == 'setupPurchases') return null;
        if (call.method == 'getOfferings') {
          return {'all': <String, dynamic>{}, 'current': null};
        }
        if (call.method == 'logIn') {
          final appUserId = (call.arguments as Map)['appUserID'] as String;
          if (appUserId == 'user-a') {
            // Delay A so B completes first.
            await Future<void>.delayed(const Duration(milliseconds: 80));
          }
          return {
            'customerInfo': _customerInfoJson(
              originalAppUserId: appUserId,
              entitlementId: entitlementId,
              isEntitled: appUserId == 'user-b',
            ),
            'created': false,
          };
        }
        throw MissingPluginException('Unhandled ${call.method}');
      });

      await service.initialize();

      final a = service.syncIdentity('user-a');
      final bOk = await service.syncIdentity('user-b');
      final aOk = await a;

      expect(bOk, isTrue);
      expect(aOk, isFalse, reason: 'Delayed A should be superseded by B.');
      expect(service.identityState, RevenueCatIdentityState.synced);
      expect(service.syncedUserId, 'user-b');
      expect(service.customerInfo?.originalAppUserId, 'user-b');
      expect(service.hasAnyPaidEntitlement(service.customerInfo), isTrue);
    });

    test('sign-out during pending sign-in keeps premium fail-closed and does not apply stale A', () async {
      final service = RevenueCatService.instance;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'setLogLevel') return null;
        if (call.method == 'setupPurchases') return null;
        if (call.method == 'getOfferings') {
          return {'all': <String, dynamic>{}, 'current': null};
        }
        if (call.method == 'logIn') {
          final appUserId = (call.arguments as Map)['appUserID'] as String;
          await Future<void>.delayed(const Duration(milliseconds: 80));
          return {
            'customerInfo': _customerInfoJson(
              originalAppUserId: appUserId,
              entitlementId: entitlementId,
              isEntitled: true,
            ),
            'created': false,
          };
        }
        if (call.method == 'logOut') {
          return _customerInfoJson(
            originalAppUserId: 'anonymous',
            entitlementId: entitlementId,
            isEntitled: false,
          );
        }
        throw MissingPluginException('Unhandled ${call.method}');
      });

      await service.initialize();

      final pending = service.syncIdentity('user-a');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await service.logOut();
      final pendingOk = await pending;

      expect(pendingOk, isFalse);
      expect(service.identityState, RevenueCatIdentityState.guest);
      expect(service.hasSyncedUser, isFalse);
      expect(await service.isPremium(), isFalse);
    });

    test('failed identify then retry succeeds; only success marks synced', () async {
      final service = RevenueCatService.instance;
      var attempt = 0;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'setLogLevel') return null;
        if (call.method == 'setupPurchases') return null;
        if (call.method == 'getOfferings') {
          return {'all': <String, dynamic>{}, 'current': null};
        }
        if (call.method == 'logIn') {
          attempt += 1;
          if (attempt == 1) {
            throw PlatformException(code: 'NETWORK_ERROR', message: 'fail');
          }
          final appUserId = (call.arguments as Map)['appUserID'] as String;
          return {
            'customerInfo': _customerInfoJson(
              originalAppUserId: appUserId,
              entitlementId: entitlementId,
              isEntitled: true,
            ),
            'created': false,
          };
        }
        throw MissingPluginException('Unhandled ${call.method}');
      });

      await service.initialize();

      final first = await service.syncIdentity('user-a');
      expect(first, isFalse);
      expect(service.identityState, RevenueCatIdentityState.failed);
      expect(service.hasSyncedUser, isFalse);

      final second = await service.syncIdentity('user-a');
      expect(second, isTrue);
      expect(service.identityState, RevenueCatIdentityState.synced);
      expect(service.syncedUserId, 'user-a');
    });

    test('stale Purchases-CustomerInfoUpdated callbacks are ignored when not synced', () async {
      final service = RevenueCatService.instance;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'setLogLevel') return null;
        if (call.method == 'setupPurchases') return null;
        if (call.method == 'getOfferings') {
          return {'all': <String, dynamic>{}, 'current': null};
        }
        throw MissingPluginException('Unhandled ${call.method}');
      });

      await service.initialize();
      expect(service.identityState, RevenueCatIdentityState.guest);

      final emitted = <bool>[];
      final sub = service.subscriptionStatusStream.listen(emitted.add);

      await _sendCustomerInfoUpdated(
        customerInfoJson: _customerInfoJson(
          originalAppUserId: 'some-other',
          entitlementId: entitlementId,
          isEntitled: true,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 5));
      await sub.cancel();

      expect(emitted.contains(true), isFalse, reason: 'Guest state must ignore premium updates.');
    });

    test('restore is blocked until identity synced', () async {
      final service = RevenueCatService.instance;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'setLogLevel') return null;
        if (call.method == 'setupPurchases') return null;
        if (call.method == 'getOfferings') {
          return {'all': <String, dynamic>{}, 'current': null};
        }
        if (call.method == 'restorePurchases') {
          return _customerInfoJson(
            originalAppUserId: 'user-a',
            entitlementId: entitlementId,
            isEntitled: true,
          );
        }
        if (call.method == 'logIn') {
          final appUserId = (call.arguments as Map)['appUserID'] as String;
          return {
            'customerInfo': _customerInfoJson(
              originalAppUserId: appUserId,
              entitlementId: entitlementId,
              isEntitled: true,
            ),
            'created': false,
          };
        }
        throw MissingPluginException('Unhandled ${call.method}');
      });

      await service.initialize();
      final before = await service.restorePurchases();
      expect(before.success, isFalse);
      expect(before.errorMessage, contains('sign in'));

      final ok = await service.syncIdentity('user-a');
      expect(ok, isTrue);
      final after = await service.restorePurchases();
      expect(after.success, isTrue);
      expect(after.isPremium, isTrue);
    });
  });

  group('L05 PremiumService release dev override rejection', () {
    test('premium_dev_mode override is ignored when isReleaseBuild() is true', () async {
      SharedPreferences.setMockInitialValues({
        'premium_dev_mode': true,
        'is_premium_override': true,
      });
      PremiumService.isReleaseBuild = () => true;

      final premium = PremiumService.instance;
      await premium.initialize();

      expect(premium.isDevModeEnabled, isFalse);
      expect(await premium.isPremium, isFalse);
    });
  });
}


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../../core/services/app_analytics.dart';
import '../../../../core/services/revenuecat_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../shared/services/premium_service.dart';
import '../../data/models/subscription_models.dart';
import 'customer_center_screen.dart';

/// Paywall screen that displays subscription options.
///
/// **RevenueCat dashboard paywalls** use [RevenueCatUI.presentPaywall] (see
/// [showRevenueCatPaywallOrCustom]). [showAsBottomSheet] / [PaywallScreen] alone
/// is the **custom Flutter** UI built in this file, not the RC Paywalls v2 UI.
class PaywallScreen extends StatefulWidget {
  /// If true, shows a close button to dismiss the paywall
  final bool showCloseButton;
  
  /// Callback when subscription is successful
  final VoidCallback? onSubscriptionSuccess;
  
  /// Callback when user dismisses the paywall
  final VoidCallback? onDismiss;

  const PaywallScreen({
    super.key,
    this.showCloseButton = true,
    this.onSubscriptionSuccess,
    this.onDismiss,
  });

  /// Show paywall as a modal bottom sheet
  static Future<bool?> showAsBottomSheet(BuildContext context) {
    AppAnalytics.logPaywallViewed(source: 'custom_sheet');
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: PaywallScreen(
            showCloseButton: true,
            onSubscriptionSuccess: () => Navigator.pop(context, true),
            onDismiss: () => Navigator.pop(context, false),
          ),
        ),
      ),
    );
  }

  /// Show paywall as a full screen dialog
  static Future<bool?> showAsDialog(BuildContext context) {
    AppAnalytics.logPaywallViewed(source: 'custom_dialog');
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => PaywallScreen(
          showCloseButton: true,
          onSubscriptionSuccess: () => Navigator.pop(context, true),
          onDismiss: () => Navigator.pop(context, false),
        ),
      ),
    );
  }

  /// Presents the **RevenueCat Paywall** (designed in the RC dashboard) first.
  /// Falls back to [showAsBottomSheet] (custom UI) if RevenueCat is not
  /// initialized, throws, or returns [PaywallResult.error].
  ///
  /// **Dashboard:** The template you edit in RevenueCat is tied to the **Offering**
  /// that has your products. Set that Offering as **Current** and attach your
  /// Paywall to it — otherwise the SDK may show an older template or fallback UI.
  ///
  /// Returns `true` if the user purchased or restored; `false` if they
  /// dismissed without a new purchase; `null` if the sheet was dismissed
  /// without a result.
  static Future<bool?> showRevenueCatPaywallOrCustom(BuildContext context) async {
    await AppAnalytics.logPaywallViewed(source: 'revenuecat');
    final rc = RevenueCatService.instance;
    if (!rc.isInitialized) {
      try {
        await rc.initialize();
      } catch (e) {
        debugPrint('Paywall: RevenueCat init before native paywall: $e');
      }
    }

    if (rc.isInitialized) {
      try {
        await rc.refreshOfferings();
        final offering = rc.effectiveOffering;
        debugPrint(
          'Paywall: RevenueCat native UI — offering="${offering?.identifier}" '
          'packages=${offering?.availablePackages.length ?? 0}',
        );
        if (offering == null || offering.availablePackages.isEmpty) {
          debugPrint(
            'Paywall: No offering or packages — Store prices will not load. '
            'Check RevenueCat Offering (Current) and App Store product IDs.',
          );
        }
        final result = await RevenueCatUI.presentPaywall(
          displayCloseButton: true,
          offering: offering,
        );
        await PremiumService.instance.refreshPremiumStatus();
        if (result == PaywallResult.purchased ||
            result == PaywallResult.restored) {
          if (result == PaywallResult.purchased) {
            await AppAnalytics.logPurchaseCompleted();
          }
          return true;
        }
        if (result == PaywallResult.error) {
          debugPrint('Paywall: Native paywall error, showing custom UI');
          if (!context.mounted) return false;
          return showAsBottomSheet(context);
        }
        return false;
      } catch (e, st) {
        debugPrint('Paywall: Native paywall exception: $e\n$st');
      }
    }

    if (!context.mounted) return null;
    return showAsBottomSheet(context);
  }

  /// Present RevenueCat's native paywall (if configured in dashboard)
  static Future<PaywallResult> presentRevenueCatPaywall() async {
    try {
      return await RevenueCatUI.presentPaywall();
    } catch (e) {
      debugPrint('RevenueCat Paywall error: $e');
      return PaywallResult.error;
    }
  }

  /// Present RevenueCat's native paywall for a specific offering
  static Future<PaywallResult> presentPaywallForOffering(Offering offering) async {
    try {
      return await RevenueCatUI.presentPaywallIfNeeded(
        offering.identifier,
      );
    } catch (e) {
      debugPrint('RevenueCat Paywall error: $e');
      return PaywallResult.error;
    }
  }

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

/// Shown when RevenueCat returns no packages (dashboard / App Store Connect setup).
const String _kEmptyOfferingsMessage =
    'No subscription plans are available yet.\n\n'
    'For TestFlight: in App Store Connect, create subscriptions with the same '
    'product IDs as in RevenueCat → Product catalog, sign the Paid Applications '
    'Agreement, and attach those products to an Offering (set it as Current). '
    'Then try again.';

class _PaywallScreenState extends State<PaywallScreen> {
  final RevenueCatService _revenueCat = RevenueCatService.instance;
  final PremiumService _premiumService = PremiumService.instance;

  List<SubscriptionPlan> _plans = [];
  SubscriptionPlan? _selectedPlan;
  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _isRedeemingCoupon = false;
  bool _isPremium = false;
  String? _error;
  StreamSubscription<bool>? _premiumSubscription;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
    _premiumService.isPremium.then((v) {
      if (mounted) setState(() => _isPremium = v);
    });
    _premiumSubscription = _premiumService.premiumStatusStream.listen((v) {
      if (mounted) setState(() => _isPremium = v);
    });
  }

  @override
  void dispose() {
    _premiumSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (!_revenueCat.isInitialized) {
        try {
          await RevenueCatService.instance.initialize();
        } catch (e) {
          debugPrint('Paywall: RevenueCat init before offerings: $e');
        }
      }
      await _revenueCat.refreshOfferings();
      final packages = _revenueCat.availablePackages;

      if (packages.isEmpty) {
        setState(() {
          _error = _kEmptyOfferingsMessage;
          _isLoading = false;
        });
        return;
      }

      final plans = packages
          .map((p) => SubscriptionPlan.fromPackage(p))
          .toList();

      // Sort: monthly, yearly, lifetime
      plans.sort((a, b) {
        const order = {
          SubscriptionPlanType.monthly: 0,
          SubscriptionPlanType.yearly: 1,
          SubscriptionPlanType.lifetime: 2,
        };
        return order[a.type]!.compareTo(order[b.type]!);
      });

      setState(() {
        _plans = plans;
        // Default select yearly (best value)
        _selectedPlan = plans.firstWhere(
          (p) => p.isBestValue,
          orElse: () => plans.first,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = _friendlyOfferingsError(e);
        _isLoading = false;
      });
    }
  }

  /// User-friendly message when offerings fail (e.g. RevenueCat/App Store config not ready).
  static String _friendlyOfferingsError(Object e) {
    final s = e.toString();
    if (s.contains('CONFIGURATION_ERROR') ||
        s.contains('configuration') && s.contains('could not be fetched') ||
        s.contains('None of the products')) {
      return 'Subscription plans are not available right now. '
          'You can try "Restore" if you already have a subscription, or try again later.';
    }
    if (s.contains('network') || s.contains('Connection')) {
      return 'Unable to load plans. Please check your connection and try again.';
    }
    return 'We couldn\'t load subscription options. Try "Restore" if you already subscribed, or try again later.';
  }

  Future<void> _purchase() async {
    if (_selectedPlan?.package == null) return;

    setState(() => _isPurchasing = true);

    try {
      final result = await _revenueCat.purchasePackage(_selectedPlan!.package!);
      
      if (result.success && result.isPremium) {
        widget.onSubscriptionSuccess?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome to Antar मार्ग Pro! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (result.cancelled) {
        // User cancelled - do nothing
      } else if (result.errorMessage != null) {
        _showError(result.errorMessage!);
      }
    } catch (e) {
      _showError('Purchase failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);

    try {
      final result = await _revenueCat.restorePurchases();
      
      if (result.success && result.isPremium) {
        widget.onSubscriptionSuccess?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchases restored successfully! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (result.success && !result.restoredPurchases) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No previous purchases found'),
            ),
          );
        }
      } else if (result.errorMessage != null) {
        _showError(result.errorMessage!);
      }
    } catch (e) {
      _showError('Restore failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _redeemCoupon() async {
    setState(() => _isRedeemingCoupon = true);
    try {
      await _revenueCat.presentCodeRedemptionSheet();
      await _premiumService.refreshPremiumStatus();
      final isNowPremium = await _premiumService.isPremium;
      if (mounted) {
        if (isNowPremium) {
          widget.onSubscriptionSuccess?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Offer code applied! Welcome to Pro 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('If you redeemed a code, your subscription may take a moment to appear. Try Restore if needed.'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) _showError('Could not open redeem: $e');
    } finally {
      if (mounted) setState(() => _isRedeemingCoupon = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    )
                  : _error != null
                      ? _buildError()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (widget.showCloseButton)
            IconButton(
              onPressed: widget.onDismiss ?? () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          TextButton(
            onPressed: (_isPurchasing || _isRedeemingCoupon) ? null : _redeemCoupon,
            child: Text(
              'Redeem Code',
              style: GoogleFonts.poppins(
                color: AppColors.primaryOrange,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: (_isPurchasing || _isRedeemingCoupon) ? null : _restore,
            child: Text(
              'Restore',
              style: GoogleFonts.poppins(
                color: AppColors.primaryOrange,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadOfferings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Premium member banner (paywall enabled for premium users too)
          if (_isPremium) _buildPremiumBanner(),
          if (_isPremium) const SizedBox(height: 16),
          // Title and subtitle
          _buildTitle(),
          const SizedBox(height: 24),
          
          // Features list
          _buildFeatures(),
          const SizedBox(height: 32),
          
          // Plan selection
          _buildPlanSelection(),
          const SizedBox(height: 24),
          
          // Purchase button
          _buildPurchaseButton(),
          const SizedBox(height: 16),
          // Coupon / offer code
          _buildCouponSection(),
          const SizedBox(height: 16),
          // Terms
          _buildTerms(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Premium badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryOrange.withOpacity(0.2),
                Colors.amber.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryOrange.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'ANTAR MARG PRO',
                style: GoogleFonts.poppins(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        Text(
          'Unlock Your Full\nSpiritual Journey',
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        
        Text(
          'Get unlimited access to all features and content',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: PremiumFeatures.features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  feature.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        feature.description,
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlanSelection() {
    return Column(
      children: _plans.map((plan) {
        final isSelected = _selectedPlan?.id == plan.id;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedPlan = plan),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        AppColors.primaryOrange.withOpacity(0.2),
                        AppColors.primaryOrange.withOpacity(0.1),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryOrange
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : Colors.white54,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Plan details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (plan.savings != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: plan.isBestValue
                                    ? Colors.green
                                    : AppColors.primaryOrange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                plan.savings!,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plan.description,
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.priceString ?? '',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      plan.period ?? '',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPurchaseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPurchasing ? null : _purchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isPurchasing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Continue with ${_selectedPlan?.title ?? 'Plan'}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CustomerCenterScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You\'re a Pro member',
                    style: GoogleFonts.poppins(
                      color: Colors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Tap to manage subscription',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    return OutlinedButton.icon(
      onPressed: (_isPurchasing || _isRedeemingCoupon)
          ? null
          : _redeemCoupon,
      icon: _isRedeemingCoupon
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            )
          : const Icon(Icons.card_giftcard_outlined, size: 20),
      label: Text(
        _isRedeemingCoupon ? 'Redeeming…' : 'Have a coupon? Redeem offer code',
        style: GoogleFonts.poppins(fontSize: 14),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildTerms() {
    return Column(
      children: [
        Text(
          'Cancel anytime. Subscriptions auto-renew until cancelled.',
          style: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.termsOfService);
              },
              child: Text(
                'Terms of Use',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' • ',
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.privacyPolicy);
              },
              child: Text(
                'Privacy Policy',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Route used by [AppRouter.paywall]: presents RevenueCat’s dashboard paywall (then pops).
///
/// Navigating to `/paywall` used to build [PaywallScreen] directly, which is **only** the old
/// custom Flutter UI and **never** loads your RevenueCat Paywall v2 design.
class PaywallRouteScreen extends StatefulWidget {
  const PaywallRouteScreen({super.key});

  @override
  State<PaywallRouteScreen> createState() => _PaywallRouteScreenState();
}

class _PaywallRouteScreenState extends State<PaywallRouteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  Future<void> _open() async {
    if (!mounted) return;
    final nav = Navigator.of(context);
    final result = await PaywallScreen.showRevenueCatPaywallOrCustom(context);
    if (!mounted) return;
    nav.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryOrange.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

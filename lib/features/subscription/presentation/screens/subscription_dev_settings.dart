import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/services/revenuecat_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/premium_service.dart';

/// Developer settings screen for testing subscriptions.
/// 
/// This screen allows developers to:
/// - Enable/disable dev mode
/// - Override premium status for testing
/// - View RevenueCat debug information
/// - Test purchases in sandbox mode
/// 
/// NOTE: This screen should only be accessible in debug/development builds.
class SubscriptionDevSettings extends StatefulWidget {
  const SubscriptionDevSettings({super.key});

  @override
  State<SubscriptionDevSettings> createState() => _SubscriptionDevSettingsState();
}

class _SubscriptionDevSettingsState extends State<SubscriptionDevSettings> {
  final RevenueCatService _revenueCat = RevenueCatService.instance;
  final PremiumService _premium = PremiumService.instance;
  
  bool _devModeEnabled = false;
  bool _isPremiumOverride = false;
  bool _isLoading = false;
  String? _appUserId;
  bool _isAnonymous = true;
  CustomerInfo? _customerInfo;
  Offerings? _offerings;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final appUserId = await _revenueCat.getAppUserId();
      final isAnonymous = await _revenueCat.isAnonymous();
      await _revenueCat.refreshCustomerInfo();
      await _revenueCat.refreshOfferings();

      if (mounted) {
        setState(() {
          _devModeEnabled = _premium.isDevModeEnabled;
          _appUserId = appUserId;
          _isAnonymous = isAnonymous;
          _customerInfo = _revenueCat.customerInfo;
          _offerings = _revenueCat.offerings;
          _isLoading = false;
        });
        
        // Get current premium override
        _premium.isPremium.then((value) {
          if (mounted) {
            setState(() => _isPremiumOverride = value);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Subscription Dev Settings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning banner
                  _buildWarningBanner(),
                  const SizedBox(height: 24),
                  
                  // Dev Mode Section
                  _buildSectionTitle('Development Mode'),
                  _buildDevModeCard(),
                  const SizedBox(height: 24),
                  
                  // User Info Section
                  _buildSectionTitle('RevenueCat User'),
                  _buildUserInfoCard(),
                  const SizedBox(height: 24),
                  
                  // Customer Info Section
                  if (_customerInfo != null) ...[
                    _buildSectionTitle('Customer Info'),
                    _buildCustomerInfoCard(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Offerings Section
                  if (_offerings != null) ...[
                    _buildSectionTitle('Offerings'),
                    _buildOfferingsCard(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Actions Section
                  _buildSectionTitle('Actions'),
                  _buildActionsCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This screen is for development only. Do not include in production builds.',
              style: GoogleFonts.poppins(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDevModeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Enable Dev Mode
          SwitchListTile(
            title: Text(
              'Enable Dev Mode',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            subtitle: Text(
              'Allows overriding premium status',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
            value: _devModeEnabled,
            activeThumbColor: AppColors.primaryOrange,
            onChanged: (value) async {
              if (value) {
                await _premium.enableDevMode();
              } else {
                await _premium.disableDevMode();
              }
              setState(() => _devModeEnabled = value);
            },
          ),
          
          if (_devModeEnabled) ...[
            const Divider(color: Colors.white12, height: 1),
            
            // Premium Override
            SwitchListTile(
              title: Text(
                'Premium Override',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              subtitle: Text(
                'Simulate premium subscription',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
              ),
              value: _isPremiumOverride,
              activeThumbColor: Colors.green,
              onChanged: (value) async {
                await _premium.setPremiumOverride(value);
                setState(() => _isPremiumOverride = value);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildInfoRow('App User ID', _appUserId ?? 'Not set', canCopy: true),
          const Divider(color: Colors.white12),
          _buildInfoRow('Anonymous', _isAnonymous ? 'Yes' : 'No'),
          const Divider(color: Colors.white12),
          _buildInfoRow('SDK Initialized', _revenueCat.isInitialized ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    final info = _customerInfo!;
    final entitlements = info.entitlements.all;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('First Seen', _formatDate(info.firstSeen)),
          const Divider(color: Colors.white12),
          _buildInfoRow('Active Subscriptions', info.activeSubscriptions.length.toString()),
          const Divider(color: Colors.white12),
          _buildInfoRow('Non-Subscriptions', info.nonSubscriptionTransactions.length.toString()),
          
          if (entitlements.isNotEmpty) ...[
            const Divider(color: Colors.white12),
            Text(
              'Entitlements:',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...entitlements.entries.map((e) => Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Row(
                children: [
                  Icon(
                    e.value.isActive ? Icons.check_circle : Icons.cancel,
                    color: e.value.isActive ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    e.key,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildOfferingsCard() {
    final offerings = _offerings!;
    final current = offerings.current;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Current Offering', current?.identifier ?? 'None'),
          
          if (current != null) ...[
            const Divider(color: Colors.white12),
            Text(
              'Packages:',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...current.availablePackages.map((p) => Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p.identifier,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    p.storeProduct.priceString,
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.white),
            title: Text(
              'Refresh Data',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            onTap: _loadData,
          ),
          const Divider(color: Colors.white12, height: 1),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.white),
            title: Text(
              'Restore Purchases',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            onTap: () async {
              final result = await _revenueCat.restorePurchases();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result.success
                          ? 'Restored: Premium = ${result.isPremium}'
                          : 'Restore failed: ${result.errorMessage}',
                    ),
                  ),
                );
                _loadData();
              }
            },
          ),
          const Divider(color: Colors.white12, height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Log Out User',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
            onTap: () async {
              await _revenueCat.logOut();
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          Row(
            children: [
              Text(
                value.length > 20 ? '${value.substring(0, 20)}...' : value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              if (canCopy)
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white38),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) return dateString;
    return '${date.day}/${date.month}/${date.year}';
  }
}

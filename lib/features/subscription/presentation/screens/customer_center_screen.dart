import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../../../core/services/revenuecat_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/subscription_models.dart';

/// Customer Center screen for managing subscriptions.
/// 
/// This screen allows users to:
/// - View their subscription status
/// - Manage/cancel subscriptions
/// - Contact support
/// - View FAQ
class CustomerCenterScreen extends StatefulWidget {
  const CustomerCenterScreen({super.key});

  /// Present RevenueCat's native Customer Center (if available)
  static Future<void> presentNativeCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('Customer Center error: $e');
      rethrow;
    }
  }

  @override
  State<CustomerCenterScreen> createState() => _CustomerCenterScreenState();
}

class _CustomerCenterScreenState extends State<CustomerCenterScreen> {
  final RevenueCatService _revenueCat = RevenueCatService.instance;
  
  SubscriptionStatus? _subscriptionStatus;
  bool _isLoading = true;
  String? _appUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final info = await _revenueCat.refreshCustomerInfo();
      final userId = await _revenueCat.getAppUserId();
      
      if (mounted) {
        setState(() {
          if (info != null) {
            _subscriptionStatus = SubscriptionStatus.fromCustomerInfo(
              info,
              'Antar marg Pro',
            );
          }
          _appUserId = userId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openManagementUrl() async {
    final managementUrl = _subscriptionStatus?.managementUrl ?? _revenueCat.managementUrl;
    
    if (managementUrl != null) {
      final uri = Uri.parse(managementUrl);
      if (await url_launcher.canLaunchUrl(uri)) {
        await url_launcher.launchUrl(uri, mode: url_launcher.LaunchMode.externalApplication);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open subscription management'),
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      final result = await _revenueCat.restorePurchases();
      
      if (mounted) {
        if (result.success && result.isPremium) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchases restored successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No purchases to restore'),
            ),
          );
        }
        
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _contactSupport() {
    // Open email client or support form
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@antarmarg.com',
      query: 'subject=Antar मार्ग Pro Support&body=User ID: $_appUserId',
    );
    url_launcher.launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Subscription',
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
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subscription Status Card
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  
                  // Subscription Details (if active)
                  if (_subscriptionStatus?.isActive == true) ...[
                    _buildDetailsCard(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Actions
                  _buildActionsCard(),
                  const SizedBox(height: 24),
                  
                  // Help & Support
                  _buildSupportCard(),
                  const SizedBox(height: 24),
                  
                  // User Info (for support)
                  if (_appUserId != null) _buildUserInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    final isActive = _subscriptionStatus?.isActive ?? false;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  Colors.green.withOpacity(0.2),
                  Colors.green.withOpacity(0.1),
                ]
              : [
                  Colors.grey.withOpacity(0.2),
                  Colors.grey.withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.star : Icons.star_border,
              color: isActive ? Colors.green : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'Antar मार्ग Pro' : 'Free Plan',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _subscriptionStatus?.statusText ?? 'Not subscribed',
                  style: GoogleFonts.poppins(
                    color: isActive ? Colors.green : Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ACTIVE',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    final status = _subscriptionStatus!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Details',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow(
            'Plan',
            _getPlanName(status.productId),
          ),
          
          if (!status.isLifetime && status.expirationDate != null) ...[
            const Divider(color: Colors.white12),
            _buildDetailRow(
              status.willRenew ? 'Renews on' : 'Expires on',
              _formatDate(status.expirationDate!),
            ),
          ],
          
          if (status.isLifetime) ...[
            const Divider(color: Colors.white12),
            _buildDetailRow(
              'Access',
              'Lifetime',
            ),
          ],
          
          if (status.isInTrial) ...[
            const Divider(color: Colors.white12),
            _buildDetailRow(
              'Status',
              'Free Trial',
              valueColor: Colors.blue,
            ),
          ],
          
          if (status.daysRemaining != null && !status.isLifetime) ...[
            const Divider(color: Colors.white12),
            _buildDetailRow(
              'Days remaining',
              '${status.daysRemaining} days',
              valueColor: status.daysRemaining! <= 3 ? Colors.orange : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: valueColor ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    final isActive = _subscriptionStatus?.isActive ?? false;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          if (isActive && _subscriptionStatus?.managementUrl != null)
            _buildActionTile(
              icon: Icons.settings,
              title: 'Manage Subscription',
              subtitle: 'Change or cancel your plan',
              onTap: _openManagementUrl,
            ),
          
          if (!isActive)
            _buildActionTile(
              icon: Icons.star,
              title: 'Upgrade to Pro',
              subtitle: 'Unlock all features',
              onTap: () => Navigator.pop(context, 'upgrade'),
              showArrow: true,
            ),
          
          _buildActionTile(
            icon: Icons.refresh,
            title: 'Restore Purchases',
            subtitle: 'Restore previous subscriptions',
            onTap: _restorePurchases,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.email_outlined,
            title: 'Contact Support',
            subtitle: 'Get help with your subscription',
            onTap: _contactSupport,
          ),
          _buildActionTile(
            icon: Icons.help_outline,
            title: 'FAQ',
            subtitle: 'Frequently asked questions',
            onTap: () {
              // Open FAQ
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryOrange,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              showArrow ? Icons.arrow_forward_ios : Icons.chevron_right,
              color: Colors.white38,
              size: showArrow ? 16 : 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.white24,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'User ID: ${_appUserId!.substring(0, 8)}...',
              style: GoogleFonts.poppins(
                color: Colors.white24,
                fontSize: 11,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Copy to clipboard
            },
            icon: const Icon(
              Icons.copy,
              color: Colors.white24,
              size: 16,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _getPlanName(String? productId) {
    if (productId == null) return 'Unknown';
    if (productId.contains('lifetime')) return 'Lifetime';
    if (productId.contains('year') || productId.contains('annual')) return 'Yearly';
    if (productId.contains('month')) return 'Monthly';
    return productId;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

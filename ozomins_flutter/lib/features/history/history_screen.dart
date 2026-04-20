import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/firestore_service.dart';
import '../../data/models/booking_model.dart';

/// Order History screen — Eco Impact dashboard + past bookings from Firestore.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirestoreService _db = FirestoreService();
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final bookings = await _db.getUserBookings(user.uid);
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _serviceEmoji(String service) {
    switch (service.toLowerCase()) {
      case 'cleaning':
      case 'home cleaning':
        return '🧹';
      case 'garbage':
      case 'garbage pickup':
        return '🗑️';
      case 'recycling':
        return '♻️';
      case 'deep cleaning':
      case 'deep clean':
        return '🧴';
      case 'transport':
      case 'bulk pickup':
        return '🚛';
      case 'emergency':
        return '🚨';
      case 'office':
        return '🏢';
      default:
        return '🌿';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'CLEAR ALL',
              style: AppTextStyles.labelSM.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadBookings,
              color: AppColors.primaryGreen,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildEcoImpact()),
                  SliverToBoxAdapter(child: _buildSectionHeader()),
                  if (_bookings.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _buildBookingCard(_bookings[i]),
                        childCount: _bookings.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: AppTextStyles.headingSM,
          ),
          const SizedBox(height: 8),
          Text(
            'Book your first eco service from the home screen!',
            style: AppTextStyles.bodySM.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEcoImpact() {
    // Calculate real stats from bookings
    final completedCount =
        _bookings.where((b) => b.status == 'completed').length;
    final totalBookings = _bookings.length;
    final co2Saved = (completedCount * 2.0).toStringAsFixed(0);
    final recycled = (completedCount * 0.7).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🌍', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Your Eco Impact',
                  style: AppTextStyles.headingSM.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _impactStat('$totalBookings', 'Bookings', '📋'),
                const SizedBox(width: 16),
                _impactStat('${co2Saved}kg', 'CO₂ Saved', '🌱'),
                const SizedBox(width: 16),
                _impactStat('${recycled}kg', 'Recycled', '♻️'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _impactStat(String value, String label, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.headingMD.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodyXS.copyWith(
                color: AppColors.textMuted,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PAST BOOKINGS',
            style: AppTextStyles.labelSM.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          Text(
            '${_bookings.length} services',
            style: AppTextStyles.bodyXS.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel b) {
    final statusColor =
        b.status == 'cancelled' ? AppColors.errorRed : AppColors.primaryGreen;
    final emoji = _serviceEmoji(b.serviceType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.serviceType,
                    style: AppTextStyles.bodySM.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${b.workerName} · ${_formatDate(b.createdAt)}',
                    style: AppTextStyles.bodyXS.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${b.amount}',
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    b.status.toUpperCase(),
                    style: AppTextStyles.bodyXS.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}

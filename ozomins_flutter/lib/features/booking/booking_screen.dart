import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../booking/booking_provider.dart';

/// Production Booking Screen — wired to BookingProvider + Firestore.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedSlot = 1;
  final _notesCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ServiceType) {
        // Use microtask to avoid calling notifyListeners during build
        Future.microtask(() {
          if (mounted) {
            context.read<BookingProvider>().selectService(args);
          }
        });
      }
      _initialized = true;
    }
  }

  static const _timeSlots = ['Now', '30 min', '1 hr', '2 hr', 'Schedule'];

  // All 17 services (matching home screen)
  static const _services = [
    _ServiceTile('🧹', 'Home Cleaning', ServiceType.cleaning),
    _ServiceTile('🧴', 'Deep Cleaning', ServiceType.deepClean),
    _ServiceTile('🏢', 'Office Clean', ServiceType.officeClean),
    _ServiceTile('📅', 'Subscription', ServiceType.subscription),
    _ServiceTile('🗑️', 'Garbage', ServiceType.garbage),
    _ServiceTile('♻️', 'Recycling', ServiceType.recycling),
    _ServiceTile('📱', 'E-Waste', ServiceType.eWaste),
    _ServiceTile('🧴', 'Dry & Wet', ServiceType.dryWetWaste),
    _ServiceTile('🚛', 'Bulk Pickup', ServiceType.bulkPickup),
    _ServiceTile('🌿', 'Eco-Friendly', ServiceType.ecoFriendly),
    _ServiceTile('🌱', 'Compost', ServiceType.compost),
    _ServiceTile('☀️', 'Solar Clean', ServiceType.solarCleaning),
    _ServiceTile('🏘️', 'Society Mgmt', ServiceType.societyWaste),
    _ServiceTile('📝', 'B2B Contract', ServiceType.b2bContract),
    _ServiceTile('👷', 'Staff Hire', ServiceType.staffOutsourcing),
    _ServiceTile('🏆', 'Eco Rewards', ServiceType.ecoRewards),
    _ServiceTile('📊', 'Waste Track', ServiceType.wasteTracking),
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Book Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Service Grid ──────────────────────────────
                  Text('SELECT SERVICE', style: AppTextStyles.labelSM),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _services.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (_, i) {
                      final s = _services[i];
                      final isSelected =
                          booking.selectedService == s.type;
                      return GestureDetector(
                        onTap: () => context
                            .read<BookingProvider>()
                            .selectService(s.type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen
                                    .withValues(alpha: 0.1)
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                      .withValues(alpha: 0.6)
                                  : AppColors.outlineVariant
                                      .withValues(alpha: 0.1),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(s.emoji,
                                  style:
                                      const TextStyle(fontSize: 22)),
                              const SizedBox(height: 6),
                              Text(
                                s.label,
                                style: AppTextStyles.bodyXS.copyWith(
                                  fontSize: 10,
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : AppColors.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Time Slot ─────────────────────────────────
                  Text('WHEN DO YOU NEED IT?',
                      style: AppTextStyles.labelSM),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _timeSlots.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final isActive = _selectedSlot == i;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedSlot = i;
                            context
                                .read<BookingProvider>()
                                .setSchedule(_timeSlots[i].toLowerCase());
                          }),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primaryGreen
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive
                                    ? AppColors.primaryGreen
                                    : AppColors.outlineVariant
                                        .withValues(alpha: 0.12),
                              ),
                            ),
                            child: Text(
                              _timeSlots[i],
                              style: AppTextStyles.bodySM.copyWith(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.onSurface,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Address ───────────────────────────────────
                  Text('PICKUP ADDRESS', style: AppTextStyles.labelSM),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _showAddressDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.outlineVariant
                              .withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.location_on_rounded,
                                color: AppColors.primaryGreen,
                                size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Builder(
                              builder: (_) {
                                final addr = context
                                    .watch<BookingProvider>()
                                    .address;
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      addr.isNotEmpty
                                          ? addr
                                          : 'Tap to set address',
                                      style: AppTextStyles.bodySM
                                          .copyWith(
                                        color: addr.isNotEmpty
                                            ? AppColors.onSurface
                                            : AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (addr.isEmpty)
                                      Text(
                                        'Required for booking',
                                        style: AppTextStyles.bodyXS
                                            .copyWith(
                                                color:
                                                    AppColors.textMuted),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const Icon(Icons.edit_rounded,
                              color: AppColors.textMuted, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Notes ─────────────────────────────────────
                  Text('SPECIAL INSTRUCTIONS',
                      style: AppTextStyles.labelSM),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.outlineVariant
                            .withValues(alpha: 0.12),
                      ),
                    ),
                    child: TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      onChanged: (v) => context
                          .read<BookingProvider>()
                          .setDescription(v),
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Any notes for the worker...',
                        hintStyle: AppTextStyles.bodyMD.copyWith(
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),

                  // ── Error ─────────────────────────────────────
                  if (booking.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.errorRed
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.errorRed, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                booking.errorMessage!,
                                style: AppTextStyles.bodySM.copyWith(
                                    color: AppColors.errorRed),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Bottom Price Bar + CTA ─────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.97),
              border: Border(
                top: BorderSide(
                  color:
                      AppColors.outlineVariant.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Price summary
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          booking.priceDisplay,
                          style: AppTextStyles.headingLG.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${booking.selectedService.label} · ${_timeSlots[_selectedSlot]}',
                          style: AppTextStyles.bodySM.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Book CTA
                  GestureDetector(
                    onTap: booking.isLoading ? null : () => _handleBook(context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: booking.isLoading
                            ? null
                            : AppColors.ctaGradient,
                        color: booking.isLoading
                            ? AppColors.surfaceContainerLow
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: booking.isLoading
                            ? null
                            : [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: booking.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Confirm',
                                  style:
                                      AppTextStyles.buttonLG.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBook(BuildContext context) async {
    final booking = context.read<BookingProvider>();

    final success = await booking.confirmBooking();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('✅', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Booking confirmed! ${booking.selectedService.label} will arrive soon.',
                  style: AppTextStyles.bodyMD.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.onSurface,
          duration: const Duration(seconds: 4),
        ),
      );
      booking.reset();
      Navigator.of(context).pop();
    }
  }

  void _showAddressDialog(BuildContext context) {
    final ctrl = TextEditingController(
        text: context.read<BookingProvider>().address);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter Address', style: AppTextStyles.headingSM),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              style: AppTextStyles.bodyMD,
              decoration: InputDecoration(
                hintText: 'e.g. 4th Block, Koramangala, Bengaluru',
                hintStyle: AppTextStyles.bodyMD
                    .copyWith(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final text = ctrl.text.trim();
                if (text.isNotEmpty) {
                  context.read<BookingProvider>().setAddress(text);
                }
                Navigator.pop(ctx);
              },
              child: Text('Save Address',
                  style:
                      AppTextStyles.buttonLG.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile {
  final String emoji;
  final String label;
  final ServiceType type;
  const _ServiceTile(this.emoji, this.label, this.type);
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/booking_model.dart';
import '../../data/services/firestore_service.dart';

/// Live Tracking screen — streams active bookings from Firestore.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _db = FirestoreService();
  StreamSubscription<List<BookingModel>>? _sub;
  List<BookingModel> _activeBookings = [];
  bool _isLoading = true;

  // Pulsing animation for the live dot
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _startStream();
  }

  void _startStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    _sub = _db.streamActiveBookings(uid).listen(
      (bookings) {
        if (mounted) {
          setState(() {
            _activeBookings = bookings;
            _isLoading = false;
          });
        }
      },
      onError: (e) {
        debugPrint('Tracking stream error: $e');
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Live Tracking'),
        centerTitle: false,
        actions: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen
                          .withValues(alpha: _pulseAnim.value),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: AppTextStyles.labelSM.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : _activeBookings.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _isLoading = true);
                    _sub?.cancel();
                    _startStream();
                  },
                  color: AppColors.primaryGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activeBookings.length,
                    itemBuilder: (_, i) =>
                        _buildActiveCard(_activeBookings[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📍', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('No active bookings', style: AppTextStyles.headingSM),
            const SizedBox(height: 10),
            Text(
              'Book a service from the Home tab to track it live here.',
              style: AppTextStyles.bodySM.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard(BookingModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: AppColors.avatarGreenGrad),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    booking.workerName.isNotEmpty
                        ? booking.workerName[0]
                        : 'W',
                    style: AppTextStyles.headingMD.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.workerName,
                        style: AppTextStyles.headingSM),
                    Text(
                      booking.serviceType,
                      style: AppTextStyles.bodyXS
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              _statusChip(booking.status),
            ],
          ),
          const SizedBox(height: 14),
          // Map Placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.1)),
            ),
            child: Stack(
              children: [
                // Map placeholder image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryGreen.withValues(alpha: 0.04),
                          AppColors.mintAccent.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                  ),
                ),
                // Grid lines (simulated map)
                CustomPaint(
                  size: Size.infinite,
                  painter: _MapGridPainter(),
                ),
                // Center location pin
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📍', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          '🚶 En route · ~10 min',
                          style: AppTextStyles.bodySM.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.phone_rounded,
                  label: 'Call',
                  color: AppColors.primaryGreen,
                  bg: AppColors.primaryGreen.withValues(alpha: 0.1),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling worker...')),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  icon: Icons.chat_rounded,
                  label: 'Chat',
                  color: AppColors.infoCyan,
                  bg: AppColors.infoCyan.withValues(alpha: 0.1),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat coming soon!')),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  icon: Icons.close_rounded,
                  label: 'Cancel',
                  color: AppColors.errorRed,
                  bg: AppColors.errorRed.withValues(alpha: 0.1),
                  onTap: () => _confirmCancel(booking),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Timeline
          _buildTimeline(booking),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final (color, label) = switch (status) {
      'confirmed' => (AppColors.primaryGreen, 'CONFIRMED'),
      'inProgress' => (AppColors.warningAmber, 'IN PROGRESS'),
      'pending' => (AppColors.infoCyan, 'PENDING'),
      _ => (AppColors.textMuted, status.toUpperCase()),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSM.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.bodySM.copyWith(
                    color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BookingModel booking) {
    final steps = [
      ('Booking Confirmed', true),
      ('Worker Assigned — ${booking.workerName}', true),
      ('On the way', booking.status == 'inProgress' || booking.status == 'confirmed'),
      ('Service in Progress', booking.status == 'inProgress'),
      ('Completed & Verified', booking.status == 'completed'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Job Timeline', style: AppTextStyles.headingSM),
        const SizedBox(height: 12),
        ...List.generate(steps.length, (i) {
          final (label, isDone) = steps[i];
          final isActive = isDone && (i + 1 >= steps.length || !steps[i + 1].$2);
          final isLast = i == steps.length - 1;
          return _timelineStep(label, isDone, isActive, isLast);
        }),
      ],
    );
  }

  Widget _timelineStep(String label, bool done, bool active, bool isLast) {
    final Color dotColor = done
        ? AppColors.primaryGreen
        : AppColors.surfaceContainerHighest;
    final Color textColor =
        active ? AppColors.primaryGreen : (done ? AppColors.onSurface : AppColors.textMuted);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: active ? 14 : 10,
                height: active ? 14 : 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.4),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                child: done && !active
                    ? const Icon(Icons.check_rounded,
                        size: 8, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: done
                      ? AppColors.primaryGreen.withValues(alpha: 0.3)
                      : AppColors.outlineVariant.withValues(alpha: 0.1),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: Text(
            label,
            style: AppTextStyles.bodySM.copyWith(
              color: textColor,
              fontWeight:
                  active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmCancel(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancel Booking?', style: AppTextStyles.headingSM),
        content: Text(
          'Are you sure you want to cancel this booking?',
          style: AppTextStyles.bodySM,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('No', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _db.cancelBooking(booking.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking cancelled.')),
                );
              }
            },
            child: Text('Yes, Cancel',
                style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}

/// Simple grid painter to simulate a map background.
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter oldDelegate) => false;
}

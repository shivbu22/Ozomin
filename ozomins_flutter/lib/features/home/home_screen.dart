import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/firestore_service.dart';

/// Blinkit-inspired Home Dashboard from Stitch design.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildHeroBanner(context)),
            SliverToBoxAdapter(child: _buildLiveIndicator()),
            SliverToBoxAdapter(child: _buildServiceGrid(context)),
            SliverToBoxAdapter(child: _buildTopWorkers(context)),
            const SliverToBoxAdapter(
                child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── Location Header ──────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery in 10 minutes',
                  style: AppTextStyles.headingMD.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Koramangala, BLR',
                      style: AppTextStyles.bodySM.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ],
            ),
          ),
          // User profile / avatar in green background
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ──────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search for "cleaning"',
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 20,
              color: AppColors.outlineVariant,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            const Icon(Icons.mic_none_rounded, color: AppColors.primaryGreen, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Hero Banner ─────────────────────────────────────────────
  Widget _buildHeroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.05),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speed badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '10 MIN',
                    style: AppTextStyles.labelSM.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '🌿 Eco services in 10\nminutes',
              style: AppTextStyles.headingLG.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book verified workers for cleaning,\nrecycling & more',
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed('/booking'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.ctaGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Book Now',
                      style: AppTextStyles.buttonLG.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Live Workers Indicator ──────────────────────────────────
  Widget _buildLiveIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StreamBuilder<int>(
            stream: FirestoreService().streamNearbyWorkersCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 50;
              return Text(
                '$count workers nearby · Fast response',
                style: AppTextStyles.bodySM.copyWith(
                  color: AppColors.textMuted,
                ),
              );
            },
          ),
        ],
      ),
    );
  }


// ... existing code ...

  // ── Service Grid (4 Columns) ──────────────────────────────────────
  Widget _buildServiceGrid(BuildContext context) {
    final services = ServiceType.values;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All Services', style: AppTextStyles.headingSM),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: services.length,
            itemBuilder: (_, i) {
              final s = services[i];
              return GestureDetector(
                onTap: () {
                  if (s == ServiceType.ecoRewards) {
                    // Specific logic for rewards or redirect to profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Eco Rewards coming soon! Checking your stats...')),
                    );
                    return;
                  }
                  Navigator.of(context).pushNamed('/booking', arguments: s);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outlineVariant
                          .withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Text(s.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                      const Spacer(),
                      Text(
                        s.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSM.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Top Rated Workers ───────────────────────────────────────
  Widget _buildTopWorkers(BuildContext context) {
    const workers = [
      _WorkerItem('R', 'Rajesh K.', 'CLEANING PRO', AppColors.avatarGreenGrad,
          '4.9'),
      _WorkerItem('S', 'Sunita M.', 'GREEN EXPERT',
          AppColors.avatarOrangeGrad, '4.8'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Rated Workers',
                  style: AppTextStyles.headingSM),
              Text(
                'SEE ALL',
                style: AppTextStyles.labelSM.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: workers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final w = workers[i];
                return Container(
                  width: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.outlineVariant
                          .withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: w.gradientColors),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                w.initial,
                                style:
                                    AppTextStyles.headingMD.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Text(
                                '★ ${w.rating}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        w.name,
                        style: AppTextStyles.bodySM.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        w.role,
                        style: AppTextStyles.labelSM.copyWith(
                          fontSize: 8,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryGreen
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Book',
                            style: AppTextStyles.buttonSM.copyWith(
                              color: AppColors.primaryGreen,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkerItem {
  final String initial;
  final String name;
  final String role;
  final List<Color> gradientColors;
  final String rating;
  const _WorkerItem(
      this.initial, this.name, this.role, this.gradientColors, this.rating);
}

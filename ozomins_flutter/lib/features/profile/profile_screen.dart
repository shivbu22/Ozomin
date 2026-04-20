import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_provider.dart';
import '../../data/services/firestore_service.dart';
import '../../data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

/// Profile screen — Firebase user data, stats from Firestore, and logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.uid;

    return StreamBuilder<UserModel?>(
      stream: uid.isNotEmpty ? _db.streamUser(uid) : null,
      builder: (context, snapshot) {
        final profile = snapshot.data ?? auth.userProfile;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded, size: 22),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileCard(auth, profile),
                const SizedBox(height: 16),
                _buildEcoImpactCard(profile),
                const SizedBox(height: 16),
                _buildQuickStats(profile),
                const SizedBox(height: 16),
                _buildMenuSection(),
                const SizedBox(height: 16),
                _buildLogout(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(AuthProvider auth, UserModel? profile) {
    final userName = profile?.name ?? auth.userName;
    final userPhone = profile?.phone ?? 
        auth.userProfile?.phone ?? 
        FirebaseAuth.instance.currentUser?.phoneNumber ?? 
        'Not set';
    final totalBookings = profile?.totalBookings ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.avatarGreenGrad,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '🌿',
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextStyles.headingMD.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  userPhone,
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    totalBookings >= 10
                        ? '🌟 ECO CHAMPION'
                        : '🌱 ECO STARTER',
                    style: AppTextStyles.labelSM.copyWith(
                      color: AppColors.primaryGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showEditNameDialog(context),
            child: const Icon(Icons.edit_rounded,
                color: AppColors.textMuted, size: 18),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final controller = TextEditingController(text: auth.userName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Name', style: AppTextStyles.headingSM),
        content: TextField(
          controller: controller,
          style: AppTextStyles.bodyMD,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            filled: true,
            fillColor: AppColors.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                auth.updateName(name);
              }
              Navigator.pop(ctx);
            },
            child: Text('Save',
                style: TextStyle(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoImpactCard(UserModel? profile) {
    final co2 = profile?.co2Saved ?? 0.0;
    final progress = (co2 % 10) / 10.0; // Level every 10kg
    final level = (co2 / 10).floor() + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.onSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eco Impact Level $level',
                    style: AppTextStyles.headingSM.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(10 - (co2 % 10)).toStringAsFixed(1)}kg to next level',
                    style: AppTextStyles.bodyXS.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const Text('🏆', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 18),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.05, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, Color(0xFFC0FF6B)],
                    ),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _impactMiniStat('Recycled', '${profile?.totalRecycled ?? 0}kg'),
              const Spacer(),
              _impactMiniStat('Points', '${(co2 * 100).toInt()}'),
              const Spacer(),
              _impactMiniStat('Badges', '2'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSM.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 8,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMD.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(UserModel? profile) {
    final totalBookings = profile?.totalBookings ?? 0;
    final co2Saved = profile?.co2Saved ?? 0.0;
    final avgRating = profile?.avgRating ?? 5.0;

    return Row(
      children: [
        _statCard('$totalBookings', 'Services', '📋'),
        const SizedBox(width: 12),
        _statCard('${co2Saved.toStringAsFixed(1)}kg', 'CO₂ Saved', '🌱'),
        const SizedBox(width: 12),
        _statCard('$avgRating', 'Rating', '⭐'),
      ],
    );
  }

  Widget _statCard(String value, String label, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
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
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    const items = [
      _MenuItem(Icons.location_on_rounded, 'Saved Addresses'),
      _MenuItem(Icons.payment_rounded, 'Payment Methods'),
      _MenuItem(Icons.card_giftcard_rounded, 'Rewards & Offers'),
      _MenuItem(Icons.help_outline_rounded, 'Help & Support'),
      _MenuItem(Icons.info_outline_rounded, 'About Ozomins'),
      _MenuItem(Icons.storage_rounded, 'Seed Demo Data', isSensitive: true),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: items.map((item) {
          final isLast = item == items.last;
          return Column(
            children: [
              GestureDetector(
                onTap: () async {
                  if (item.label == 'Seed Demo Data') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Seeding demo workers...')),
                    );
                    await _db.seedWorkers();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demo data ready! Check Home Screen.')),
                      );
                    }
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon,
                            size: 18, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTextStyles.bodyMD.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textMuted, size: 20),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 66,
                  color: AppColors.outlineVariant
                      .withValues(alpha: 0.1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await context.read<AuthProvider>().logout();
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (_) => false);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.errorRed.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.errorRed.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                color: AppColors.errorRed, size: 20),
            const SizedBox(width: 10),
            Text(
              'Sign Out',
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final bool isSensitive;
  const _MenuItem(this.icon, this.label, {this.isSensitive = false});
}

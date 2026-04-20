import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gradient_text.dart';
import '../../core/widgets/eco_button.dart';
import 'auth_provider.dart';

/// Login screen with phone number input and OTP verification.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    final auth = context.read<AuthProvider>();
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit phone number')),
      );
      return;
    }
    final success = await auth.sendOtp(phone);
    if (mounted) {
      if (success && auth.errorMessage == null) {
        setState(() => _otpSent = true);
      } else if (auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage!)),
        );
      }
    }
  }

  void _handleVerifyOtp() async {
    final auth = context.read<AuthProvider>();
    final otp = _otpCtrl.text.trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP')),
      );
      return;
    }
    final success = await auth.verifyOtp(otp);
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.25),
                  ),
                ),
                child: const Center(
                  child: Text('🌿', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 28),
              Text('Welcome to', style: AppTextStyles.headingLG),
              GradientText(
                'Ozomins',
                style: AppTextStyles.headingHero,
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in with your phone number to book eco services in minutes.',
                style: AppTextStyles.bodyMD,
              ),
              const SizedBox(height: 40),

              if (!_otpSent) ...[
                // ── Phone Input ─────────────────────
                Text('Phone Number',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Country code
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Text(
                        '+91',
                        style: AppTextStyles.bodyMD.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: AppTextStyles.bodyMD.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Enter 10-digit number',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                EcoButton(
                  label: 'Send OTP',
                  fullWidth: true,
                  loading: auth.isLoading,
                  icon: Icons.sms_outlined,
                  onTap: _handleSendOtp,
                ),
              ] else ...[
                // ── OTP Input ───────────────────────
                Text('Enter OTP',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  'Sent to +91 ${_phoneCtrl.text}',
                  style: AppTextStyles.bodySM,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingLG.copyWith(
                    letterSpacing: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: '● ● ● ● ● ●',
                  ),
                ),
                const SizedBox(height: 24),
                EcoButton(
                  label: 'Verify & Login',
                  fullWidth: true,
                  loading: auth.isLoading,
                  icon: Icons.check_circle_outline,
                  onTap: _handleVerifyOtp,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _otpSent = false),
                    child: Text(
                      'Change number',
                      style: AppTextStyles.bodySM.copyWith(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // ── Divider ───────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('OR', style: AppTextStyles.bodySM),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // ── Google sign-in (UI only) ──────────
              EcoButton(
                label: 'Continue with Google',
                variant: EcoButtonVariant.outline,
                fullWidth: true,
                icon: Icons.g_mobiledata_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google sign-in coming soon!')),
                  );
                },
              ),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  'By continuing you agree to our Terms & Privacy Policy',
                  style: AppTextStyles.bodyXS,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

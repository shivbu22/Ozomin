import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gradient_text.dart';
import '../../core/widgets/eco_button.dart';

class _OnboardingPage {
  final String emoji;
  final String title;
  final String gradientWord;
  final String description;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.gradientWord,
    required this.description,
  });
}

const _pages = [
  _OnboardingPage(
    emoji: '🏙️',
    title: 'Your City,\nCleaner\nin Minutes.',
    gradientWord: 'Cleaner',
    description:
        'Book verified sanitation workers for cleaning, garbage pickup, recycling & emergencies — tracked in real-time.',
  ),
  _OnboardingPage(
    emoji: '📍',
    title: 'Track\nEverything\nLive.',
    gradientWord: 'Everything',
    description:
        'Real-time GPS tracking from the moment your worker accepts. Know exactly when they arrive and when the job is done.',
  ),
  _OnboardingPage(
    emoji: '♻️',
    title: 'Earn From\nYour\nWaste.',
    gradientWord: 'Earn',
    description:
        'Get paid for your recyclable waste. We pick up, sort, and send to certified recyclers. Money straight to your wallet.',
  ),
];

/// 3-page onboarding with parallax effects, dot indicators, and skip/next buttons.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.bodySM.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),

            // ── Pages ──────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              page.emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                        SizedBox(height: screenH * 0.04),
                        // Title with gradient word
                        _buildTitle(page),
                        const SizedBox(height: 20),
                        Text(
                          page.description,
                          style: AppTextStyles.bodyMD,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Dots + Action ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primaryGreen
                              : AppColors.surfaceBorderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action button
                  EcoButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    fullWidth: true,
                    icon: _currentPage == _pages.length - 1
                        ? Icons.arrow_forward_rounded
                        : null,
                    onTap: () {
                      if (_currentPage < _pages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _goToLogin();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(_OnboardingPage page) {
    final lines = page.title.split('\n');
    return Column(
      children: lines.map((line) {
        if (line.trim() == page.gradientWord) {
          return GradientText(
            line,
            style: AppTextStyles.headingHero,
            textAlign: TextAlign.center,
          );
        }
        return Text(
          line,
          style: AppTextStyles.headingHero,
          textAlign: TextAlign.center,
        );
      }).toList(),
    );
  }
}

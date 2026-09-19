import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_haptics.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBg;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Organize Your Tasks',
      description:
          'Keep your assignments, exams, projects, and lab work meticulously organized in one intuitive student hub.',
      icon: Icons.assignment_turned_in_rounded,
      iconBg: AppColors.categoryAssignment,
    ),
    OnboardingItem(
      title: 'Track Every Deadline',
      description:
          'Stay ahead of due dates with smart priority badges, today & upcoming filters, and clear countdowns.',
      icon: Icons.calendar_month_rounded,
      iconBg: AppColors.categoryExam,
    ),
    OnboardingItem(
      title: 'Boost Productivity',
      description:
          'Visualize your completion percentage, analyze your academic focus, and conquer your semester goals.',
      icon: Icons.insights_rounded,
      iconBg: AppColors.categoryProject,
    ),
  ];

  Future<void> _finishOnboarding() async {
    await StorageService.setOnboardingCompleted(true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              'Skip',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  AppHaptics.selection();
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final isActive = index == _currentPage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isActive ? 1.0 : 0.8,
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 450),
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  page.iconBg.withOpacity(isActive ? 0.18 : 0.10),
                                  page.iconBg.withOpacity(0.06),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: page.iconBg.withOpacity(0.25),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(page.icon, size: 66, color: page.iconBg),
                          ),
                        ),
                        const SizedBox(height: 40),
                        AnimatedOpacity(
                          opacity: isActive ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
                          child: AnimatedSlide(
                            offset: isActive ? Offset.zero : const Offset(0, 0.15),
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOut,
                            child: Column(
                              children: [
                                Text(
                                  page.title,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    height: 1.6,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom bar: indicators + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Button
                  ElevatedButton(
                    onPressed: () {
                      AppHaptics.light();
                      if (_currentPage == _pages.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

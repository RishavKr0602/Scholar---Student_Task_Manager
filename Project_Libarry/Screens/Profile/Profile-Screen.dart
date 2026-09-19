import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/app_haptics.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/animated_entrance.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final stats = ref.watch(statsProvider).stats;
    final user = authState.user;

    final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'S';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // User Avatar Card
              AnimatedEntrance(
                index: 0,
                child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initial,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Prince Sharma',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'prince@student.edu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Quick stats pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            '${stats.completed} Tasks Completed • ${stats.completionRate}% Rate',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 24),

              // Settings Section Header
              AnimatedEntrance(
                index: 1,
                child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'PREFERENCES & SETTINGS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ),
              ),
              const SizedBox(height: 12),

              // Settings Card
              AnimatedEntrance(
                index: 2,
                child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    // Dark Mode Toggle
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Dark Theme',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Comfortable viewing for late night study sessions',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12),
                      ),
                      value: isDark,
                      activeColor: AppColors.primary,
                      onChanged: (_) {
                        AppHaptics.selection();
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                    ),
                    const Divider(height: 1),

                    // Server Configuration
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.dns_rounded, color: AppColors.secondary, size: 20),
                      ),
                      title: Text(
                        'Backend Server URL',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        ApiClient().baseUrl,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                      onTap: () => _showServerConfigDialog(context),
                    ),
                    const Divider(height: 1),

                    // About App
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                      ),
                      title: Text(
                        'About TaskFlow',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'v1.0.0 • Full-Stack Flutter + Node.js + PostgreSQL',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              AnimatedEntrance(
                index: 3,
                child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, ref),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showServerConfigDialog(BuildContext context) {
    final controller = TextEditingController(text: ApiClient().baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configure Backend API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the base URL of your running Express server:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'http://localhost:5000/api',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Android Emulator: http://10.0.2.2:5000/api\n• Physical Device: http://<YOUR_PC_IP>:5000/api\n• Windows/Web: http://localhost:5000/api',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                await ApiClient().setBaseUrl(newUrl);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.task_alt_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('TaskFlow'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A production-quality full-stack academic task management application developed for college students.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            SizedBox(height: 12),
            Text('Tech Stack:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('• Frontend: Flutter & Dart (Material 3, Riverpod, Dio)\n• Backend: Node.js & Express with TypeScript\n• Database: PostgreSQL with Prisma ORM\n• Authentication: JWT & bcrypt'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of your student account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

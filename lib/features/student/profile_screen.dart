import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/database_service.dart';
import '../../widgets/common/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;
    final student = DatabaseService.instance.getStudentById(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(user.name, style: Theme.of(context).textTheme.headlineMedium),
            Text(
              user.collegeId,
              style: const TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 24),

            // Info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (student != null) ...[
                    _InfoRow(
                      icon: Icons.school_outlined,
                      label: AppStrings.department,
                      value: student.department,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.grade_outlined,
                      label: AppStrings.year,
                      value: '${student.year} Year',
                    ),
                    const Divider(height: 24),
                  ],
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    label: AppStrings.collegeId,
                    value: user.collegeId,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Role',
                    value: user.isAdmin ? 'Admin' : 'Student',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            CustomButton(
              text: AppStrings.logout,
              onPressed: () async {
                await auth.logout();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              color: AppColors.danger,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

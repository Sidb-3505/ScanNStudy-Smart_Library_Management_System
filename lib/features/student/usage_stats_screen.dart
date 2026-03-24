import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/visit_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/stat_card.dart';

class UsageStatsScreen extends StatelessWidget {
  const UsageStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final visits = context.watch<VisitProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.stats)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Library Usage',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                StatCard(
                  title: AppStrings.totalVisits,
                  value: visits.getTotalVisits(user.id).toString(),
                  icon: Icons.door_front_door_outlined,
                  color: AppColors.primary,
                ),
                StatCard(
                  title: AppStrings.totalTimeSpent,
                  value: visits.getTotalTimeSpent(user.id),
                  icon: Icons.access_time,
                  color: AppColors.secondary,
                ),
                StatCard(
                  title: AppStrings.avgSessionDuration,
                  value: visits.getAvgSession(user.id),
                  icon: Icons.timelapse,
                  color: AppColors.warning,
                ),
                StatCard(
                  title: 'Status',
                  value: visits.isStudentInside(user.id) ? 'Inside' : 'Outside',
                  icon: Icons.sensors,
                  color: visits.isStudentInside(user.id)
                      ? AppColors.secondary
                      : AppColors.textLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

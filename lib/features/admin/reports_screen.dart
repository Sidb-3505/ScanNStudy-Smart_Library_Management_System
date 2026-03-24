import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/double_back_exit.dart';
import '../../providers/visit_provider.dart';
import '../../widgets/charts/usage_chart.dart';
import '../../widgets/common/stat_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final visits = context.watch<VisitProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          DoubleBackExit.handle(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.reports)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Summary",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  StatCard(
                    title: AppStrings.totalEntriesToday,
                    value: visits.totalEntriesToday.toString(),
                    icon: Icons.login,
                    color: AppColors.primary,
                  ),
                  StatCard(
                    title: AppStrings.totalExitsToday,
                    value: visits.totalExitsToday.toString(),
                    icon: Icons.logout,
                    color: AppColors.secondary,
                  ),
                  StatCard(
                    title: AppStrings.avgSessionTime,
                    value: visits.avgSessionToday,
                    icon: Icons.timelapse,
                    color: AppColors.warning,
                  ),
                  StatCard(
                    title: AppStrings.studentsInside,
                    value: visits.studentsInsideNow.toString(),
                    icon: Icons.people,
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Last 7 Days',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              UsageChart(
                data: visits.dailyEntryCounts,
                title: 'Daily Entry Count',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/visit_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/cards/visit_card.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<VisitProvider>().getAllLogs();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.logs),
      ),
      body: logs.isEmpty
          ? const Center(
              child: Text(
                'No logs yet.',
                style: TextStyle(color: AppColors.textLight),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: logs.length,
              itemBuilder: (_, i) => VisitCard(
                log: logs[i],
                showStudentName: true,
              ),
            ),
    );
  }
}

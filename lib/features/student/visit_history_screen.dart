import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/visit_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/cards/visit_card.dart';

class VisitHistoryScreen extends StatelessWidget {
  const VisitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final visits = context.watch<VisitProvider>().getStudentVisits(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.history)),
      body: visits.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.history, size: 64, color: AppColors.border),
                  SizedBox(height: 12),
                  Text(
                    AppStrings.noVisitsYet,
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: visits.length,
              itemBuilder: (_, i) => VisitCard(log: visits[i]),
            ),
    );
  }
}

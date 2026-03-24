import 'package:flutter/material.dart';
import '../../models/visit_log_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';

class VisitCard extends StatelessWidget {
  final VisitLog log;
  final bool showStudentName;

  const VisitCard({
    super.key,
    required this.log,
    this.showStudentName = false,
  });

  @override
  Widget build(BuildContext context) {
    final duration = log.sessionDuration;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: log.isActive
                ? AppColors.secondary.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            log.isActive ? Icons.sensors : Icons.check_circle_outline,
            color: log.isActive ? AppColors.secondary : AppColors.primary,
            size: 20,
          ),
        ),
        title: showStudentName
            ? Text(
                log.studentName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              )
            : Text(
                AppDateUtils.formatDate(log.entryTime),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.login, size: 12, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  'In: ${AppDateUtils.formatTime(log.entryTime)}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 12),
                if (log.exitTime != null) ...[
                  const Icon(Icons.logout, size: 12, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    'Out: ${AppDateUtils.formatTime(log.exitTime!)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: log.isActive
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Inside',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : duration != null
                ? Text(
                    AppDateUtils.formatDuration(duration),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      fontSize: 13,
                    ),
                  )
                : null,
      ),
    );
  }
}

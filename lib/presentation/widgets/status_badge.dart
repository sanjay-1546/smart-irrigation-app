import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/alert.dart';
import '../../domain/entities/zone_status.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadge({super.key, required this.text, required this.color});

  factory StatusBadge.moisture(MoistureLevel level) {
    switch (level) {
      case MoistureLevel.healthy:
        return StatusBadge(text: 'Healthy', color: AppColors.healthy);
      case MoistureLevel.warning:
        return StatusBadge(text: 'Warning', color: AppColors.warning);
      case MoistureLevel.critical:
        return StatusBadge(text: 'Critical', color: AppColors.critical);
    }
  }

  factory StatusBadge.severity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return StatusBadge(text: 'Critical', color: AppColors.critical);
      case AlertSeverity.warning:
        return StatusBadge(text: 'Warning', color: AppColors.warning);
      case AlertSeverity.info:
        return StatusBadge(text: 'Info', color: AppColors.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

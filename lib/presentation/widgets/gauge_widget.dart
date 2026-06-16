import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/zone_status.dart';

class GaugeWidget extends StatelessWidget {
  final double percent;
  final String label;
  final double size;

  const GaugeWidget({
    super.key,
    required this.percent,
    required this.label,
    this.size = 110,
  });

  Color _colorFor(double percent) {
    if (percent < 25) return AppColors.critical;
    if (percent < 45) return AppColors.warning;
    return AppColors.healthy;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(percent);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 10,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}

MoistureLevel moistureLevelFor(double percent) {
  if (percent < 25) return MoistureLevel.critical;
  if (percent < 45) return MoistureLevel.warning;
  return MoistureLevel.healthy;
}

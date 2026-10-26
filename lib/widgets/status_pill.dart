import "package:flutter/material.dart";

import "/utils/colors.dart";

enum StatusPillType { active, inactive, neutral, warning }

class StatusPill extends StatelessWidget {
  final String label;
  final StatusPillType type;
  final bool showDot;

  const StatusPill({
    super.key,
    required this.label,
    this.type = StatusPillType.neutral,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final (dotColor, textColor, borderColor) = switch (type) {
      StatusPillType.active => (
        AppColors.statusActiveDot,
        AppColors.zinc950,
        AppColors.zinc300,
      ),
      StatusPillType.inactive => (
        AppColors.statusErrorDot,
        AppColors.zinc700,
        AppColors.zinc200,
      ),
      StatusPillType.warning => (
        AppColors.statusWarningDot,
        AppColors.zinc800,
        AppColors.zinc300,
      ),
      StatusPillType.neutral => (
        AppColors.zinc500,
        AppColors.zinc800,
        AppColors.zinc200,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

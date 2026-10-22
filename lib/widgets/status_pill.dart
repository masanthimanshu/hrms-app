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
    Color dotColor;
    Color bgColor;
    Color textColor;
    BorderSide border;

    switch (type) {
      case StatusPillType.active:
        dotColor = AppColors.statusActiveDot;
        bgColor = AppColors.zinc100;
        textColor = AppColors.zinc950;
        border = const BorderSide(color: AppColors.zinc300, width: 1);
        break;
      case StatusPillType.inactive:
        dotColor = AppColors.statusErrorDot;
        bgColor = AppColors.zinc100;
        textColor = AppColors.zinc700;
        border = const BorderSide(color: AppColors.zinc200, width: 1);
        break;
      case StatusPillType.warning:
        dotColor = AppColors.statusWarningDot;
        bgColor = AppColors.zinc100;
        textColor = AppColors.zinc800;
        border = const BorderSide(color: AppColors.zinc300, width: 1);
        break;
      case StatusPillType.neutral:
        dotColor = AppColors.zinc500;
        bgColor = AppColors.zinc100;
        textColor = AppColors.zinc800;
        border = const BorderSide(color: AppColors.zinc200, width: 1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.fromBorderSide(border),
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

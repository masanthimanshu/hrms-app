import "package:flutter/material.dart";

import "/models/attendance_model.dart";
import "/utils/colors.dart";
import "/utils/formatters.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/status_pill.dart";

class AttendanceLogTile extends StatelessWidget {
  final AttendanceModel record;

  const AttendanceLogTile({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return MonochromeCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.zinc100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check, size: 18, color: AppColors.zinc950),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.storeName ?? "Primary Facility",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.zinc950,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatters.formatDate(record.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.zinc500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${record.latitude}, ${record.longitude}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: "monospace",
                    color: AppColors.zinc600,
                  ),
                ),
              ],
            ),
          ),
          StatusPill(
            label: record.isVerified ? "Verified" : "Warning",
            type: record.isVerified ? StatusPillType.active : StatusPillType.warning,
          ),
        ],
      ),
    );
  }
}

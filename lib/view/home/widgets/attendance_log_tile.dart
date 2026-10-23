import "package:flutter/material.dart";

import "/models/attendance_model.dart";
import "/utils/colors.dart";
import "/utils/formatters.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/status_pill.dart";

class AttendanceLogTile extends StatelessWidget {
  final AttendanceModel record;

  const AttendanceLogTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return MonochromeCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.zinc950,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 18,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        record.storeName ?? "Headquarters - San Francisco",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc950,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    StatusPill(
                      label: record.isVerified ? "Verified" : "Warning",
                      type: record.isVerified
                          ? StatusPillType.active
                          : StatusPillType.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  AppFormatters.formatDate(record.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.zinc600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.zinc200, width: 1),
                      ),
                      child: Text(
                        "${record.latitude}, ${record.longitude}",
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: "monospace",
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 10,
                            color: AppColors.zinc700,
                          ),
                          SizedBox(width: 3),
                          Text(
                            "Selfie Proof",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.zinc700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import "package:flutter/material.dart";

import "/models/attendance_model.dart";
import "/utils/colors.dart";
import "/utils/formatters.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/status_pill.dart";

class AttendanceLogTile extends StatelessWidget {
  final AttendanceModel record;
  final String? fallbackStoreName;

  const AttendanceLogTile({
    super.key,
    required this.record,
    this.fallbackStoreName,
  });

  Widget _tag(Widget child, {bool border = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(4),
        border: border ? Border.all(color: AppColors.zinc200, width: 1) : null,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayStoreName =
        (record.storeName != null && record.storeName!.isNotEmpty)
        ? record.storeName!
        : (fallbackStoreName != null && fallbackStoreName!.isNotEmpty)
        ? fallbackStoreName!
        : "Workplace Facility";

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
                        displayStoreName,
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
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _tag(
                      Text(
                        AppFormatters.formatCoordinates(
                          record.latitude,
                          record.longitude,
                        ),
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: "monospace",
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc700,
                        ),
                      ),
                    ),
                    if (record.distance != null)
                      _tag(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me_outlined,
                              size: 10,
                              color: AppColors.zinc700,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              "${record.distance}m",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.zinc700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    _tag(
                      const Row(
                        mainAxisSize: MainAxisSize.min,
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
                      border: false,
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

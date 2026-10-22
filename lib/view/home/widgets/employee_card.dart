import "package:flutter/material.dart";

import "/models/user_model.dart";
import "/utils/colors.dart";
import "/utils/formatters.dart";
import "/widgets/monochrome_card.dart";
import "/widgets/status_pill.dart";

class EmployeeCard extends StatelessWidget {
  final UserModel employee;
  final bool isCurrentUser;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return MonochromeCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Initials Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCurrentUser ? AppColors.zinc950 : AppColors.zinc100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentUser ? AppColors.zinc800 : AppColors.zinc300,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                AppFormatters.getInitials(employee.name),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isCurrentUser ? AppColors.white : AppColors.zinc900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc950,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.zinc950,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "YOU",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  employee.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.zinc600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        employee.storeName ?? "Primary Branch",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.zinc700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          StatusPill(
            label: employee.isValid ? "Active" : "Pending",
            type: employee.isValid ? StatusPillType.active : StatusPillType.warning,
          ),
        ],
      ),
    );
  }
}

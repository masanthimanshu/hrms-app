import "package:flutter/material.dart";

import "/utils/colors.dart";
import "monochrome_button.dart";

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.zinc200, width: 1),
              ),
              child: Icon(icon, size: 36, color: AppColors.zinc700),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.zinc950,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.zinc500,
                height: 1.4,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 20),
              MonochromeButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                variant: MonochromeButtonVariant.secondary,
                height: 40,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

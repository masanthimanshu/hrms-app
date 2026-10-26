import "package:flutter/material.dart";

import "/utils/colors.dart";

enum MonochromeButtonVariant { primary, secondary, ghost }

class MonochromeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final MonochromeButtonVariant variant;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const MonochromeButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = MonochromeButtonVariant.primary,
    this.width,
    this.height = 48,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, border) = switch (variant) {
      MonochromeButtonVariant.primary => (
        AppColors.zinc950,
        AppColors.white,
        null,
      ),
      MonochromeButtonVariant.secondary => (
        AppColors.white,
        AppColors.zinc950,
        Border.all(color: AppColors.zinc300, width: 1),
      ),
      MonochromeButtonVariant.ghost => (
        AppColors.zinc100,
        AppColors.zinc900,
        Border.all(color: AppColors.zinc200, width: 1),
      ),
    };

    final disabled = onPressed == null || isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: disabled ? AppColors.zinc200 : bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: disabled ? null : border,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 16, color: fgColor),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: disabled ? AppColors.zinc400 : fgColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

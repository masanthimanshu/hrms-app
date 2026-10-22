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
    Color bgColor;
    Color fgColor;
    BorderSide borderSide;

    switch (variant) {
      case MonochromeButtonVariant.primary:
        bgColor = AppColors.zinc950;
        fgColor = AppColors.white;
        borderSide = BorderSide.none;
        break;
      case MonochromeButtonVariant.secondary:
        bgColor = AppColors.white;
        fgColor = AppColors.zinc950;
        borderSide = const BorderSide(color: AppColors.zinc300, width: 1);
        break;
      case MonochromeButtonVariant.ghost:
        bgColor = AppColors.zinc100;
        fgColor = AppColors.zinc900;
        borderSide = const BorderSide(color: AppColors.zinc200, width: 1);
        break;
    }

    final bool disabled = onPressed == null || isLoading;

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
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: disabled ? null : (borderSide == BorderSide.none ? null : Border.fromBorderSide(borderSide)),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
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
                          Icon(icon, size: 18, color: fgColor),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: disabled ? AppColors.zinc400 : fgColor,
                            letterSpacing: -0.2,
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

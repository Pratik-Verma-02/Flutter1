import 'package:flutter/material.dart';
import '../../core/config/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool hasGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard.withOpacity(0.8),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: hasGlow
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : AppTheme.textMuted.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          if (hasGlow)
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

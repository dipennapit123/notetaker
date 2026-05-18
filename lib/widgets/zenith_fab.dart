import 'package:db_notes/theme/app_colors.dart';
import 'package:db_notes/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// DESIGN.md: 64×64, 18px radius, #7C6CFA, white icon 24px, violet-tinted shadow.
class ZenithFab extends StatelessWidget {
  const ZenithFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fabViolet,
      elevation: 10,
      shadowColor: AppColors.fabShadow,
      borderRadius: BorderRadius.circular(AppTheme.fabRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.fabRadius),
        child: const SizedBox(
          width: AppTheme.fabSize,
          height: AppTheme.fabSize,
          child: Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

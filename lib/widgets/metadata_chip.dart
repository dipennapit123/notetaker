import 'package:flutter/material.dart';

class MetadataChip extends StatelessWidget {
  const MetadataChip({
    super.key,
    required this.icon,
    required this.label,
    this.uppercase = false,
  });

  final IconData icon;
  final String label;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final text = uppercase ? label.toUpperCase() : label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: isDark
            ? null
            : Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: uppercase ? 0.8 : 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

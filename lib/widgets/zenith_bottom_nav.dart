import 'package:db_notes/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum ZenithTab { notes, favorites, labels, settings }

class ZenithBottomNav extends StatelessWidget {
  const ZenithBottomNav({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final ZenithTab current;
  final ValueChanged<ZenithTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(context, ZenithTab.notes, 'Notes'),
              _item(context, ZenithTab.favorites, 'Favorites'),
              _item(context, ZenithTab.labels, 'Labels'),
              _item(context, ZenithTab.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, ZenithTab tab, String label) {
    final theme = Theme.of(context);
    final selected = current == tab;

    late final IconData icon;
    switch (tab) {
      case ZenithTab.notes:
        icon = selected ? Icons.description : Icons.description_outlined;
      case ZenithTab.favorites:
        icon = selected ? Icons.star : Icons.star_outline;
      case ZenithTab.labels:
        icon = selected ? Icons.label : Icons.label_outline;
      case ZenithTab.settings:
        icon = selected ? Icons.settings : Icons.settings_outlined;
    }

    return InkWell(
      onTap: () => onChanged(tab),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

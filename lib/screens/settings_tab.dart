import 'package:db_notes/theme/app_theme.dart';
import 'package:db_notes/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.containerPadding,
        12,
        AppTheme.containerPadding,
        120,
      ),
      children: [
        Text(
          'Appearance',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Theme follows your Aether Notes design tokens.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _ThemeTile(
          title: 'System',
          subtitle: 'Match device setting',
          selected: themeController.mode == ThemeMode.system,
          onTap: () => themeController.setMode(ThemeMode.system),
        ),
        _ThemeTile(
          title: 'Light',
          subtitle: 'Warm off-white canvas',
          selected: themeController.mode == ThemeMode.light,
          onTap: () => themeController.setMode(ThemeMode.light),
        ),
        _ThemeTile(
          title: 'Dark',
          subtitle: 'Aether dark surfaces (#10131d)',
          selected: themeController.mode == ThemeMode.dark,
          onTap: () => themeController.setMode(ThemeMode.dark),
        ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: theme.colorScheme.primary)
                else
                  Icon(Icons.circle_outlined, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class FormatToolbar extends StatelessWidget {
  const FormatToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget btn(IconData icon) {
      return IconButton(
        onPressed: () {},
        icon: Icon(icon, color: theme.colorScheme.primary),
        style: IconButton.styleFrom(
          minimumSize: const Size(40, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(
          alpha: isDark ? 0.9 : 0.85,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.format_bold),
          btn(Icons.format_italic),
          btn(Icons.format_list_bulleted),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          btn(Icons.image_outlined),
          btn(Icons.mic_none_rounded),
          btn(Icons.palette_outlined),
        ],
      ),
    );
  }
}

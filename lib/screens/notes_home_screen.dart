import 'dart:math';

import 'package:db_notes/models/note.dart';
import 'package:db_notes/screens/note_editor_screen.dart';
import 'package:db_notes/screens/settings_tab.dart';
import 'package:db_notes/services/notes_repository.dart';
import 'package:db_notes/theme/app_theme.dart';
import 'package:db_notes/theme/note_accents.dart';
import 'package:db_notes/theme/theme_controller.dart';
import 'package:db_notes/widgets/delete_note_dialog.dart';
import 'package:db_notes/widgets/note_card.dart';
import 'package:db_notes/widgets/zenith_bottom_nav.dart';
import 'package:db_notes/widgets/zenith_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({
    super.key,
    required this.repo,
    required this.themeController,
  });

  final NotesRepository repo;
  final ThemeController themeController;

  @override
  State<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  ZenithTab _tab = ZenithTab.notes;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String _topTitle(ZenithTab tab) {
    return switch (tab) {
      ZenithTab.notes => 'Notes',
      ZenithTab.favorites => 'Favorites',
      ZenithTab.labels => 'Labels',
      ZenithTab.settings => 'Settings',
    };
  }

  List<Note> _filter(List<Note> notes) {
    if (_query.isEmpty) return notes;
    return notes.where((n) {
      final title = n.title.toLowerCase();
      final body = n.body.toLowerCase();
      return title.contains(_query) || body.contains(_query);
    }).toList();
  }

  Future<void> _openEditor(BuildContext context, {Note? note}) async {
    final accentIndex = note != null
        ? note.accentIndex
        : Random().nextInt(kNoteAccents.length);

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (ctx) => NoteEditorScreen(
          repo: widget.repo,
          initialNote: note,
          accentIndex: accentIndex,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Note note) async {
    final ok = await showDeleteNoteDialog(context) ?? false;
    if (!ok || !context.mounted) return;
    await widget.repo.deleteNote(note.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showFab = _tab == ZenithTab.notes;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _TopBar(
            title: _topTitle(_tab),
            tab: _tab,
            onSearchTap: _tab == ZenithTab.notes
                ? () => _searchFocus.requestFocus()
                : null,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: showFab
          ? Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: ZenithFab(onPressed: () => _openEditor(context)),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: ZenithBottomNav(
        current: _tab,
        onChanged: (t) => setState(() => _tab = t),
      ),
    );
  }

  Widget _buildBody() {
    switch (_tab) {
      case ZenithTab.notes:
        return _NotesTab(
          repo: widget.repo,
          searchCtrl: _searchCtrl,
          searchFocus: _searchFocus,
          query: _query,
          filter: _filter,
          onOpen: (n) => _openEditor(context, note: n),
          onDelete: (n) => _confirmDelete(context, n),
          onNew: () => _openEditor(context),
        );
      case ZenithTab.favorites:
        return _FavoritesTab(
          repo: widget.repo,
          onOpen: (n) => _openEditor(context, note: n),
          onDelete: (n) => _confirmDelete(context, n),
          onBrowseNotes: () => setState(() => _tab = ZenithTab.notes),
        );
      case ZenithTab.labels:
        return _LabelsBrowseTab(
          repo: widget.repo,
          onOpen: (n) => _openEditor(context, note: n),
          onDelete: (n) => _confirmDelete(context, n),
        );
      case ZenithTab.settings:
        return SettingsTab(themeController: widget.themeController);
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.tab,
    this.onSearchTap,
  });

  final String title;
  final ZenithTab tab;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerPadding),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.menu, color: theme.colorScheme.primary),
              ),
              Text(title, style: theme.textTheme.headlineLarge),
              const Spacer(),
              if (tab == ZenithTab.notes && onSearchTap != null) ...[
                IconButton(
                  onPressed: onSearchTap,
                  icon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                  backgroundImage: null,
                  child: Icon(
                    Icons.person_outline,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class NotesCollectionView extends StatelessWidget {
  const NotesCollectionView({
    super.key,
    required this.notes,
    required this.repo,
    required this.onOpen,
    required this.onConfirmDelete,
    this.emptyIcon = Icons.note_alt_outlined,
    this.emptyTitle = 'Nothing here yet',
    this.emptySubtitle,
    this.emptyActionLabel,
    this.onEmptyAction,
  });

  final List<Note> notes;
  final NotesRepository repo;
  final ValueChanged<Note> onOpen;
  final ValueChanged<Note> onConfirmDelete;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptySubtitle;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;

  static const _pad = EdgeInsets.fromLTRB(
    AppTheme.containerPadding,
    0,
    AppTheme.containerPadding,
    140,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 600;

    if (notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emptyIcon,
                size: 56,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 16),
              Text(emptyTitle, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              if (emptySubtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  emptySubtitle!,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              if (onEmptyAction != null && emptyActionLabel != null) ...[
                const SizedBox(height: 20),
                TextButton(onPressed: onEmptyAction, child: Text(emptyActionLabel!)),
              ],
            ],
          ),
        ),
      );
    }

    Widget card(Note note) {
      final accent = kNoteAccents[noteAccentIndex(note.accentIndex)];
      return NoteCard(
        note: note,
        accent: accent,
        onTap: () => onOpen(note),
        onLongPress: () => onConfirmDelete(note),
        onFavoriteTap: () => repo.setFavorite(note.id, !note.isFavorite),
      );
    }

    if (wide) {
      return MasonryGridView.count(
        padding: _pad,
        crossAxisCount: 2,
        mainAxisSpacing: AppTheme.gutter,
        crossAxisSpacing: AppTheme.gutter,
        itemCount: notes.length,
        itemBuilder: (context, i) => card(notes[i]),
      );
    }

    return ListView.separated(
      padding: _pad,
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppTheme.gutter),
      itemBuilder: (context, i) => card(notes[i]),
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({
    required this.repo,
    required this.searchCtrl,
    required this.searchFocus,
    required this.query,
    required this.filter,
    required this.onOpen,
    required this.onDelete,
    required this.onNew,
  });

  final NotesRepository repo;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final String query;
  final List<Note> Function(List<Note>) filter;
  final void Function(Note) onOpen;
  final void Function(Note) onDelete;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.containerPadding,
            0,
            AppTheme.containerPadding,
            AppTheme.gutter,
          ),
          child: SizedBox(
            height: 48,
            child: TextField(
              controller: searchCtrl,
              focusNode: searchFocus,
              textInputAction: TextInputAction.search,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search your notes',
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: searchCtrl.clear,
                      ),
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceContainerHigh
                    : theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.searchRadius),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0 : 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.searchRadius),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Note>>(
            stream: repo.watchNotes(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _ErrorState(message: snapshot.error.toString());
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final visible = filter(snapshot.data!);
              if (visible.isEmpty) {
                return _EmptyState(query: query, onNew: onNew);
              }

              return NotesCollectionView(
                notes: visible,
                repo: repo,
                onOpen: onOpen,
                onConfirmDelete: onDelete,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab({
    required this.repo,
    required this.onOpen,
    required this.onDelete,
    required this.onBrowseNotes,
  });

  final NotesRepository repo;
  final ValueChanged<Note> onOpen;
  final ValueChanged<Note> onDelete;
  final VoidCallback onBrowseNotes;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Note>>(
      stream: repo.watchNotes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorState(message: snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final favs = snapshot.data!.where((n) => n.isFavorite).toList();
        return NotesCollectionView(
          notes: favs,
          repo: repo,
          onOpen: onOpen,
          onConfirmDelete: onDelete,
          emptyIcon: Icons.star_outline,
          emptyTitle: 'No favorites yet',
          emptySubtitle:
              'Tap the star on a note card, or open a note and tap the star in the toolbar.',
          emptyActionLabel: 'Browse notes',
          onEmptyAction: onBrowseNotes,
        );
      },
    );
  }
}

class _LabelsBrowseTab extends StatefulWidget {
  const _LabelsBrowseTab({
    required this.repo,
    required this.onOpen,
    required this.onDelete,
  });

  final NotesRepository repo;
  final ValueChanged<Note> onOpen;
  final ValueChanged<Note> onDelete;

  @override
  State<_LabelsBrowseTab> createState() => _LabelsBrowseTabState();
}

class _LabelsBrowseTabState extends State<_LabelsBrowseTab> {
  String? _selectedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<Note>>(
      stream: widget.repo.watchNotes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorState(message: snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final notes = snapshot.data!;

        if (_selectedLabel != null) {
          final label = _selectedLabel!;
          final filtered = notes.where((n) => n.labels.contains(label)).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, AppTheme.containerPadding, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => setState(() => _selectedLabel = null),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: theme.textTheme.titleMedium),
                          Text(
                            '${filtered.length} ${filtered.length == 1 ? 'note' : 'notes'}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: NotesCollectionView(
                  notes: filtered,
                  repo: widget.repo,
                  onOpen: widget.onOpen,
                  onConfirmDelete: widget.onDelete,
                  emptyIcon: Icons.label_outline,
                  emptyTitle: 'No notes with this label',
                  emptySubtitle: 'Assign this label from the note editor.',
                ),
              ),
            ],
          );
        }

        final counts = <String, int>{};
        for (final n in notes) {
          for (final l in n.labels) {
            counts[l] = (counts[l] ?? 0) + 1;
          }
        }

        if (counts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No labels yet. Open any note and choose Labels.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final sorted = counts.keys.toList()..sort();

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.containerPadding,
            8,
            AppTheme.containerPadding,
            120,
          ),
          itemCount: sorted.length,
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: theme.dividerTheme.color),
          itemBuilder: (context, i) {
            final label = sorted[i];
            final c = noteLabelColor(label);
            final count = counts[label]!;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: c.withValues(alpha: 0.12),
                foregroundColor: c,
                child: const Icon(Icons.label_outline, size: 22),
              ),
              title: Text(label, style: theme.textTheme.titleMedium?.copyWith(fontSize: 17)),
              trailing: Text(
                '$count',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              onTap: () => setState(() => _selectedLabel = label),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query, required this.onNew});

  final String query;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searching = query.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searching ? Icons.manage_search : Icons.auto_awesome,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              searching ? 'No matches' : 'Your canvas is ready',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              searching
                  ? 'Try another phrase or clear the search.'
                  : 'Tap + to capture something brilliant.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (!searching) ...[
              const SizedBox(height: 20),
              TextButton(onPressed: onNew, child: const Text('Create note')),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Something went wrong', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

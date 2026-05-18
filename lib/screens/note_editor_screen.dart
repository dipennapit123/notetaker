import 'dart:collection';

import 'package:db_notes/models/note.dart';
import 'package:db_notes/services/notes_repository.dart';
import 'package:db_notes/theme/app_colors.dart';
import 'package:db_notes/theme/app_theme.dart';
import 'package:db_notes/theme/note_accents.dart';
import 'package:db_notes/widgets/format_toolbar.dart';
import 'package:db_notes/widgets/metadata_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({
    super.key,
    required this.repo,
    required this.initialNote,
    required this.accentIndex,
  });

  final NotesRepository repo;
  final Note? initialNote;
  final int accentIndex;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  Note? _note;
  bool _creating = false;
  late final bool _isNew;

  late bool _favorite;
  late LinkedHashSet<String> _selectedLabels;

  @override
  void initState() {
    super.initState();
    _isNew = widget.initialNote == null;
    _titleCtrl = TextEditingController(text: widget.initialNote?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.initialNote?.body ?? '');
    _note = widget.initialNote;
    _favorite = widget.initialNote?.isFavorite ?? false;
    _selectedLabels = LinkedHashSet<String>.from(
      widget.initialNote?.labels ??
          <String>[noteAccentLabel(widget.accentIndex)],
    );

    if (_isNew) {
      _creating = true;
      widget.repo
          .createNote(title: '', body: '', accentIndex: widget.accentIndex)
          .then((id) {
        if (!mounted) return;
        final now = DateTime.now();
        final seed = noteAccentLabel(widget.accentIndex);
        setState(() {
          _note = Note(
            id: id,
            title: '',
            body: '',
            createdAt: now,
            updatedAt: now,
            accentIndex: widget.accentIndex,
            isFavorite: false,
            explicitLabels: [seed],
          );
          _selectedLabels
            ..clear()
            ..add(seed);
          _favorite = false;
          _creating = false;
        });
      }).catchError((Object _) {
        if (!mounted) return;
        setState(() => _creating = false);
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _persistOrCleanup() async {
    final note = _note;
    if (note == null) return;

    final title = _titleCtrl.text;
    final body = _bodyCtrl.text;
    final empty = title.trim().isEmpty && body.trim().isEmpty;

    if (empty && _isNew) {
      await widget.repo.deleteNote(note.id);
      return;
    }

    final ls = _selectedLabels.isEmpty
        ? <String>[noteAccentLabel(note.accentIndex)]
        : _selectedLabels.toList();

    await widget.repo.updateNote(
      Note(
        id: note.id,
        title: title,
        body: body,
        createdAt: note.createdAt,
        updatedAt: DateTime.now(),
        accentIndex: note.accentIndex,
        isFavorite: _favorite,
        explicitLabels: ls,
      ),
    );
  }

  Future<void> _handlePop() async {
    await _persistOrCleanup();
    if (!mounted) return;
    final nav = Navigator.maybeOf(context);
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
  }

  Future<void> _toggleFavoriteBar() async {
    final n = _note;
    if (n == null || _creating) return;
    final next = !_favorite;
    setState(() => _favorite = next);
    await widget.repo.setFavorite(n.id, next);
  }

  String _labelsPreview() {
    if (_selectedLabels.isEmpty) return noteAccentLabel(widget.accentIndex);
    final list = _selectedLabels.toList();
    if (list.length <= 2) return list.join(', ');
    return '${list.take(2).join(', ')}…';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateLabel = _note != null
        ? DateFormat.yMMMd().format(_note!.updatedAt)
        : DateFormat.yMMMd().format(DateTime.now());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handlePop();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: _creating
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.fabViolet,
                            AppColors.inversePrimary,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.containerPadding,
                          ),
                          child: SizedBox(
                            height: 64,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _handlePop,
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  _isNew ? 'New note' : 'Edit note',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isDark
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  tooltip: _favorite ? 'Remove favorite' : 'Favorite',
                                  onPressed: _toggleFavoriteBar,
                                  icon: Icon(
                                    _favorite ? Icons.star_rounded : Icons.star_outline,
                                    color: _favorite
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (isDark)
                                  TextButton(
                                    onPressed: _handlePop,
                                    child: Text(
                                      'Done',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: AppColors.darkOnSurface,
                                      ),
                                    ),
                                  )
                                else
                                  FilledButton(
                                    onPressed: _handlePop,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.lightPrimary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Done'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.containerPadding,
                            8,
                            AppTheme.containerPadding,
                            120,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  MetadataChip(
                                    icon: Icons.calendar_today_outlined,
                                    label: dateLabel,
                                    uppercase: isDark,
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: MetadataChip(
                                      icon: Icons.sell_outlined,
                                      label: _labelsPreview(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Labels',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap to add or remove. At least one label stays on the note.',
                                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: kNoteAccentLabels.map((l) {
                                  final selected = _selectedLabels.contains(l);
                                  return FilterChip(
                                    label: Text(l),
                                    selected: selected,
                                    onSelected: (value) {
                                      setState(() {
                                        if (value) {
                                          _selectedLabels.add(l);
                                        } else if (_selectedLabels.length > 1) {
                                          _selectedLabels.remove(l);
                                        }
                                      });
                                    },
                                    selectedColor:
                                        noteLabelColor(l).withValues(alpha: 0.22),
                                    checkmarkColor: noteLabelColor(l),
                                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                                      color: selected
                                          ? noteLabelColor(l)
                                          : theme.colorScheme.onSurfaceVariant,
                                      fontWeight:
                                          selected ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _titleCtrl,
                                style: theme.textTheme.headlineLarge,
                                decoration: InputDecoration(
                                  hintText: 'Title',
                                  hintStyle: theme.textTheme.headlineLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.4),
                                  ),
                                  border: InputBorder.none,
                                  filled: false,
                                ),
                                maxLines: 3,
                                textCapitalization: TextCapitalization.sentences,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _bodyCtrl,
                                keyboardType: TextInputType.multiline,
                                minLines: 12,
                                maxLines: null,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isDark
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Start writing...',
                                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.4),
                                  ),
                                  border: InputBorder.none,
                                  filled: false,
                                  alignLabelWithHint: true,
                                ),
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 32,
                    child: Center(child: FormatToolbar()),
                  ),
                ],
              ),
      ),
    );
  }
}

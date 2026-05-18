import 'package:flutter/material.dart';

/// Accent stripes for note cards (persisted per note via `accentIndex`).
const List<Color> kNoteAccents = [
  Color(0xFF7C6CFA),
  Color(0xFF5FDACB),
  Color(0xFFF59BB5),
  Color(0xFFFFB871),
  Color(0xFF78B8FF),
  Color(0xFFB388FF),
];

/// DESIGN.md category chips — aligns stripe color with label story.
const List<String> kNoteAccentLabels = [
  'Design',
  'Work',
  'Personal',
  'Priority',
  'Ideas',
  'Planning',
];

String noteAccentLabel(int accentIndex) =>
    kNoteAccentLabels[noteAccentIndex(accentIndex)];

/// Maps any stored index to a valid accent position (handles negatives).
int noteAccentIndex(int raw) {
  final n = kNoteAccents.length;
  return ((raw % n) + n) % n;
}

/// Chip / stripe color for a saved label name.
Color noteLabelColor(String label) {
  final i = kNoteAccentLabels.indexOf(label);
  if (i >= 0) return kNoteAccents[i];
  return const Color(0xFF7C6CFA);
}

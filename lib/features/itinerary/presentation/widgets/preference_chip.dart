import 'package:flutter/material.dart';

/// A custom chip widget for selecting preferences
class PreferenceChip extends StatelessWidget {
  /// The label text to display
  final String label;

  /// Whether the chip is selected
  final bool selected;

  /// Callback when the selection state changes
  final ValueChanged<bool> onSelected;

  /// The background color when selected
  final Color? selectedColor;

  /// The text color when selected
  final Color? selectedTextColor;

  /// Creates a preference chip widget
  const PreferenceChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.selectedColor,
    this.selectedTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor:
          selectedColor ?? theme.colorScheme.primary.withOpacity(0.8),
      checkmarkColor: selectedTextColor ?? theme.colorScheme.onPrimary,
      labelStyle: TextStyle(
        color: selected
            ? (selectedTextColor ?? theme.colorScheme.onPrimary)
            : theme.textTheme.bodyMedium?.color,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: selected ? 2 : 0,
      pressElevation: 4,
    );
  }
}

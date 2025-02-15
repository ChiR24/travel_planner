import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/itinerary.dart';
import '../../models/activity_category.dart';
import '../../providers/notification_provider.dart';

class EditActivityDialog extends ConsumerStatefulWidget {
  final Activity? activity;
  final DateTime dayStartTime;
  final DateTime dayEndTime;

  const EditActivityDialog({
    super.key,
    this.activity,
    required this.dayStartTime,
    required this.dayEndTime,
  });

  @override
  ConsumerState<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends ConsumerState<EditActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagController;
  late DateTime _startTime;
  late DateTime _endTime;
  late ActivityCategory _category;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.activity?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.activity?.description ?? '');
    _tagController = TextEditingController();
    _startTime = widget.activity?.startTime ?? widget.dayStartTime;
    _endTime =
        widget.activity?.endTime ?? _startTime.add(const Duration(hours: 1));
    _category = widget.activity?.category ?? ActivityCategory.other;
    _tags = List<String>.from(widget.activity?.tags ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag.toLowerCase())) {
      setState(() {
        _tags.add(tag.toLowerCase());
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartTime ? _startTime : _endTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dayPeriodTextStyle: GoogleFonts.poppins(),
              hourMinuteTextStyle: GoogleFonts.poppins(
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final DateTime baseDate = isStartTime ? _startTime : _endTime;
        final newDateTime = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          picked.hour,
          picked.minute,
        );

        if (isStartTime) {
          _startTime = newDateTime;
          // Ensure end time is after start time
          if (_endTime.isBefore(_startTime)) {
            _endTime = _startTime.add(const Duration(hours: 1));
          }
        } else {
          if (newDateTime.isAfter(_startTime)) {
            _endTime = newDateTime;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End time must be after start time'),
              ),
            );
          }
        }
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final activity = Activity(
        name: _nameController.text,
        description: _descriptionController.text,
        startTime: _startTime,
        endTime: _endTime,
        category: _category,
        tags: _tags,
      );

      // Schedule notification for the new/updated activity
      final settings = ref.read(notificationSettingsProvider);
      if (settings.activityReminders) {
        final notificationService = ref.read(notificationServiceProvider);
        notificationService.scheduleActivityReminder(
          activity,
          reminderBefore: Duration(minutes: settings.reminderMinutes),
        );
      }

      Navigator.pop(context, activity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeFormat = DateFormat('h:mm a');

    return AlertDialog(
      title: Text(
        widget.activity == null ? 'Add Activity' : 'Edit Activity',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Activity Name',
                  hintText: 'Enter activity name',
                  labelStyle: TextStyle(color: colorScheme.onSurface),
                  hintStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an activity name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ActivityCategory>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: colorScheme.onSurface),
                ),
                dropdownColor: colorScheme.surface,
                style: TextStyle(color: colorScheme.onSurface),
                items: ActivityCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Text(category.icon),
                        const SizedBox(width: 8),
                        Text(
                          category.label,
                          style: GoogleFonts.poppins(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter activity description',
                  labelStyle: TextStyle(color: colorScheme.onSurface),
                  hintStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              Text(
                'Time',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeSelector(
                      context,
                      label: 'Start',
                      time: _startTime,
                      onTap: () => _selectTime(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeSelector(
                      context,
                      label: 'End',
                      time: _endTime,
                      onTap: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Duration: ${_formatDuration(_endTime.difference(_startTime))}',
                  style: GoogleFonts.poppins(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tags',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._tags.map((tag) => Chip(
                        label: Text(
                          tag,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                        onDeleted: () => _removeTag(tag),
                        deleteIcon: const Icon(Icons.close, size: 16),
                      )),
                  InputChip(
                    label: SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Add tag',
                          hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6)),
                        ),
                        style: TextStyle(color: colorScheme.onSurface),
                        onSubmitted: _addTag,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: Text(widget.activity == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(
    BuildContext context, {
    required String label,
    required DateTime time,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeFormat = DateFormat('h:mm a');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  timeFormat.format(time),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }
}

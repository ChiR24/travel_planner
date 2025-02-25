import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../../../models/itinerary.dart';
import '../../domain/ai_itinerary_service.dart';
import '../widgets/preference_chip.dart';

class AIItineraryGeneratorScreen extends ConsumerStatefulWidget {
  const AIItineraryGeneratorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIItineraryGeneratorScreen> createState() =>
      _AIItineraryGeneratorScreenState();
}

class _AIItineraryGeneratorScreenState
    extends ConsumerState<AIItineraryGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _budget = 'moderate';
  final List<String> _selectedPreferences = [];

  bool _isGenerating = false;
  Itinerary? _generatedItinerary;

  final List<String> _availablePreferences = [
    'adventure',
    'relaxation',
    'culture',
    'food',
    'shopping',
    'nature',
    'history',
    'family-friendly',
    'budget-friendly',
    'luxury',
    'nightlife',
  ];

  final List<String> _budgetOptions = [
    'budget',
    'moderate',
    'luxury',
  ];

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Itinerary Generator'),
      ),
      body: _generatedItinerary != null
          ? _buildItineraryResult()
          : _buildGeneratorForm(),
    );
  }

  Widget _buildGeneratorForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            const Text(
              'Let AI plan your perfect trip',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fill in the details below and our AI will create a personalized itinerary for your trip.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Destination field
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                hintText: 'Where are you going?',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a destination';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date range
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _startDate != null
                            ? DateFormat('MMM d, yyyy').format(_startDate!)
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _endDate != null
                            ? DateFormat('MMM d, yyyy').format(_endDate!)
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_startDate != null &&
                _endDate != null &&
                _endDate!.isBefore(_startDate!))
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'End date must be after start date',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24),

            // Budget selection
            const Text(
              'Budget',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _budgetOptions.map((budget) {
                return ChoiceChip(
                  label: Text(budget.capitalize()),
                  selected: _budget == budget,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _budget = budget;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Preferences
            const Text(
              'Preferences (select up to 5)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _availablePreferences.map((preference) {
                return PreferenceChip(
                  label: preference.capitalize(),
                  selected: _selectedPreferences.contains(preference),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_selectedPreferences.length < 5) {
                          _selectedPreferences.add(preference);
                        }
                      } else {
                        _selectedPreferences.remove(preference);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateItinerary,
                child: _isGenerating
                    ? const LoadingIndicator(size: 24)
                    : const Text('Generate Itinerary'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryResult() {
    final itinerary = _generatedItinerary!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Header
              Text(
                'Your Trip to ${itinerary.destinations.join(', ')}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${DateFormat('MMM d').format(itinerary.startDate)} - ${DateFormat('MMM d, yyyy').format(itinerary.endDate)} · ${itinerary.duration.inDays} days',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Days
              ...itinerary.days.asMap().entries.map((entry) {
                final index = entry.key;
                final day = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${index + 1} - ${day.location}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Activities
                        ...day.activities.map((activity) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('h:mm a')
                                          .format(activity.startTime),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('h:mm a')
                                          .format(activity.endTime),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activity.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(activity.description),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: activity.tags.map((tag) {
                                          return Chip(
                                            label: Text(tag),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        // Bottom buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _generatedItinerary = null;
                    });
                  },
                  child: const Text('Start Over'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Save the itinerary
                    // This would typically call a method to save to a repository
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Itinerary saved successfully!'),
                      ),
                    );
                    Navigator.pop(context, _generatedItinerary);
                  },
                  child: const Text('Save Itinerary'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;

        // If end date is before start date, update it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate!.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ??
          (_startDate?.add(const Duration(days: 1)) ??
              DateTime.now().add(const Duration(days: 1))),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _generateItinerary() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      if (_endDate!.isBefore(_startDate!)) {
        // Show error
        return;
      }

      setState(() {
        _isGenerating = true;
      });

      try {
        final params = {
          'destination': _destinationController.text,
          'startDate': _startDate,
          'endDate': _endDate,
          'preferences': _selectedPreferences,
          'budget': _budget,
        };

        final itinerary =
            await ref.read(aiItineraryServiceProvider).generateItinerary(
                  destination: _destinationController.text,
                  startDate: _startDate!,
                  endDate: _endDate!,
                  preferences: _selectedPreferences,
                  budget: _budget,
                );

        setState(() {
          _generatedItinerary = itinerary;
          _isGenerating = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating itinerary: $e'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}

// Helper extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

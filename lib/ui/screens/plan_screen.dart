import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/itinerary_provider.dart';
import '../widgets/loading_screen.dart';
import '../widgets/custom_preference_input.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationsController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final Map<String, bool> _preferences = {
    'Cultural Activities': false,
    'Outdoor Activities': false,
    'Food & Dining': false,
    'Shopping': false,
    'Historical Sites': false,
    'Museums & Art': false,
    'Nightlife': false,
    'Family Friendly': false,
    'Budget Friendly': false,
    'Luxury': false,
  };
  final Map<String, String> _customPreferences = {};

  @override
  void initState() {
    super.initState();
    // If a destination was passed through navigation, pre-fill it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra != null && extra is Map<String, dynamic>) {
        final destination = extra['destination'] as String?;
        if (destination != null && _destinationsController.text.isEmpty) {
          _destinationsController.text = destination;
        }
      }
    });
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate =
        isStartDate ? DateTime.now() : _startDate ?? DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleCustomPreference(String key, String value) {
    setState(() {
      if (value.isEmpty) {
        _customPreferences.remove(key);
      } else {
        _customPreferences[key] = value;
      }
    });
  }

  void _generateItinerary() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select travel dates')),
        );
        return;
      }

      final destinations = _destinationsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (destinations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enter at least one destination')),
        );
        return;
      }

      // Combine standard and custom preferences
      final allPreferences = {
        ..._preferences,
        ..._customPreferences,
      };

      ref.read(generationProvider.notifier).generateItinerary(
            GenerateItineraryParams(
              origin: _originController.text,
              destinations: destinations,
              startDate: _startDate!,
              endDate: _endDate!,
              preferences: allPreferences,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final generationState = ref.watch(generationProvider);

    // Add navigation when itinerary is generated
    ref.listen<GenerationState>(generationProvider, (previous, next) {
      if (!next.isLoading &&
          next.itinerary != null &&
          previous?.isLoading == true) {
        context.go('/itinerary/${next.itinerary!.id}');
      }
    });

    if (generationState.isLoading) {
      return LoadingScreen(
        destination: _destinationsController.text.split(',').first.trim(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Plan Your Trip',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Details',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Starting Point',
                  hintText: 'Enter your starting location',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a starting point';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destinationsController,
                decoration: const InputDecoration(
                  labelText: 'Destinations',
                  hintText: 'Enter destinations, separated by commas',
                  prefixIcon: Icon(Icons.place),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter at least one destination';
                  }
                  return null;
                },
                maxLines: null,
              ),
              const SizedBox(height: 24),
              Text(
                'Travel Dates',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _startDate == null
                              ? 'Select Date'
                              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _endDate == null
                              ? 'Select Date'
                              : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Preferences',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _preferences.keys.map((preference) {
                  return FilterChip(
                    label: Text(preference),
                    selected: _preferences[preference]!,
                    onSelected: (selected) {
                      setState(() {
                        _preferences[preference] = selected;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              CustomPreferenceInput(
                onPreferenceAdded: _handleCustomPreference,
                existingPreferences: _customPreferences,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generateItinerary,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Generate Itinerary',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              if (generationState.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    generationState.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

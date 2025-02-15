import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/interactive_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/custom_preference_input.dart';
import '../../providers/itinerary_provider.dart';

final _planLoadingProvider = StateProvider<bool>((ref) => true);
final _generatingProvider = StateProvider<bool>((ref) => false);

// Add preference categories
final _preferenceCategories = {
  'Activities': [
    'Cultural Activities',
    'Outdoor Activities',
    'Museums & Art',
    'Historical Sites',
  ],
  'Lifestyle': [
    'Food & Dining',
    'Shopping',
    'Nightlife',
  ],
  'Travel Style': [
    'Family Friendly',
    'Budget Friendly',
    'Luxury',
  ],
};

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
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

  // Add expanded states for categories
  final Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Check for pre-filled destination
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra != null && extra is Map<String, dynamic>) {
        final destination = extra['destination'] as String?;
        if (destination != null && _destinationController.text.isEmpty) {
          _destinationController.text = destination;
        }
      }
    });

    // Simulate data loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        ref.read(_planLoadingProvider.notifier).state = false;
      }
    });

    // Initialize all categories as expanded
    for (final category in _preferenceCategories.keys) {
      _expandedCategories[category] = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ??
              (_startDate?.add(const Duration(days: 1)) ?? DateTime.now()),
      firstDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = _formatDate(picked);
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
            _endDateController.clear();
          }
        } else {
          _endDate = picked;
          _endDateController.text = _formatDate(picked);
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  void _generateItinerary() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select travel dates')),
        );
        return;
      }

      final destinations = _destinationController.text
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

      // Set generating state to true
      ref.read(_generatingProvider.notifier).state = true;

      try {
        // Combine standard and custom preferences
        final allPreferences = {
          ..._preferences,
          ..._customPreferences,
        };

        await ref.read(generationProvider.notifier).generateItinerary(
              GenerateItineraryParams(
                origin: _originController.text,
                destinations: destinations,
                startDate: _startDate!,
                endDate: _endDate!,
                preferences: allPreferences,
              ),
            );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating itinerary: $e')),
          );
        }
      } finally {
        if (mounted) {
          ref.read(_generatingProvider.notifier).state = false;
        }
      }
    }
  }

  Widget _buildPreferencesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.interests,
                color: colorScheme.secondary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                  Text(
                    'Customize your experience',
                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.unfold_more,
                color: colorScheme.secondary,
              ),
              onPressed: () {
                setState(() {
                  final allExpanded =
                      _expandedCategories.values.every((v) => v);
                  for (final category in _preferenceCategories.keys) {
                    _expandedCategories[category] = !allExpanded;
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        ..._preferenceCategories.entries.map((category) {
          return Column(
            children: [
              InteractiveCard(
                onTap: () {
                  setState(() {
                    _expandedCategories[category.key] =
                        !(_expandedCategories[category.key] ?? false);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            category.key,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.secondary,
                            ),
                          ),
                          const Spacer(),
                          AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            turns: (_expandedCategories[category.key] ?? false)
                                ? 0.5
                                : 0,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox(height: 0),
                        secondChild: Column(
                          children: [
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: category.value.map((preference) {
                                return AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: _preferences[preference]! ? 1.05 : 1.0,
                                  child: FilterChip(
                                    label: Text(
                                      preference,
                                      style: GoogleFonts.poppins(
                                        color: _preferences[preference]!
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    selected: _preferences[preference]!,
                                    onSelected: (selected) {
                                      setState(() {
                                        _preferences[preference] = selected;
                                      });
                                    },
                                    selectedColor: colorScheme.primary,
                                    checkmarkColor: colorScheme.onPrimary,
                                    avatar: _preferences[preference]!
                                        ? Icon(
                                            _getPreferenceIcon(preference),
                                            size: 18,
                                            color: colorScheme.onPrimary,
                                          )
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        crossFadeState:
                            (_expandedCategories[category.key] ?? false)
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
        InteractiveCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Preferences',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                CustomPreferenceInput(
                  onPreferenceAdded: _handleCustomPreference,
                  existingPreferences: _customPreferences,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getPreferenceIcon(String preference) {
    switch (preference) {
      case 'Cultural Activities':
        return Icons.theater_comedy;
      case 'Outdoor Activities':
        return Icons.landscape;
      case 'Museums & Art':
        return Icons.museum;
      case 'Historical Sites':
        return Icons.account_balance;
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Nightlife':
        return Icons.nightlife;
      case 'Family Friendly':
        return Icons.family_restroom;
      case 'Budget Friendly':
        return Icons.savings;
      case 'Luxury':
        return Icons.diamond;
      default:
        return Icons.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = ref.watch(_planLoadingProvider);
    final isGenerating = ref.watch(_generatingProvider);
    final generationState = ref.watch(generationProvider);

    // Add navigation when itinerary is generated
    ref.listen<GenerationState>(generationProvider, (previous, next) {
      if (!next.isLoading &&
          next.itinerary != null &&
          previous?.isLoading == true) {
        context.go('/itinerary/${next.itinerary!.id}');
      }
    });

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
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeInAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoading(
                isLoading: isLoading,
                child: InteractiveCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.flight_takeoff,
                                  color: colorScheme.primary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Trip Details',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      'Plan your perfect journey',
                                      style: GoogleFonts.poppins(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _originController,
                            decoration: InputDecoration(
                              labelText: 'Starting Point',
                              hintText: 'Enter your starting location',
                              prefixIcon: Icon(Icons.location_on,
                                  color: colorScheme.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                            controller: _destinationController,
                            decoration: InputDecoration(
                              labelText: 'Destinations',
                              hintText:
                                  'Enter destinations, separated by commas',
                              prefixIcon:
                                  Icon(Icons.place, color: colorScheme.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter at least one destination';
                              }
                              return null;
                            },
                            maxLines: null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _startDateController,
                                  readOnly: true,
                                  onTap: () => _selectDate(context, true),
                                  decoration: InputDecoration(
                                    labelText: 'Start Date',
                                    hintText: 'Select date',
                                    prefixIcon: Icon(Icons.calendar_today,
                                        color: colorScheme.primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _endDateController,
                                  readOnly: true,
                                  onTap: () => _selectDate(context, false),
                                  decoration: InputDecoration(
                                    labelText: 'End Date',
                                    hintText: 'Select date',
                                    prefixIcon: Icon(Icons.calendar_today,
                                        color: colorScheme.primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ShimmerLoading(
                isLoading: isLoading,
                child: InteractiveCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildPreferencesSection(context),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ShimmerLoading(
                isLoading: isLoading,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: isGenerating ? null : _generateItinerary,
                    icon: isGenerating
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Icon(Icons.explore),
                    label: Text(
                      isGenerating ? 'Generating...' : 'Generate Itinerary',
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
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            generationState.error!,
                            style: GoogleFonts.poppins(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ShimmerLoading(
                isLoading: isLoading,
                child: Text(
                  'Popular Destinations',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildDestinationCard(
                      context,
                      image:
                          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=600',
                      name: 'Paris',
                      description: 'The City of Light',
                      isLoading: isLoading,
                    ),
                    _buildDestinationCard(
                      context,
                      image:
                          'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=600',
                      name: 'Barcelona',
                      description: 'Heart of Catalonia',
                      isLoading: isLoading,
                    ),
                    _buildDestinationCard(
                      context,
                      image:
                          'https://images.unsplash.com/photo-1534351590666-13e3e96b5017?w=600',
                      name: 'Amsterdam',
                      description: 'Venice of the North',
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context, {
    required String image,
    required String name,
    required String description,
    required bool isLoading,
  }) {
    return ShimmerLoading(
      isLoading: isLoading,
      child: InteractiveCard(
        onTap: () {
          final currentDestinations = _destinationController.text.split(',');
          if (currentDestinations.length == 1 &&
              currentDestinations[0].isEmpty) {
            _destinationController.text = name;
          } else {
            _destinationController.text =
                '${_destinationController.text}, $name';
          }
        },
        child: Container(
          width: 200,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

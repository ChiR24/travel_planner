import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPreferenceInput extends StatefulWidget {
  final void Function(String key, String value) onPreferenceAdded;
  final Map<String, dynamic> existingPreferences;

  const CustomPreferenceInput({
    super.key,
    required this.onPreferenceAdded,
    required this.existingPreferences,
  });

  @override
  State<CustomPreferenceInput> createState() => _CustomPreferenceInputState();
}

class _CustomPreferenceInputState extends State<CustomPreferenceInput>
    with SingleTickerProviderStateMixin {
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _selectedCategory = '';
  bool _isSearching = false;

  // Suggested preferences with example values and icons
  final Map<String, Map<String, dynamic>> _suggestedPreferences = {
    'Food Type': {
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'values': [
        'Vegetarian',
        'Vegan',
        'Halal',
        'Kosher',
        'Seafood',
        'Local Cuisine',
        'Street Food',
        'Fine Dining'
      ],
    },
    'Activity Level': {
      'icon': Icons.directions_run,
      'color': Colors.green,
      'values': ['Low', 'Moderate', 'High', 'Extreme', 'Adaptive', 'Mixed'],
    },
    'Transportation': {
      'icon': Icons.directions_car,
      'color': Colors.blue,
      'values': [
        'Public Transit',
        'Walking',
        'Car Rental',
        'Bike',
        'Private Driver',
        'Ride Share',
        'Water Transport'
      ],
    },
    'Accommodation': {
      'icon': Icons.hotel,
      'color': Colors.purple,
      'values': [
        'Hotel',
        'Hostel',
        'Resort',
        'Apartment',
        'Boutique',
        'Villa',
        'Eco Lodge',
        'Luxury Suite'
      ],
    },
    'Budget Per Day': {
      'icon': Icons.attach_money,
      'color': Colors.green,
      'values': [
        r'$100',
        r'$200',
        r'$500',
        'Luxury',
        'Budget',
        'Mid-Range',
        'All-Inclusive'
      ],
    },
    'Language': {
      'icon': Icons.translate,
      'color': Colors.indigo,
      'values': [
        'English Only',
        'Multi-lingual',
        'Local Language',
        'Translation Services',
        'Language Learning'
      ],
    },
    'Pace': {
      'icon': Icons.speed,
      'color': Colors.amber,
      'values': ['Relaxed', 'Moderate', 'Fast-paced', 'Flexible', 'Structured'],
    },
    'Special Requirements': {
      'icon': Icons.accessible,
      'color': Colors.red,
      'values': [
        'Wheelchair Access',
        'Child-friendly',
        'Pet-friendly',
        'Senior-friendly',
        'Allergy-aware',
        'Medical Support',
      ],
    },
    'Time of Day': {
      'icon': Icons.access_time,
      'color': Colors.deepPurple,
      'values': [
        'Early Bird',
        'Day Time',
        'Night Owl',
        'Flexible Hours',
        'Specific Times'
      ],
    },
    'Weather Preference': {
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
      'values': [
        'Indoor on Rain',
        'Any Weather',
        'Sunny Days Only',
        'Cool Weather',
        'Seasonal Activities'
      ],
    },
    'Cultural Interest': {
      'icon': Icons.museum,
      'color': Colors.brown,
      'values': [
        'Local Traditions',
        'Historical Sites',
        'Art Galleries',
        'Music Venues',
        'Cultural Events'
      ],
    },
    'Social Style': {
      'icon': Icons.people,
      'color': Colors.teal,
      'values': [
        'Solo Activities',
        'Group Tours',
        'Mix of Both',
        'Local Interactions',
        'Private Guide'
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addPreference() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onPreferenceAdded(
          _keyController.text.trim(), _valueController.text.trim());
      _keyController.clear();
      _valueController.clear();
      _showSnackBar('Preference added successfully!');
    }
  }

  void _selectSuggestedPreference(String key, String value) {
    setState(() {
      _keyController.text = key;
      _valueController.text = value;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  List<MapEntry<String, Map<String, dynamic>>> _getFilteredPreferences() {
    if (_searchController.text.isEmpty) {
      return _suggestedPreferences.entries.where((entry) {
        return _selectedCategory.isEmpty || entry.key == _selectedCategory;
      }).toList();
    }

    final searchTerm = _searchController.text.toLowerCase();
    return _suggestedPreferences.entries.where((entry) {
      final matchesCategory = entry.key.toLowerCase().contains(searchTerm);
      final matchesValues = (entry.value['values'] as List).any(
        (value) => value.toString().toLowerCase().contains(searchTerm),
      );
      return (matchesCategory || matchesValues) &&
          (_selectedCategory.isEmpty || entry.key == _selectedCategory);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search and Filter
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search preferences...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.filter_list,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _selectedCategory = '';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Category Filter
                  if (_isSearching) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: _selectedCategory.isEmpty,
                            onSelected: (selected) {
                              setState(() => _selectedCategory = '');
                            },
                          ),
                          const SizedBox(width: 8),
                          ...(_suggestedPreferences.keys.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: _selectedCategory == category,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory =
                                        selected ? category : '';
                                  });
                                },
                              ),
                            );
                          })),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Input Fields
                  TextFormField(
                    controller: _keyController,
                    decoration: InputDecoration(
                      labelText: 'Preference Key',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a preference key';
                      }
                      if (widget.existingPreferences
                          .containsKey(value.trim())) {
                        return 'This preference already exists';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _valueController,
                    decoration: InputDecoration(
                      labelText: 'Preference Value',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a preference value';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _addPreference,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Preference'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Suggested Preferences
                  Text(
                    'Suggested Preferences',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _getFilteredPreferences().length,
                      itemBuilder: (context, index) {
                        final entry = _getFilteredPreferences()[index];
                        return ExpansionTile(
                          leading: Icon(
                            entry.value['icon'] as IconData,
                            color: entry.value['color'] as Color,
                          ),
                          title: Text(
                            entry.key,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (entry.value['values'] as List)
                                    .map((value) {
                                  return ActionChip(
                                    label: Text(value.toString()),
                                    onPressed: () => _selectSuggestedPreference(
                                      entry.key,
                                      value.toString(),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

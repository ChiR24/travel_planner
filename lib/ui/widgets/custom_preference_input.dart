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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Custom Preference',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Customize your trip with specific preferences',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(_isSearching ? Icons.close : Icons.search),
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) {
                            _searchController.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),
                if (_isSearching) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search preferences',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory.isEmpty,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = '';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ..._suggestedPreferences.keys.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : '';
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _keyController,
                        decoration: InputDecoration(
                          labelText: 'Preference Name',
                          hintText: 'e.g., Food Type, Activity Level',
                          prefixIcon: const Icon(Icons.label_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a preference name';
                          }
                          if (widget.existingPreferences
                              .containsKey(value.trim())) {
                            return 'This preference already exists';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _valueController,
                        decoration: InputDecoration(
                          labelText: 'Value',
                          hintText: 'e.g., Vegetarian, High',
                          prefixIcon: const Icon(Icons.edit_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a value';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => _buildSuggestionsSheet(context),
                        );
                      },
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('View Suggestions'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addPreference,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Preference'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.existingPreferences.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Custom Preferences',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Clear all preferences
                          widget.existingPreferences.keys
                              .toList()
                              .forEach((key) {
                            widget.onPreferenceAdded(key, '');
                          });
                        },
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.existingPreferences.entries.map((entry) {
                      final category = _suggestedPreferences[entry.key];
                      final icon =
                          category?['icon'] as IconData? ?? Icons.label_outline;
                      final color =
                          category?['color'] as Color? ?? colorScheme.primary;

                      return Chip(
                        avatar: Icon(icon, color: color, size: 18),
                        label: Text('${entry.key}: ${entry.value}'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          widget.onPreferenceAdded(entry.key, '');
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final filteredPreferences = _getFilteredPreferences();

        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Suggested Preferences',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap any suggestion to use it',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredPreferences.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No matching preferences found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: filteredPreferences.length,
                        itemBuilder: (context, index) {
                          final entry = filteredPreferences[index];
                          final category = entry.value;

                          return Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              leading: Icon(
                                category['icon'] as IconData,
                                color: category['color'] as Color,
                              ),
                              title: Text(
                                entry.key,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (category['values'] as List)
                                        .map((value) {
                                      return ActionChip(
                                        avatar: Icon(
                                          category['icon'] as IconData,
                                          size: 18,
                                          color: category['color'] as Color,
                                        ),
                                        label: Text(value),
                                        onPressed: () {
                                          _selectSuggestedPreference(
                                              entry.key, value);
                                          Navigator.pop(context);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatefulWidget {
  final String destination;

  const LoadingScreen({
    super.key,
    required this.destination,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int _currentTipIndex = 0;
  late Timer _timer;
  late final List<String> _travelTips;

  @override
  void initState() {
    super.initState();
    _travelTips = [
      '🌍 Researching local customs and traditions...',
      '🗺️ Finding hidden gems in ${widget.destination}...',
      '🍽️ Discovering local culinary delights...',
      '📸 Identifying the best photo spots...',
      '🎨 Exploring cultural attractions...',
      '🌅 Planning optimal visit times...',
      '🚶‍♂️ Creating walkable routes...',
      '🎭 Finding local events and festivals...',
      '☔ Checking weather patterns...',
      '💰 Estimating local costs...',
    ];
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % _travelTips.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/animations/travel_loading.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            // Loading text
            Text(
              'Creating Your Perfect Itinerary',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'for ${widget.destination}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 24),
            // Travel tip with fade transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Container(
                key: ValueKey<int>(_currentTipIndex),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _travelTips[_currentTipIndex],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Progress indicator
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

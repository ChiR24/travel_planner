import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/interactive_card.dart';
import '../widgets/shimmer_loading.dart';
import 'package:lottie/lottie.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

final _aboutLoadingProvider = StateProvider<bool>((ref) => true);

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

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

    // Start loading animation
    _controller.forward();

    // Simulate data loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        ref.read(_aboutLoadingProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final packageInfo = ref.watch(packageInfoProvider);
    final isLoading = ref.watch(_aboutLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: Text(
          'About',
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  ShimmerLoading(
                    isLoading: isLoading,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.travel_explore,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ShimmerLoading(
                    isLoading: isLoading,
                    child: Text(
                      'Travel Planner',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShimmerLoading(
                    isLoading: isLoading,
                    child: packageInfo.when(
                      data: (info) => Text(
                        'Version ${info.version} (${info.buildNumber})',
                        style: GoogleFonts.poppins(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      loading: () => const SizedBox(
                        height: 20,
                        width: 150,
                      ),
                      error: (_, __) =>
                          const Text('Version information unavailable'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ShimmerLoading(
              isLoading: isLoading,
              child: InteractiveCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.info_outline,
                                color: colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'App Information',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Travel Planner is your all-in-one travel companion app. '
                        'Plan trips, manage itineraries, and keep track of your travel experiences '
                        'with ease.',
                        style: GoogleFonts.poppins(
                          color: colorScheme.onSurface.withOpacity(0.8),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ShimmerLoading(
              isLoading: isLoading,
              child: InteractiveCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.star_outline,
                                color: colorScheme.secondary),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Features',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        context,
                        icon: Icons.map_outlined,
                        text: 'Trip Planning',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.calendar_today_outlined,
                        text: 'Itinerary Management',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.local_activity_outlined,
                        text: 'Activity Scheduling',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.analytics_outlined,
                        text: 'Travel Metrics',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.offline_bolt_outlined,
                        text: 'Offline Support',
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.dark_mode_outlined,
                        text: 'Dark Mode',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ShimmerLoading(
              isLoading: isLoading,
              child: InteractiveCard(
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Travel Planner',
                  applicationVersion: packageInfo.when(
                    data: (info) => '${info.version} (${info.buildNumber})',
                    loading: () => '',
                    error: (_, __) => 'Unknown',
                  ),
                  applicationIcon: Icon(
                    Icons.travel_explore,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.gavel_outlined, color: colorScheme.tertiary),
                  ),
                  title: Text(
                    'Licenses',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            if (!isLoading) ...[
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '© ${DateTime.now().year} Travel Planner',
                  style: GoogleFonts.poppins(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

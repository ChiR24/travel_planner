import 'package:flutter/material.dart';

/// A widget that displays a skeleton loading animation.
/// Used to show a loading state that resembles the actual content.
class SkeletonLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const _ShimmerEffect(),
    );
  }
}

/// A widget that displays a shimmer effect animation.
class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
              ],
              stops: [
                0.0,
                0.5 + (_animation.value / 4),
                1.0,
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: Container(
            color: Colors.white,
          ),
        );
      },
    );
  }
}

/// A widget that displays a skeleton loading animation for an itinerary list.
class ItineraryListSkeleton extends StatelessWidget {
  final int itemCount;

  const ItineraryListSkeleton({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _ItineraryCardSkeleton(),
        );
      },
    );
  }
}

/// A widget that displays a skeleton loading animation for an itinerary card.
class _ItineraryCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            SkeletonLoading(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 24,
            ),
            const SizedBox(height: 16),
            // Date range
            SkeletonLoading(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 16,
            ),
            const SizedBox(height: 16),
            // Location
            SkeletonLoading(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 16,
            ),
            const SizedBox(height: 16),
            // Activity count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoading(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 16,
                ),
                SkeletonLoading(
                  width: 80,
                  height: 32,
                  borderRadius: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

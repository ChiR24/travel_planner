import 'package:flutter/material.dart';

/// Breakpoints for different device sizes
class ScreenBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// A widget that adapts its layout based on the screen size.
/// Provides different layouts for mobile, tablet, and desktop.
class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AdaptiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ScreenBreakpoints.desktop &&
            desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= ScreenBreakpoints.tablet &&
            tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Extension on BuildContext to easily access screen size information
extension ScreenSizeExtension on BuildContext {
  /// Returns true if the screen is considered a mobile screen
  bool get isMobile =>
      MediaQuery.of(this).size.width < ScreenBreakpoints.mobile;

  /// Returns true if the screen is considered a tablet screen
  bool get isTablet =>
      MediaQuery.of(this).size.width >= ScreenBreakpoints.mobile &&
      MediaQuery.of(this).size.width < ScreenBreakpoints.desktop;

  /// Returns true if the screen is considered a desktop screen
  bool get isDesktop =>
      MediaQuery.of(this).size.width >= ScreenBreakpoints.desktop;

  /// Returns the current screen type as a string
  String get screenType {
    if (isDesktop) return 'Desktop';
    if (isTablet) return 'Tablet';
    return 'Mobile';
  }
}

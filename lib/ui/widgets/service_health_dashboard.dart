import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/service_metrics.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';

class ServiceHealthDashboard extends ConsumerStatefulWidget {
  final MetricsService metricsService;

  const ServiceHealthDashboard({
    super.key,
    required this.metricsService,
  });

  @override
  ConsumerState<ServiceHealthDashboard> createState() =>
      _ServiceHealthDashboardState();
}

class _ServiceHealthDashboardState
    extends ConsumerState<ServiceHealthDashboard> {
  List<ServiceMetric> _recentMetrics = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
    widget.metricsService.addListener(_onMetricsUpdate);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    widget.metricsService.removeListener(_onMetricsUpdate);
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateMetrics();
    });
  }

  void _onMetricsUpdate(ServiceMetric metric) {
    setState(() {
      _recentMetrics = [..._recentMetrics, metric]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (_recentMetrics.length > 100) {
        _recentMetrics = _recentMetrics.take(100).toList();
      }
    });
  }

  void _updateMetrics() {
    setState(() {
      // Update state with new metrics
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.metricsService.metrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/metrics_loading.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            Text(
              'No metrics data available yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate test metrics to see the dashboard in action',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Response Time Distribution',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: widget.metricsService.metrics
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.duration.inMilliseconds.toDouble(),
                            ))
                        .toList(),
                    isCurved: true,
                    color: colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Operations',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.metricsService.metrics.length,
            itemBuilder: (context, index) {
              final metric = widget.metricsService.metrics[index];
              return ListTile(
                leading: Icon(
                  metric.isSuccess ? Icons.check_circle : Icons.error,
                  color: metric.isSuccess ? Colors.green : Colors.red,
                ),
                title: Text(
                  metric.operation,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${metric.duration.inMilliseconds}ms',
                  style: GoogleFonts.poppins(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                trailing: metric.isSuccess
                    ? null
                    : Text(
                        metric.errorCode?.toString() ?? 'Unknown Error',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

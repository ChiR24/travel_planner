import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/service_metrics.dart';

class MetricsChart extends StatelessWidget {
  final List<ServiceMetric> metrics;

  const MetricsChart({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (metrics.isEmpty) {
      return Center(
        child: Text(
          'No metrics data available',
          style: GoogleFonts.poppins(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    // Group metrics by operation
    final operationMetrics = <String, List<ServiceMetric>>{};
    for (final metric in metrics) {
      operationMetrics.putIfAbsent(metric.operation, () => []).add(metric);
    }

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                horizontalInterval: 100,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: colorScheme.onSurface.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: colorScheme.onSurface.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= metrics.length) {
                        return const Text('');
                      }
                      final date = metrics[value.toInt()].timestamp;
                      return Text(
                        '${date.hour}:${date.minute}',
                        style: GoogleFonts.poppins(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 100,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}ms',
                        style: GoogleFonts.poppins(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              minX: 0,
              maxX: metrics.length.toDouble() - 1,
              minY: 0,
              maxY: _getMaxDuration(),
              lineBarsData: _getLineBarsData(colorScheme),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(colorScheme),
      ],
    );
  }

  double _getMaxDuration() {
    if (metrics.isEmpty) return 1000;
    return metrics
        .map((m) => m.duration.inMilliseconds.toDouble())
        .reduce((a, b) => a > b ? a : b)
        .ceilToDouble();
  }

  List<LineChartBarData> _getLineBarsData(ColorScheme colorScheme) {
    final operationMetrics = <String, List<ServiceMetric>>{};
    for (final metric in metrics) {
      operationMetrics.putIfAbsent(metric.operation, () => []).add(metric);
    }

    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return operationMetrics.entries.toList().asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final entry = mapEntry.value;
      final metrics = entry.value;

      return LineChartBarData(
        spots: metrics.asMap().entries.map((e) {
          return FlSpot(
            e.key.toDouble(),
            e.value.duration.inMilliseconds.toDouble(),
          );
        }).toList(),
        isCurved: true,
        color: colors[index % colors.length],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          color: colors[index % colors.length].withOpacity(0.1),
        ),
      );
    }).toList();
  }

  Widget _buildLegend(ColorScheme colorScheme) {
    final operations = metrics.map((m) => m.operation).toSet().toList();
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: operations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                operations[index],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

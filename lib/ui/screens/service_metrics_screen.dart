import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/metrics_provider.dart';
import '../../services/service_metrics.dart';
import '../../services/base_service_response.dart';
import '../widgets/service_health_dashboard.dart';
import 'package:go_router/go_router.dart';

class ServiceMetricsScreen extends ConsumerWidget {
  const ServiceMetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsService = ref.watch(metricsServiceProvider);
    final healthState = ref.watch(serviceHealthProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Service Metrics',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Generate test metrics
              _generateTestMetrics(metricsService);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHealthIndicator(context, healthState),
          Expanded(
            child: ServiceHealthDashboard(
              metricsService: metricsService,
            ),
          ),
        ],
      ),
    );
  }

  void _generateTestMetrics(MetricsService metricsService) async {
    final operations = [
      'api_request',
      'database_query',
      'cache_operation',
      'file_upload',
    ];

    final random = Random();

    // Generate 20 test metrics
    for (var i = 0; i < 20; i++) {
      final operation = operations[random.nextInt(operations.length)];
      final duration = Duration(milliseconds: 100 + random.nextInt(900));
      final success = random.nextDouble() > 0.1; // 10% error rate

      if (success) {
        await metricsService.trackOperation(
          operation: operation,
          action: () async {
            await Future.delayed(const Duration(milliseconds: 50));
            return ServiceResponse.success('Test data $i');
          },
        );
      } else {
        await metricsService.trackOperation(
          operation: operation,
          action: () async {
            await Future.delayed(const Duration(milliseconds: 50));
            return ServiceResponse.error(
              code: ServiceErrorCode
                  .values[random.nextInt(ServiceErrorCode.values.length)],
              message: 'Test error $i',
            );
          },
        );
      }

      // Add a small delay between metrics
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Widget _buildHealthIndicator(BuildContext context, ServiceHealth health) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: health.isHealthy
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: health.isHealthy
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            health.isHealthy ? Icons.check_circle : Icons.error,
            color: health.isHealthy ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  health.status,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (health.lastCheck != null)
                  Text(
                    'Last checked: ${_formatDateTime(health.lastCheck!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Error Rate: ${(health.errorRate * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Active Connections: ${health.activeConnections}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

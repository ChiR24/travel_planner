import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/service_metrics.dart';

final metricsServiceProvider = Provider<MetricsService>((ref) {
  final service = MetricsService();
  ref.onDispose(() => service.dispose());
  return service;
});

final serviceMetricsProvider = StreamProvider<List<ServiceMetric>>((ref) {
  final service = ref.watch(metricsServiceProvider);
  return service.metricsStream;
});

class ServiceHealth {
  final bool isHealthy;
  final String status;
  final double errorRate;
  final int activeConnections;
  final DateTime? lastCheck;

  ServiceHealth({
    required this.isHealthy,
    required this.status,
    required this.errorRate,
    required this.activeConnections,
    this.lastCheck,
  });
}

final serviceHealthProvider = Provider<ServiceHealth>((ref) {
  final service = ref.watch(metricsServiceProvider);
  final errorRate = service.errorRate;
  final isHealthy =
      errorRate < 0.1; // Less than 10% error rate is considered healthy

  return ServiceHealth(
    isHealthy: isHealthy,
    status: isHealthy ? 'Healthy' : 'Degraded',
    errorRate: errorRate,
    activeConnections: service.metrics.length,
    lastCheck: service.metrics.isEmpty ? null : service.metrics.last.timestamp,
  );
});

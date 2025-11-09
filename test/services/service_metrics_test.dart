import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/services/service_metrics.dart';
import 'package:travel_planner/services/base_service_response.dart';

void main() {
  late MetricsService metricsService;

  setUp(() {
    metricsService = MetricsService(
      retentionPeriod: const Duration(minutes: 5),
    );
  });

  tearDown(() {
    metricsService.dispose();
  });

  group('MetricsService - Operation Tracking', () {
    test('tracks successful operation', () async {
      final response = await metricsService.trackOperation(
        operation: 'test_operation',
        action: () async => ServiceResponse.success('test data'),
      );

      expect(response.success, true);
      expect(response.data, 'test data');

      final metrics = metricsService.getMetricsForOperation('test_operation');
      expect(metrics.length, 1);
      expect(metrics.first.success, true);
      expect(metrics.first.operation, 'test_operation');
      expect(metrics.first.duration.inMilliseconds, greaterThan(0));
    });

    test('tracks failed operation', () async {
      final response = await metricsService.trackOperation(
        operation: 'failed_operation',
        action: () async => ServiceResponse.error(
          ServiceErrorCode.INVALID_DATA,
          'Test error',
        ),
      );

      expect(response.success, false);
      expect(response.errorCode, ServiceErrorCode.INVALID_DATA);

      final metrics = metricsService.getMetricsForOperation('failed_operation');
      expect(metrics.length, 1);
      expect(metrics.first.success, false);
      expect(metrics.first.errorCode, ServiceErrorCode.INVALID_DATA);
    });

    test('tracks operation with exception', () async {
      final response = await metricsService.trackOperation(
        operation: 'exception_operation',
        action: () async => throw Exception('Test exception'),
      );

      expect(response.success, false);
      expect(response.errorCode, ServiceErrorCode.UNKNOWN_ERROR);

      final metrics =
          metricsService.getMetricsForOperation('exception_operation');
      expect(metrics.length, 1);
      expect(metrics.first.success, false);
      expect(metrics.first.errorCode, ServiceErrorCode.UNKNOWN_ERROR);
    });
  });

  group('MetricsService - Batch Operations', () {
    test('tracks batch operations', () async {
      final actions = List.generate(
        3,
        (i) => () async => ServiceResponse.success('data_$i'),
      );

      final responses = await metricsService.trackBatch(
        operation: 'batch_test',
        actions: actions,
      );

      expect(responses.length, 3);
      expect(responses.every((r) => r.success), true);

      final metrics = metricsService.getMetricsForOperation('batch_test_0');
      expect(metrics.length, 1);
      expect(metrics.first.attributes['batch_size'], 3);
    });
  });

  group('MetricsService - Analytics', () {
    test('calculates success rate', () async {
      // Successful operation
      await metricsService.trackOperation(
        operation: 'calc_test',
        action: () async => ServiceResponse.success('data'),
      );

      // Failed operation
      await metricsService.trackOperation(
        operation: 'calc_test',
        action: () async => ServiceResponse.error(
          ServiceErrorCode.INVALID_DATA,
          'error',
        ),
      );

      final successRate = metricsService.getSuccessRate('calc_test');
      expect(successRate, 0.5);
    });

    test('calculates average duration', () async {
      await metricsService.trackOperation(
        operation: 'duration_test',
        action: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          return ServiceResponse.success('data');
        },
      );

      final avgDuration = metricsService.getAverageDuration('duration_test');
      expect(avgDuration!.inMilliseconds, greaterThanOrEqualTo(100));
    });

    test('generates performance summary', () async {
      await metricsService.trackOperation(
        operation: 'summary_test',
        action: () async => ServiceResponse.success('data'),
      );

      final summary = metricsService.getPerformanceSummary();
      expect(summary['summary_test'], isNotNull);
      expect(summary['summary_test']['count'], 1);
      expect(summary['summary_test']['success_rate'], '1.00');
    });
  });

  group('MetricsService - Cleanup', () {
    test('cleans up old metrics', () async {
      // Create metrics service with very short retention period
      final shortRetentionService = MetricsService(
        retentionPeriod: const Duration(milliseconds: 100),
        cleanupInterval: const Duration(milliseconds: 50),
      );

      // Add a metric
      await shortRetentionService.trackOperation(
        operation: 'cleanup_test',
        action: () async => ServiceResponse.success('data'),
      );

      // Wait for retention period to expire
      await Future.delayed(const Duration(milliseconds: 150));

      // Force cleanup
      shortRetentionService.forceCleanup();

      final metrics =
          shortRetentionService.getMetricsForOperation('cleanup_test');
      expect(metrics.isEmpty, true);

      shortRetentionService.dispose();
    });
  });

  group('MetricsService - Event Listeners', () {
    test('notifies listeners of metrics events', () async {
      ServiceMetrics? capturedMetrics;
      metricsService.addListener((metrics) {
        capturedMetrics = metrics;
      });

      await metricsService.trackOperation(
        operation: 'listener_test',
        action: () async => ServiceResponse.success('data'),
      );

      expect(capturedMetrics, isNotNull);
      expect(capturedMetrics!.operation, 'listener_test');
      expect(capturedMetrics!.success, true);
    });
  });
}

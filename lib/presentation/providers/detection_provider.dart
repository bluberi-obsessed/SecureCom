import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sms_detection.dart';
import '../../data/models/call_detection.dart';
import '../../data/models/threat_stats.dart';
import '../../data/repositories/detection_repository.dart';
import '../../data/repositories/mock_detection_repository.dart';

// Repository provider - EASY TO SWITCH between mock and real API
final detectionRepositoryProvider = Provider<DetectionRepository>((ref) {
  return MockDetectionRepository();
  // return ApiDetectionRepository(ApiClient()); // Switch to real API later
});

// SMS detections provider
final smsDetectionsProvider = FutureProvider<List<SmsDetection>>((ref) async {
  final repository = ref.watch(detectionRepositoryProvider);
  return repository.getSmsDetections();
});

// Call detections provider
final callDetectionsProvider = FutureProvider<List<CallDetection>>((ref) async {
  final repository = ref.watch(detectionRepositoryProvider);
  return repository.getCallDetections();
});

// Stats provider
final statsProvider = FutureProvider<ThreatStats>((ref) async {
  final repository = ref.watch(detectionRepositoryProvider);
  return repository.getStats();
});

// Filtered SMS detections provider
final filteredSmsDetectionsProvider =
    Provider.family<List<SmsDetection>, String>((ref, filter) {
      final detections = ref.watch(smsDetectionsProvider);

      return detections.when(
        data: (list) {
          final now = DateTime.now();
          switch (filter) {
            case 'Today':
              return list
                  .where(
                    (d) =>
                        d.timestamp.year == now.year &&
                        d.timestamp.month == now.month &&
                        d.timestamp.day == now.day,
                  )
                  .toList();
            case 'Week':
              final weekAgo = now.subtract(const Duration(days: 7));
              return list.where((d) => d.timestamp.isAfter(weekAgo)).toList();
            case 'Month':
              final monthAgo = now.subtract(const Duration(days: 30));
              return list.where((d) => d.timestamp.isAfter(monthAgo)).toList();
            default: // 'All'
              return list;
          }
        },
        loading: () => [],
        error: (_, __) => [],
      );
    });

// Filtered call detections provider
final filteredCallDetectionsProvider =
    Provider.family<List<CallDetection>, String>((ref, filter) {
      final detections = ref.watch(callDetectionsProvider);

      return detections.when(
        data: (list) {
          final now = DateTime.now();
          switch (filter) {
            case 'Today':
              return list
                  .where(
                    (d) =>
                        d.timestamp.year == now.year &&
                        d.timestamp.month == now.month &&
                        d.timestamp.day == now.day,
                  )
                  .toList();
            case 'Week':
              final weekAgo = now.subtract(const Duration(days: 7));
              return list.where((d) => d.timestamp.isAfter(weekAgo)).toList();
            case 'Month':
              final monthAgo = now.subtract(const Duration(days: 30));
              return list.where((d) => d.timestamp.isAfter(monthAgo)).toList();
            default: // 'All'
              return list;
          }
        },
        loading: () => [],
        error: (_, __) => [],
      );
    });

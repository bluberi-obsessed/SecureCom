import 'detection_repository.dart';
import '../models/sms_detection.dart';
import '../models/call_detection.dart';
import '../models/threat_stats.dart';
import '../data_sources/mock/mock_api_service.dart';

class MockDetectionRepository implements DetectionRepository {
  final MockApiService _mockApi = MockApiService();

  @override
  Future<List<SmsDetection>> getSmsDetections({
    int? limit,
    DateTime? since,
  }) async {
    final allDetections = await _mockApi.getMockSmsDetections();

    var filtered = since != null
        ? allDetections.where((d) => d.timestamp.isAfter(since)).toList()
        : allDetections;

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && filtered.length > limit) {
      filtered = filtered.sublist(0, limit);
    }

    return filtered;
  }

  @override
  Future<List<CallDetection>> getCallDetections({
    int? limit,
    DateTime? since,
  }) async {
    final allDetections = await _mockApi.getMockCallDetections();

    var filtered = since != null
        ? allDetections.where((d) => d.timestamp.isAfter(since)).toList()
        : allDetections;

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && filtered.length > limit) {
      filtered = filtered.sublist(0, limit);
    }

    return filtered;
  }

  @override
  Future<ThreatStats> getStats() async {
    return await _mockApi.getMockStats();
  }

  @override
  Future<SmsDetection> analyzeSms(String sender, String message) async {
    return await _mockApi.analyzeSmsMessage(sender, message);
  }

  @override
  Future<void> reportFalsePositive(String detectionId, String type) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Reported false positive: detectionId($detectionId), type($type)');
  }

  @override
  Future<void> deleteDetection(String detectionId, String type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Deleted detection: detectionId($detectionId), type($type)');
  }
}

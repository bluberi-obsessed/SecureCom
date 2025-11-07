import '../models/sms_detection.dart';
import '../models/call_detection.dart';
import '../models/threat_stats.dart';

abstract class DetectionRepository {
  Future<List<SmsDetection>> getSmsDetections({int? limit, DateTime? since});
  Future<List<CallDetection>> getCallDetections({int? limit, DateTime? since});
  Future<ThreatStats> getStats();
  Future<SmsDetection> analyzeSms(String sender, String message);
  Future<void> reportFalsePositive(String detectionId, String type);
  Future<void> deleteDetection(String detectionId, String type);
}

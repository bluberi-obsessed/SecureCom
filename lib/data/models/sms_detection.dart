import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/threat_classification.dart';

part 'sms_detection.freezed.dart';
part 'sms_detection.g.dart';

@freezed
class SmsDetection with _$SmsDetection {
  const factory SmsDetection({
    required String id,
    required String sender,
    required String messagePreview,
    required String fullMessage,
    required ThreatClassification classification,
    required double confidence,
    required List<String> detectionReasons,
    required DateTime timestamp,
    String? senderName,
    @Default(false) bool isRead,
    @Default(false) bool userReported,
  }) = _SmsDetection;

  factory SmsDetection.fromJson(Map<String, dynamic> json) =>
      _$SmsDetectionFromJson(json);
}

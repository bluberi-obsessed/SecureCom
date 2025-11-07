import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/threat_classification.dart';

part 'call_detection.freezed.dart';
part 'call_detection.g.dart';

@freezed
class CallDetection with _$CallDetection {
  const factory CallDetection({
    required String id,
    required String callerNumber,
    required String transcriptPreview,
    String? fullTranscript,
    required ThreatClassification classification,
    required double confidence,
    required List<String> detectionReasons,
    required DateTime timestamp,
    required int duration,
    String? callerName,
    @Default(false) bool userReported,
  }) = _CallDetection;

  factory CallDetection.fromJson(Map<String, dynamic> json) =>
      _$CallDetectionFromJson(json);
}

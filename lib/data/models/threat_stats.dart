import 'package:freezed_annotation/freezed_annotation.dart';

part 'threat_stats.freezed.dart';
part 'threat_stats.g.dart';

@freezed
class ThreatStats with _$ThreatStats {
  const factory ThreatStats({
    required int totalThreatsBlocked,
    required int smsScamsBlocked,
    required int vishingAttemptsBlocked,
    required int todayThreats,
    required int weekThreats,
    required int monthThreats,
    required Map<String, int> threatsByDay,
    required DateTime lastUpdated,
  }) = _ThreatStats;

  factory ThreatStats.fromJson(Map<String, dynamic> json) =>
      _$ThreatStatsFromJson(json);
}

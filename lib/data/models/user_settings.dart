import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

enum SensitivityLevel {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case SensitivityLevel.low:
        return 'Low';
      case SensitivityLevel.medium:
        return 'Medium';
      case SensitivityLevel.high:
        return 'High';
    }
  }
}

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default(SensitivityLevel.medium) SensitivityLevel sensitivityLevel,
    @Default(true) bool protectionEnabled,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool cloudLearningEnabled,
    @Default([]) List<String> whitelistedNumbers,
    @Default(false) bool biometricEnabled,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

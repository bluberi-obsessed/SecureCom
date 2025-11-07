import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_settings.dart';

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(const UserSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final sensitivityIndex = prefs.getInt('sensitivityLevel') ?? 1;
      final sensitivity = SensitivityLevel.values[sensitivityIndex];

      state = UserSettings(
        sensitivityLevel: sensitivity,
        protectionEnabled: prefs.getBool('protectionEnabled') ?? true,
        notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
        cloudLearningEnabled: prefs.getBool('cloudLearningEnabled') ?? true,
        whitelistedNumbers: prefs.getStringList('whitelistedNumbers') ?? [],
        biometricEnabled: prefs.getBool('biometricEnabled') ?? false,
      );
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('sensitivityLevel', state.sensitivityLevel.index);
      await prefs.setBool('protectionEnabled', state.protectionEnabled);
      await prefs.setBool('notificationsEnabled', state.notificationsEnabled);
      await prefs.setBool('cloudLearningEnabled', state.cloudLearningEnabled);
      await prefs.setStringList('whitelistedNumbers', state.whitelistedNumbers);
      await prefs.setBool('biometricEnabled', state.biometricEnabled);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  void updateSensitivity(SensitivityLevel level) {
    state = state.copyWith(sensitivityLevel: level);
    _saveSettings();
  }

  void toggleProtection(bool enabled) {
    state = state.copyWith(protectionEnabled: enabled);
    _saveSettings();
  }

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    _saveSettings();
  }

  void toggleCloudLearning(bool enabled) {
    state = state.copyWith(cloudLearningEnabled: enabled);
    _saveSettings();
  }

  void addWhitelistedNumber(String number) {
    final updated = [...state.whitelistedNumbers, number];
    state = state.copyWith(whitelistedNumbers: updated);
    _saveSettings();
  }

  void removeWhitelistedNumber(String number) {
    final updated = state.whitelistedNumbers.where((n) => n != number).toList();
    state = state.copyWith(whitelistedNumbers: updated);
    _saveSettings();
  }

  void toggleBiometric(bool enabled) {
    state = state.copyWith(biometricEnabled: enabled);
    _saveSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((
  ref,
) {
  return SettingsNotifier();
});

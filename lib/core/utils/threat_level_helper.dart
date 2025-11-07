import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

enum ThreatLevel {
  allClear,
  caution,
  highAlert;

  String get label {
    switch (this) {
      case ThreatLevel.allClear:
        return AppStrings.allClear;
      case ThreatLevel.caution:
        return AppStrings.caution;
      case ThreatLevel.highAlert:
        return AppStrings.highAlert;
    }
  }

  Color get color {
    switch (this) {
      case ThreatLevel.allClear:
        return AppColors.safe;
      case ThreatLevel.caution:
        return AppColors.suspicious;
      case ThreatLevel.highAlert:
        return AppColors.danger;
    }
  }

  IconData get icon {
    switch (this) {
      case ThreatLevel.allClear:
        return Icons.shield_outlined;
      case ThreatLevel.caution:
        return Icons.warning_amber_outlined;
      case ThreatLevel.highAlert:
        return Icons.dangerous_outlined;
    }
  }
}

class ThreatLevelHelper {
  static ThreatLevel calculateThreatLevel({
    required int todayThreats,
    required int confirmedScams,
  }) {
    if (confirmedScams > 3 || todayThreats > 5) {
      return ThreatLevel.highAlert;
    } else if (confirmedScams > 0 || todayThreats > 2) {
      return ThreatLevel.caution;
    } else {
      return ThreatLevel.allClear;
    }
  }
}

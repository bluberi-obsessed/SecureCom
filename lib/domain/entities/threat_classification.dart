import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

enum ThreatClassification {
  legitimate,
  suspicious,
  confirmedScam;

  Color get color {
    switch (this) {
      case ThreatClassification.legitimate:
        return AppColors.safe;
      case ThreatClassification.suspicious:
        return AppColors.suspicious;
      case ThreatClassification.confirmedScam:
        return AppColors.danger;
    }
  }

  String get label {
    switch (this) {
      case ThreatClassification.legitimate:
        return AppStrings.legitimate;
      case ThreatClassification.suspicious:
        return AppStrings.suspicious;
      case ThreatClassification.confirmedScam:
        return AppStrings.confirmedScam;
    }
  }

  IconData get icon {
    switch (this) {
      case ThreatClassification.legitimate:
        return Icons.check_circle;
      case ThreatClassification.suspicious:
        return Icons.warning;
      case ThreatClassification.confirmedScam:
        return Icons.dangerous;
    }
  }
}

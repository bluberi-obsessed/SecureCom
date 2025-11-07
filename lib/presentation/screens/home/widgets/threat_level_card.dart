import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/threat_level_helper.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/threat_stats.dart';

class ThreatLevelCard extends StatelessWidget {
  final ThreatStats stats;

  const ThreatLevelCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final threatLevel = ThreatLevelHelper.calculateThreatLevel(
      todayThreats: stats.todayThreats,
      confirmedScams: stats.smsScamsBlocked + stats.vishingAttemptsBlocked,
    );

    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: _getGradient(threatLevel),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(threatLevel.icon, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              threatLevel.label,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusMessage(threatLevel, stats.todayThreats),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withAlpha(230),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Last scan: ${DateFormatter.formatTimeAgo(stats.lastUpdated)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradient(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.allClear:
        return AppColors.safeGradient;
      case ThreatLevel.caution:
        return AppColors.suspiciousGradient;
      case ThreatLevel.highAlert:
        return AppColors.dangerGradient;
    }
  }

  String _getStatusMessage(ThreatLevel level, int todayThreats) {
    switch (level) {
      case ThreatLevel.allClear:
        return 'Your device is protected. No threats detected today.';
      case ThreatLevel.caution:
        return '$todayThreats threat${todayThreats > 1 ? 's' : ''} detected today. Stay vigilant.';
      case ThreatLevel.highAlert:
        return '$todayThreats threats detected today! Review blocked messages.';
    }
  }
}

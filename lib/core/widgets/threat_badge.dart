import 'package:flutter/material.dart';
import '../../domain/entities/threat_classification.dart';

class ThreatBadge extends StatelessWidget {
  final ThreatClassification classification;
  final bool showIcon;
  final double fontSize;

  const ThreatBadge({
    super.key,
    required this.classification,
    this.showIcon = true,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: classification.color.withAlpha(
          25,
        ), // Fixed: Use withAlpha instead of withOpacity
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: classification.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              classification.icon,
              size: fontSize + 2,
              color: classification.color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            classification.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: classification.color,
            ),
          ),
        ],
      ),
    );
  }
}

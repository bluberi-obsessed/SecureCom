import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/threat_badge.dart';
import '../../../../data/models/sms_detection.dart';

class RecentThreatsList extends StatelessWidget {
  final List<SmsDetection> detections;

  const RecentThreatsList({super.key, required this.detections});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: detections.map((detection) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: detection.classification.color.withAlpha(50),
              child: Icon(
                detection.classification.icon,
                color: detection.classification.color,
              ),
            ),
            title: Text(
              detection.sender,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  detection.messagePreview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ThreatBadge(
                      classification: detection.classification,
                      fontSize: 10,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormatter.formatTimeAgo(detection.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            isThreeLine: true,
            onTap: () {
              _showDetailDialog(context, detection);
            },
          ),
        );
      }).toList(),
    );
  }

  void _showDetailDialog(BuildContext context, SmsDetection detection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            ThreatBadge(classification: detection.classification),
            const SizedBox(width: 8),
            const Expanded(child: Text('Threat Details')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(label: 'Sender', value: detection.sender),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Confidence',
                value: '${(detection.confidence * 100).toStringAsFixed(1)}%',
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Time',
                value: DateFormatter.formatDateTime(detection.timestamp),
              ),
              const SizedBox(height: 16),
              const Text(
                'Message:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(detection.fullMessage),
              const SizedBox(height: 16),
              const Text(
                'Detection Reasons:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...detection.detectionReasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(reason)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

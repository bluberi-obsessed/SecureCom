import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../providers/detection_provider.dart';
import 'widgets/detection_list_item.dart';
import 'widgets/call_detection_list_item.dart';

class DetectionHistoryScreen extends ConsumerStatefulWidget {
  const DetectionHistoryScreen({super.key});

  @override
  ConsumerState<DetectionHistoryScreen> createState() =>
      _DetectionHistoryScreenState();
}

class _DetectionHistoryScreenState extends ConsumerState<DetectionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.detectionHistory),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.message), text: AppStrings.smsTab),
            Tab(icon: Icon(Icons.phone), text: AppStrings.callsTab),
          ],
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: ['Today', 'Week', 'Month', 'All'].map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildSmsTab(), _buildCallsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmsTab() {
    final detections = ref.watch(
      filteredSmsDetectionsProvider(_selectedFilter),
    );

    if (detections.isEmpty) {
      return EmptyState(
        icon: Icons.check_circle,
        title: AppStrings.noThreatsTitle,
        subtitle: AppStrings.noThreatsSubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(smsDetectionsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: detections.length,
        itemBuilder: (context, index) {
          final detection = detections[index];
          return Dismissible(
            key: Key(detection.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Detection'),
                  content: const Text(
                    'Are you sure you want to delete this detection?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              ref
                  .read(detectionRepositoryProvider)
                  .deleteDetection(detection.id, 'sms');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Detection deleted')),
              );
            },
            child: DetectionListItem(
              detection: detection,
              onTap: () {
                _showSmsDetailDialog(context, detection);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCallsTab() {
    final detections = ref.watch(
      filteredCallDetectionsProvider(_selectedFilter),
    );

    if (detections.isEmpty) {
      return EmptyState(
        icon: Icons.phone_disabled,
        title: AppStrings.noCallsTitle,
        subtitle: AppStrings.noCallsSubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(callDetectionsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: detections.length,
        itemBuilder: (context, index) {
          final detection = detections[index];
          return Dismissible(
            key: Key(detection.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Detection'),
                  content: const Text(
                    'Are you sure you want to delete this detection?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              ref
                  .read(detectionRepositoryProvider)
                  .deleteDetection(detection.id, 'call');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Detection deleted')),
              );
            },
            child: CallDetectionListItem(
              detection: detection,
              onTap: () {
                _showCallDetailDialog(context, detection);
              },
            ),
          );
        },
      ),
    );
  }

  void _showSmsDetailDialog(BuildContext context, detection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SMS Threat Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Sender', detection.sender),
              _buildDetailRow('Classification', detection.classification.label),
              _buildDetailRow(
                'Confidence',
                '${(detection.confidence * 100).toStringAsFixed(1)}%',
              ),
              _buildDetailRow('Time', detection.timestamp.toString()),
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
            onPressed: () {
              ref
                  .read(detectionRepositoryProvider)
                  .reportFalsePositive(detection.id, 'sms');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reported as false positive')),
              );
            },
            child: const Text('Report Wrong'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCallDetailDialog(BuildContext context, detection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Threat Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Caller', detection.callerNumber),
              _buildDetailRow('Classification', detection.classification.label),
              _buildDetailRow(
                'Confidence',
                '${(detection.confidence * 100).toStringAsFixed(1)}%',
              ),
              _buildDetailRow('Duration', '${detection.duration}s'),
              _buildDetailRow('Time', detection.timestamp.toString()),
              const SizedBox(height: 16),
              const Text(
                'Transcript:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(detection.fullTranscript ?? detection.transcriptPreview),
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
            onPressed: () {
              ref
                  .read(detectionRepositoryProvider)
                  .reportFalsePositive(detection.id, 'call');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reported as false positive')),
              );
            },
            child: const Text('Report Wrong'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
      ),
    );
  }
}

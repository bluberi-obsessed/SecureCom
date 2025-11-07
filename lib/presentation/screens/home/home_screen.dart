import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';
import '../../providers/detection_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/threat_level_card.dart';
import 'widgets/stats_overview.dart';
import 'widgets/weekly_activity_chart.dart';
import 'widgets/recent_threats_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.detectionHistory);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsProvider);
    final smsDetectionsAsync = ref.watch(smsDetectionsProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.shield,
              color: settings.protectionEnabled ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            const Text(AppStrings.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statsProvider);
          ref.invalidate(smsDetectionsProvider);
          ref.invalidate(callDetectionsProvider);
        },
        child: statsAsync.when(
          data: (stats) => _buildDashboard(context, stats, smsDetectionsAsync),
          loading: () =>
              const LoadingIndicator(message: AppStrings.loadingData),
          error: (error, stack) => ErrorView(
            error: error.toString(),
            onRetry: () {
              ref.invalidate(statsProvider);
            },
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: AppStrings.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: AppStrings.navHistory,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: AppStrings.navSettings,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showManualReportDialog(context);
        },
        icon: const Icon(Icons.report),
        label: const Text('Report Threat'),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    stats,
    smsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThreatLevelCard(stats: stats),
          const SizedBox(height: 16),
          StatsOverview(stats: stats),
          const SizedBox(height: 24),
          Text(
            AppStrings.weeklyActivity,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          WeeklyActivityChart(data: stats.threatsByDay),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.recentThreats,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.detectionHistory);
                },
                child: const Text(AppStrings.viewAll),
              ),
            ],
          ),
          const SizedBox(height: 12),
          smsAsync.when(
            data: (detections) {
              if (detections.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('No recent threats detected'),
                    ),
                  ),
                );
              }
              return RecentThreatsList(
                detections: detections.take(5).toList(),
              );
            },
            loading: () => const LoadingIndicator(),
            error: (e, s) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  void _showManualReportDialog(BuildContext context) {
    final senderController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report Suspicious Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: senderController,
              decoration: const InputDecoration(
                labelText: 'Sender Number',
                hintText: '+639171234567',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Enter the suspicious message...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (senderController.text.isNotEmpty &&
                  messageController.text.isNotEmpty) {
                Navigator.pop(dialogContext);

                final repository = ref.read(detectionRepositoryProvider);
                final result = await repository.analyzeSms(
                  senderController.text,
                  messageController.text,
                );

                ref.invalidate(smsDetectionsProvider);
                ref.invalidate(statsProvider);

                // Use dialogContext or check mounted
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Detection complete: ${result.classification.label}',
                    ),
                    backgroundColor: result.classification.color,
                  ),
                );
              }
            },
            child: const Text('Analyze'),
          ),
        ],
      ),
    );
  }
}

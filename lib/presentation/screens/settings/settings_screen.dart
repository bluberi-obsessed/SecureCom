import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/user_settings.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Protection Settings Section
          _buildSectionHeader(context, AppStrings.protectionSettings),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(AppStrings.enableProtection),
                  subtitle: const Text('Real-time SMS and call scanning'),
                  value: settings.protectionEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleProtection(value);
                  },
                  secondary: Icon(
                    Icons.shield,
                    color:
                        settings.protectionEnabled ? Colors.green : Colors.grey,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text(AppStrings.sensitivityLevel),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        settings.sensitivityLevel.label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _SensitivityButton(
                              label: AppStrings.sensitivityLow,
                              isSelected: settings.sensitivityLevel ==
                                  SensitivityLevel.low,
                              onTap: () {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateSensitivity(SensitivityLevel.low);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SensitivityButton(
                              label: AppStrings.sensitivityMedium,
                              isSelected: settings.sensitivityLevel ==
                                  SensitivityLevel.medium,
                              onTap: () {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateSensitivity(SensitivityLevel.medium);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SensitivityButton(
                              label: AppStrings.sensitivityHigh,
                              isSelected: settings.sensitivityLevel ==
                                  SensitivityLevel.high,
                              onTap: () {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateSensitivity(SensitivityLevel.high);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader(context, AppStrings.notifications),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Get alerts for detected threats'),
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .toggleNotifications(value);
                  },
                  secondary: const Icon(Icons.notifications),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Privacy Section
          _buildSectionHeader(context, AppStrings.privacy),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(AppStrings.cloudLearning),
                  subtitle: const Text(
                    'Share anonymized threat data to improve detection',
                  ),
                  value: settings.cloudLearningEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .toggleCloudLearning(value);
                  },
                  secondary: const Icon(Icons.cloud),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showPrivacyDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Whitelist Section
          _buildSectionHeader(context, AppStrings.whitelistManagement),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Manage Whitelisted Numbers'),
              subtitle: Text('${settings.whitelistedNumbers.length} numbers'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showWhitelistDialog(context, settings);
              },
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, AppStrings.about),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showHelpDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star_outline),
                  title: const Text('Rate App'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your interest!'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Report a Bug'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showBugReportDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SecureCom Privacy Policy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Data Collection:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• We analyze SMS and call metadata to detect threats\n'
                '• Message content is processed locally on your device\n'
                '• Only anonymized threat patterns are sent to our servers',
              ),
              SizedBox(height: 16),
              Text(
                'Data Usage:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Improve threat detection algorithms\n'
                '• Train AI models with anonymized data\n'
                '• Share threat intelligence across users',
              ),
              SizedBox(height: 16),
              Text(
                'Your Rights:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Opt out of cloud learning anytime\n'
                '• Delete your data on request\n'
                '• Access your detection history',
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

  void _showWhitelistDialog(BuildContext context, UserSettings settings) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Whitelisted Numbers'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Add Number',
                  hintText: '+639171234567',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        ref
                            .read(settingsProvider.notifier)
                            .addWhitelistedNumber(controller.text);
                        controller.clear();
                      }
                    },
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              if (settings.whitelistedNumbers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No whitelisted numbers'),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: settings.whitelistedNumbers.length,
                    itemBuilder: (context, index) {
                      final number = settings.whitelistedNumbers[index];
                      return ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(number),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ref
                                .read(settingsProvider.notifier)
                                .removeWhitelistedNumber(number);
                          },
                        ),
                      );
                    },
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to Use SecureCom:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '1. Enable Protection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Turn on real-time scanning in Settings'),
              SizedBox(height: 12),
              Text(
                '2. Review Detections',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Check your detection history regularly'),
              SizedBox(height: 12),
              Text(
                '3. Report False Positives',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Help improve accuracy by reporting errors'),
              SizedBox(height: 12),
              Text(
                '4. Whitelist Contacts',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Add trusted numbers to prevent false alarms'),
              SizedBox(height: 16),
              Text(
                'Need more help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Email: support@securecom.app'),
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

  void _showBugReportDialog(BuildContext context) {
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe the issue you encountered:'),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Describe the bug...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report submitted. Thank you!'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _SensitivityButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SensitivityButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

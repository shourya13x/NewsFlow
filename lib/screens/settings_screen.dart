import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('News Explorer v1.0.0'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'News Explorer',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.newspaper_rounded),
                  children: const [
                    Text('Your daily dose of news and information.'),
                    SizedBox(height: 8),
                    Text('Stay informed, effortlessly.'),
                    SizedBox(height: 8),
                    Text('Built with Flutter and multiple news APIs.'),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Report Bug'),
              subtitle: const Text('Help us improve the app'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bug reporting feature coming soon!'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback'),
              subtitle: const Text('Share your thoughts'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feedback feature coming soon!'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              subtitle: const Text('How we handle your data'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy policy coming soon!')),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms of Service'),
              subtitle: const Text('App usage terms'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terms of service coming soon!'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

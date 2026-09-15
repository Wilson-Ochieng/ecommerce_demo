import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/ThemeProvider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 30),
        children: [
          // =========================================================
          // APPEARANCE
          // =========================================================

          _sectionTitle(context, 'Appearance'),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),

                      leading: _iconContainer(
                        context,
                        themeProvider.getIsDarkTHeme
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                      ),

                      title: const Text(
                        'Dark Mode',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      subtitle: Text(
                        themeProvider.getIsDarkTHeme
                            ? 'Dark theme enabled'
                            : 'Light theme enabled',
                      ),

                      trailing: Switch(
                        value: themeProvider.getIsDarkTHeme,
                        onChanged: (value) {
                          themeProvider.setDarkTheme(value);
                        },
                      ),
                    ),

                    const Divider(height: 1),

                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),

                      leading: _iconContainer(context, Icons.language_outlined),

                      title: const Text(
                        'Language',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      subtitle: const Text('English'),

                      trailing: const Icon(Icons.chevron_right),

                      onTap: () {
                        _showLanguageDialog(context);
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // =========================================================
          // NOTIFICATIONS
          // =========================================================
          _sectionTitle(context, 'Notifications'),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _switchTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive app notifications',
                  value: true,
                  onChanged: (value) {
                    // TODO:
                    // Save notification preference.
                  },
                ),

                const Divider(height: 1),

                _switchTile(
                  context,
                  icon: Icons.local_shipping_outlined,
                  title: 'Order Updates',
                  subtitle: 'Get updates about your orders',
                  value: true,
                  onChanged: (value) {
                    // TODO:
                    // Save order notification preference.
                  },
                ),

                const Divider(height: 1),

                _switchTile(
                  context,
                  icon: Icons.local_offer_outlined,
                  title: 'Promotions',
                  subtitle: 'Receive offers and promotions',
                  value: false,
                  onChanged: (value) {
                    // TODO:
                    // Save promotion preference.
                  },
                ),
              ],
            ),
          ),

          // =========================================================
          // ACCOUNT
          // =========================================================
          _sectionTitle(context, 'Account'),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _menuTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  subtitle: 'Manage your profile information',
                  onTap: () {
                    // TODO:
                    // Navigate to EditProfileScreen.
                  },
                ),

                const Divider(height: 1),

                _menuTile(
                  context,
                  icon: Icons.phone_outlined,
                  title: 'Phone Number',
                  subtitle: 'Manage your phone number',
                  onTap: () {
                    // TODO:
                    // Navigate to phone settings.
                  },
                ),

                const Divider(height: 1),

                _menuTile(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email Address',
                  subtitle: 'Manage your email address',
                  onTap: () {
                    // TODO:
                    // Navigate to email settings.
                  },
                ),
              ],
            ),
          ),

          // =========================================================
          // SECURITY
          // =========================================================
          _sectionTitle(context, 'Security'),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _menuTile(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () {
                    // TODO:
                    // Navigate to ChangePasswordScreen.
                  },
                ),

                const Divider(height: 1),

                _menuTile(
                  context,
                  icon: Icons.verified_user_outlined,
                  title: 'Account Verification',
                  subtitle: 'Manage email and phone verification',
                  onTap: () {
                    // TODO:
                    // Navigate to verification screen.
                  },
                ),
              ],
            ),
          ),

          // =========================================================
          // SUPPORT
          // =========================================================
          _sectionTitle(context, 'Support'),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _menuTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help with the application',
                  onTap: () {
                    // TODO:
                    // Open support screen.
                  },
                ),

                const Divider(height: 1),

                _menuTile(
                  context,
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Tell us what you think',
                  onTap: () {
                    // TODO:
                    // Open feedback screen.
                  },
                ),
              ],
            ),
          ),

          // =========================================================
          // LEGAL
          // =========================================================
          _sectionTitle(context, 'Legal'),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _menuTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    // TODO:
                    // Open Privacy Policy.
                  },
                ),

                const Divider(height: 1),

                _menuTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {
                    // TODO:
                    // Open Terms & Conditions.
                  },
                ),
              ],
            ),
          ),

          // =========================================================
          // ABOUT
          // =========================================================
          _sectionTitle(context, 'About'),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _menuTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About App',
                  subtitle: 'Version 1.0.0',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),

          // =========================================================
          // LOGOUT
          // =========================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 10),
            child: OutlinedButton.icon(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===============================================================
  // ICON CONTAINER
  // ===============================================================

  Widget _iconContainer(BuildContext context, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: theme.colorScheme.primary),
    );
  }

  // ===============================================================
  // MENU TILE
  // ===============================================================

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      leading: _iconContainer(context, icon),

      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

      subtitle: subtitle != null ? Text(subtitle) : null,

      trailing: const Icon(Icons.chevron_right),

      onTap: onTap,
    );
  }

  // ===============================================================
  // SWITCH TILE
  // ===============================================================

  Widget _switchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      leading: _iconContainer(context, icon),

      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

      subtitle: Text(subtitle),

      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  // ===============================================================
  // LANGUAGE DIALOG
  // ===============================================================

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'English',
                groupValue: 'English',
                title: const Text('English'),
                onChanged: (_) {
                  Navigator.pop(context);
                },
              ),

              RadioListTile<String>(
                value: 'Swahili',
                groupValue: 'English',
                title: const Text('Kiswahili'),
                onChanged: (_) {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ===============================================================
  // ABOUT DIALOG
  // ===============================================================

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Test App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Test App',
    );
  }

  // ===============================================================
  // LOGOUT DIALOG
  // ===============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),

          content: const Text('Are you sure you want to logout?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                // TODO:
                // Call AuthRepository.logout()
                // Clear UserProvider
                // Navigate to LoginScreen.
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

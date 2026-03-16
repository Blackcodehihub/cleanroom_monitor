import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  bool enableAlerts = true;
  bool criticalOnly = false;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool emailAlerts = false;
  bool deviceOfflineAlerts = true;

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          _infoCard(),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'General Alerts',
            subtitle: 'Control how the app sends monitoring notifications',
            children: [
              _switchTile(
                title: 'Enable Alerts',
                subtitle: 'Turn all alert notifications on or off',
                value: enableAlerts,
                onChanged: (value) {
                  setState(() {
                    enableAlerts = value;
                  });
                },
              ),
              _divider(),
              _switchTile(
                title: 'Critical Alerts Only',
                subtitle: 'Receive only warning and critical events',
                value: criticalOnly,
                onChanged: enableAlerts
                    ? (value) {
                        setState(() {
                          criticalOnly = value;
                        });
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: 'Alert Behavior',
            subtitle: 'Choose how alerts should behave on this device',
            children: [
              _switchTile(
                title: 'Sound',
                subtitle: 'Play a sound when an alert is received',
                value: soundEnabled,
                onChanged: enableAlerts
                    ? (value) {
                        setState(() {
                          soundEnabled = value;
                        });
                      }
                    : null,
              ),
              _divider(),
              _switchTile(
                title: 'Vibration',
                subtitle: 'Vibrate the phone for important alerts',
                value: vibrationEnabled,
                onChanged: enableAlerts
                    ? (value) {
                        setState(() {
                          vibrationEnabled = value;
                        });
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: 'Special Alerts',
            subtitle: 'Select which system events should notify the user',
            children: [
              _switchTile(
                title: 'Device Offline Alerts',
                subtitle: 'Notify when the monitoring device disconnects',
                value: deviceOfflineAlerts,
                onChanged: enableAlerts
                    ? (value) {
                        setState(() {
                          deviceOfflineAlerts = value;
                        });
                      }
                    : null,
              ),
              _divider(),
              _switchTile(
                title: 'Email Alerts',
                subtitle: 'Send alerts by email later when backend is added',
                value: emailAlerts,
                onChanged: enableAlerts
                    ? (value) {
                        setState(() {
                          emailAlerts = value;
                        });
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save_rounded),
              label: const Text(
                'Save Notification Settings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.notifications_active_rounded, color: primaryGreen),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Preferences',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'These controls define how the app should notify users about cleanroom conditions and system activity.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final disabled = onChanged == null;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        color: Colors.black.withValues(alpha: 0.08),
      ),
    );
  }
}
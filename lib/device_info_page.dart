import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';

class DeviceInformationPage extends StatelessWidget {
  const DeviceInformationPage({super.key});

  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final reading = service.currentReading;

        return Scaffold(
          backgroundColor: softBg,
          appBar: AppBar(
            title: const Text(
              'Device Information',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              _infoCard(reading.online),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Main Device',
                subtitle: 'Primary cleanroom monitoring controller',
                children: [
                  _infoRow('Device Name', 'Cleanroom Main Device'),
                  _divider(),
                  _infoRow('Device ID', 'ESP32-CR-A1'),
                  _divider(),
                  _infoRow(
                    'Connection Status',
                    reading.online ? 'Online' : 'Offline',
                    valueColor: reading.online ? primaryGreen : Colors.red,
                  ),
                  _divider(),
                  _infoRow('Last Sync', service.formatTime(reading.timestamp)),
                  _divider(),
                  _infoRow('Firmware Version', 'v1.0.0 Prototype'),
                ],
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'Installed Sensors',
                subtitle: 'Sensors currently used by the monitoring prototype',
                children: const [
                  _SensorRow(
                    icon: Icons.air_rounded,
                    title: 'PM2.5 Sensor',
                    subtitle: 'Particle concentration monitoring',
                    badge: 'Active',
                  ),
                  _SensorDivider(),
                  _SensorRow(
                    icon: Icons.thermostat_rounded,
                    title: 'Temperature Sensor',
                    subtitle: 'Cleanroom thermal condition monitoring',
                    badge: 'Active',
                  ),
                  _SensorDivider(),
                  _SensorRow(
                    icon: Icons.water_drop_rounded,
                    title: 'Humidity Sensor',
                    subtitle: 'Relative humidity monitoring',
                    badge: 'Active',
                  ),
                  _SensorDivider(),
                  _SensorRow(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Luminance Sensor',
                    subtitle: 'Light intensity monitoring',
                    badge: 'Active',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'Current Live Values',
                subtitle: 'Latest values reported by the connected device',
                children: [
                  _infoRow('PM2.5', '${reading.pm25.toStringAsFixed(1)} µg/m³'),
                  _divider(),
                  _infoRow(
                    'Temperature',
                    '${reading.temperature.toStringAsFixed(1)}°C',
                  ),
                  _divider(),
                  _infoRow(
                    'Humidity',
                    '${reading.humidity.toStringAsFixed(1)}%',
                  ),
                  _divider(),
                  _infoRow(
                    'Luminance',
                    '${reading.luminance.toStringAsFixed(0)} lux',
                  ),
                  _divider(),
                  _infoRow(
                    'System Status',
                    reading.status,
                    valueColor: service.statusColor(reading.status),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'Network & System',
                subtitle: 'Basic environment and deployment details',
                children: [
                  _infoRow('Wi-Fi Status', reading.online ? 'Connected' : 'Disconnected'),
                  _divider(),
                  _infoRow('Monitoring Mode', 'Prototype / Mock Data'),
                  _divider(),
                  _infoRow('Backend Integration', 'Pending'),
                  _divider(),
                  _infoRow('Cloud Sync', 'Not yet connected'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard(bool online) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(
              online ? Icons.memory_rounded : Icons.portable_wifi_off,
              color: online ? primaryGreen : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              online
                  ? 'The cleanroom monitoring device is currently online and transmitting live data.'
                  : 'The monitoring device is currently offline. Live sensor updates may be delayed.',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.4,
              ),
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

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
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

class _SensorRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;

  const _SensorRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFEAF6EC),
          child: Icon(icon, color: DeviceInformationPage.primaryGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
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
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF6EC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              color: DeviceInformationPage.primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SensorDivider extends StatelessWidget {
  const _SensorDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        color: Colors.black12,
      ),
    );
  }
}
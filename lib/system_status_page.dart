import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';

class SystemStatusPage extends StatelessWidget {
  const SystemStatusPage({super.key});

  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final reading = service.currentReading;
        final statusColor = service.statusColor(reading.status);

        return Scaffold(
          backgroundColor: softBg,
          appBar: AppBar(
            title: const Text(
              'System Status',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              _heroCard(reading.status, statusColor, reading.online),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Monitoring State',
                subtitle: 'Current overall operating condition',
                children: [
                  _infoRow(
                    'Cleanroom Status',
                    reading.status,
                    valueColor: statusColor,
                  ),
                  _divider(),
                  _infoRow(
                    'Device Connectivity',
                    reading.online ? 'Online' : 'Offline',
                    valueColor: reading.online ? primaryGreen : Colors.red,
                  ),
                  _divider(),
                  _infoRow('Monitoring Mode', 'Prototype / Mock Live Data'),
                  _divider(),
                  _infoRow('Last Update', service.formatTime(reading.timestamp)),
                ],
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'Lighting Control State',
                subtitle: 'Luminance schedule and override information',
                children: [
                  _infoRow('Override Mode', service.overrideModeText),
                  _divider(),
                  _infoRow('Current Light Status', service.lightStatusText),
                  _divider(),
                  _infoRow(
                    'Schedule',
                    '${service.thresholds.lightOnMinutes} min ON / ${service.thresholds.lightOffMinutes} min OFF',
                  ),
                  _divider(),
                  _infoRow(
                    'Remaining Cycle Time',
                    service.thresholds.overrideMode == LightOverrideMode.auto
                        ? '${service.minutesRemainingInLightCycle} min'
                        : '--',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'Backend & Services',
                subtitle: 'Current software integration state',
                children: const [
                  _StaticInfoRow('Authentication', 'UI only'),
                  _SectionDivider(),
                  _StaticInfoRow('Cloud Database', 'Not connected'),
                  _SectionDivider(),
                  _StaticInfoRow('Push Notifications', 'Prototype only'),
                  _SectionDivider(),
                  _StaticInfoRow('Firebase Integration', 'Pending'),
                ],
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'Application Health',
                subtitle: 'Prototype environment details',
                children: const [
                  _StaticInfoRow('App Version', 'v1.0.0'),
                  _SectionDivider(),
                  _StaticInfoRow('Build Type', 'Prototype'),
                  _SectionDivider(),
                  _StaticInfoRow('Sensor Simulation', 'Active'),
                  _SectionDivider(),
                  _StaticInfoRow('Status Engine', 'Running'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _heroCard(String status, Color statusColor, bool online) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: statusColor.withOpacity(0.12),
            child: Icon(
              online ? Icons.verified_user_outlined : Icons.portable_wifi_off,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Overview',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  online
                      ? 'The monitoring system is active and reporting data.'
                      : 'The monitoring device is offline at the moment.',
                  style: const TextStyle(
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
        color: Colors.black.withOpacity(0.08),
      ),
    );
  }
}

class _StaticInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _StaticInfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
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
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

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
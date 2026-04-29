import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';
import 'notifications_page.dart';
import 'profile_service.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final alerts = service.alerts;
        final warningCount = alerts.where((a) => a.isWarning).length;
        final stableCount = alerts.where((a) => !a.isWarning).length;

        return Scaffold(
          backgroundColor: softBg,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: _topHeader(context, alerts.length),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _summarySection(
                    warningCount: warningCount,
                    stableCount: stableCount,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: alerts.isEmpty
                      ? const Center(
                          child: Text(
                            'No alerts available.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _alertCard(service, alert),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topHeader(BuildContext context, int alertCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Alerts',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsPage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: primaryGreen,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Monitor warnings and system updates',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '$alertCount alerts',
            style: const TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summarySection({
    required int warningCount,
    required int stableCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _summaryChip(
            title: 'Warnings',
            value: warningCount.toString(),
            color: Colors.orange,
            icon: Icons.warning_amber_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryChip(
            title: 'Stable',
            value: stableCount.toString(),
            color: primaryGreen,
            icon: Icons.check_circle_rounded,
          ),
        ),
      ],
    );
  }

  Widget _summaryChip({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.16),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertCard(MockSensorService service, AlertItem alert) {
    final color = alert.isWarning ? Colors.orange : primaryGreen;
    final receiverNumber = ProfileService.instance.contactNumber;

    return Container(
      padding: const EdgeInsets.all(15),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              alert.isWarning
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        alert.isWarning ? 'Warning' : 'Stable',
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alert.message,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                if (alert.isWarning) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sms_outlined,
                          size: 15,
                          color: primaryGreen,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Sent to: $receiverNumber',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: Colors.black38,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      service.formatTime(alert.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
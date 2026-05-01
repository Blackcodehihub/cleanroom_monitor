import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';
import 'profile_service.dart';

enum AlertFilter {
  all,
  warning,
  stable,
}

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  AlertFilter selectedFilter = AlertFilter.all;

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final allAlerts = service.alerts;
        final warningCount = allAlerts.where((a) => a.isWarning).length;
        final stableCount = allAlerts.where((a) => !a.isWarning).length;

        final alerts = switch (selectedFilter) {
          AlertFilter.warning => allAlerts.where((a) => a.isWarning).toList(),
          AlertFilter.stable => allAlerts.where((a) => !a.isWarning).toList(),
          AlertFilter.all => allAlerts,
        };

        return Scaffold(
          backgroundColor: softBg,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: _topHeader(context, allAlerts.length),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _summarySection(
                    warningCount: warningCount,
                    stableCount: stableCount,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: alerts.isEmpty
                      ? Center(
                          child: Text(
                            selectedFilter == AlertFilter.warning
                                ? 'No warning alerts available.'
                                : selectedFilter == AlertFilter.stable
                                    ? 'No stable alerts available.'
                                    : 'No alerts available.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 6, 18, 96),
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

  Widget _topHeader(BuildContext context, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Monitor warnings and system updates',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = AlertFilter.all;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selectedFilter == AlertFilter.all
                    ? const Color(0xFFEAF6EC)
                    : const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$count alerts',
                style: const TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
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
            selected: selectedFilter == AlertFilter.warning,
            onTap: () {
              setState(() {
                selectedFilter = AlertFilter.warning;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryChip(
            title: 'Stable',
            value: stableCount.toString(),
            color: primaryGreen,
            icon: Icons.check_circle_rounded,
            selected: selectedFilter == AlertFilter.stable,
            onTap: () {
              setState(() {
                selectedFilter = AlertFilter.stable;
              });
            },
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
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.18)
              : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(
                  color: color.withValues(alpha: 0.45),
                  width: 1.2,
                )
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.16),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
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
          ],
        ),
      ),
    );
  }

  Widget _alertCard(MockSensorService service, AlertItem alert) {
    final color = alert.isWarning ? Colors.orange : primaryGreen;
    final receiver = ProfileService.instance.contactNumber;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              alert.isWarning
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
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
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
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
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                if (alert.isWarning) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sms_outlined,
                          size: 16,
                          color: primaryGreen,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sent to: $receiver',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: Colors.black38,
                    ),
                    const SizedBox(width: 6),
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
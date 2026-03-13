import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 390;

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
                  padding: EdgeInsets.fromLTRB(
                    isSmallScreen ? 16 : 18,
                    12,
                    isSmallScreen ? 16 : 18,
                    0,
                  ),
                  child: _topHeader(
                    alertCount: alerts.length,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 18,
                  ),
                  child: _summarySection(
                    warningCount: warningCount,
                    stableCount: stableCount,
                    isSmallScreen: isSmallScreen,
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
                          padding: EdgeInsets.fromLTRB(
                            isSmallScreen ? 16 : 18,
                            0,
                            isSmallScreen ? 16 : 18,
                            18,
                          ),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _alertCard(
                                service: service,
                                alert: alert,
                                isSmallScreen: isSmallScreen,
                              ),
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

  Widget _topHeader({
    required int alertCount,
    required bool isSmallScreen,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stackHeader = constraints.maxWidth < 380;

        if (stackHeader) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alerts',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
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
              _countPill(alertCount),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alerts',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Monitor warnings and system updates',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _countPill(alertCount),
          ],
        );
      },
    );
  }

  Widget _countPill(int count) {
    return Container(
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
        '$count alerts',
        style: const TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _summarySection({
    required int warningCount,
    required int stableCount,
    required bool isSmallScreen,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stackSummary = constraints.maxWidth < 360;

        if (stackSummary) {
          return Column(
            children: [
              _summaryChip(
                title: 'Warnings',
                value: warningCount.toString(),
                color: Colors.orange,
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(height: 10),
              _summaryChip(
                title: 'Stable',
                value: stableCount.toString(),
                color: primaryGreen,
                icon: Icons.check_circle_rounded,
              ),
            ],
          );
        }

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
      },
    );
  }

  Widget _summaryChip({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
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

  Widget _alertCard({
    required MockSensorService service,
    required AlertItem alert,
    required bool isSmallScreen,
  }) {
    final color = alert.isWarning ? Colors.orange : primaryGreen;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 15),
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
            radius: isSmallScreen ? 20 : 21,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              alert.isWarning
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_rounded,
              color: color,
              size: isSmallScreen ? 20 : 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool compact = constraints.maxWidth < 230;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (compact) ...[
                      Text(
                        alert.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _statusBadge(
                        text: alert.isWarning ? 'Warning' : 'Stable',
                        color: color,
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _statusBadge(
                            text: alert.isWarning ? 'Warning' : 'Stable',
                            color: color,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      alert.message,
                      maxLines: compact ? 3 : 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
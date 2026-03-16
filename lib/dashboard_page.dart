import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isSmallScreen = screenWidth < 390;
    final double gridAspectRatio = isSmallScreen ? 0.88 : 0.98;
    final double sensorValueSize = isSmallScreen ? 26 : 30;
    final double heroTempSize = isSmallScreen ? 34 : 38;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final reading = service.currentReading;
        final statusColor = service.statusColor(reading.status);

        return Scaffold(
          backgroundColor: softBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(reading.online),
                  const SizedBox(height: 18),
                  _heroStatusCard(
                    reading: reading,
                    service: service,
                    statusColor: statusColor,
                    heroTempSize: heroTempSize,
                    isSmallScreen: isSmallScreen,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Environmental Overview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sensorGrid(
                    reading,
                    gridAspectRatio: gridAspectRatio,
                    sensorValueSize: sensorValueSize,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Devices',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _deviceCard(
                    title: 'Cleanroom Main Device',
                    subtitle: 'Tap to view device details',
                    online: reading.online,
                  ),
                  const SizedBox(height: 10),
                  _deviceCard(
                    title: 'Monitoring Node A1',
                    subtitle: 'PM2.5 / Temp / Humidity / Lux active',
                    online: true,
                  ),
                  const SizedBox(height: 16),
                  _recentAlertsSection(service),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(bool online) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Text(
                  'Cleanroom Operator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '●',
                  style: TextStyle(
                    color: online ? primaryGreen : Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _heroStatusCard({
    required SensorReading reading,
    required MockSensorService service,
    required Color statusColor,
    required double heroTempSize,
    required bool isSmallScreen,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                isSmallScreen ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${reading.temperature.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: heroTempSize,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ISO monitoring mode active',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 18,
                      runSpacing: 8,
                      children: [
                        _miniReading(
                          label: 'System Status',
                          value: reading.status,
                        ),
                        _miniReading(
                          label: 'Device',
                          value: reading.online ? 'Online' : 'Offline',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: isSmallScreen ? 74 : 84,
                height: isSmallScreen ? 74 : 84,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  reading.status == 'SAFE'
                      ? Icons.cloud_done_rounded
                      : reading.status == 'WARNING'
                          ? Icons.warning_amber_rounded
                          : Icons.error_outline_rounded,
                  size: isSmallScreen ? 36 : 42,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Last updated: ${service.formatTime(reading.timestamp)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniReading({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black45,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _sensorGrid(
    SensorReading reading, {
    required double gridAspectRatio,
    required double sensorValueSize,
  }) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: gridAspectRatio,
      children: [
        _colorStatCard(
          title: 'PM2.5',
          value: '${reading.pm25.toStringAsFixed(1)}',
          note: 'Air particles',
          icon: Icons.air_rounded,
          colors: const [Color(0xFF22B8CF), Color(0xFF15AABF)],
          valueSize: sensorValueSize,
        ),
        _colorStatCard(
          title: 'Humidity',
          value: '${reading.humidity.toStringAsFixed(1)}%',
          note: 'Relative humidity',
          icon: Icons.water_drop_rounded,
          colors: const [Color(0xFFFF922B), Color(0xFFFF6B6B)],
          valueSize: sensorValueSize,
        ),
        _colorStatCard(
          title: 'Temperature',
          value: '${reading.temperature.toStringAsFixed(1)}°C',
          note: 'Normal range: 20°C - 24°C',
          icon: Icons.thermostat_rounded,
          colors: const [Color(0xFF40C057), Color(0xFF2F9E44)],
          valueSize: sensorValueSize,
        ),
        _colorStatCard(
          title: 'Luminance',
          value: '${reading.luminance.toStringAsFixed(0)} lux',
          note: 'Light intensity',
          icon: Icons.wb_sunny_outlined,
          colors: const [Color(0xFFFAB005), Color(0xFFF59F00)],
          valueSize: sensorValueSize - 2,
        ),
      ],
    );
  }

  Widget _colorStatCard({
    required String title,
    required String value,
    required String note,
    required IconData icon,
    required List<Color> colors,
    required double valueSize,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: valueSize,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceCard({
    required String title,
    required String subtitle,
    required bool online,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: online ? primaryGreen : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentAlertsSection(MockSensorService service) {
    final alerts = service.alerts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Alerts',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...alerts.map(
          (alert) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        (alert.isWarning ? Colors.orange : primaryGreen)
                            .withValues(alpha: 0.12),
                    child: Icon(
                      alert.isWarning
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_rounded,
                      color: alert.isWarning ? Colors.orange : primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
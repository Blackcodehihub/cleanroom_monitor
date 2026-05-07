import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';
import 'alerts_page.dart';

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
        final warningCount = service.alerts.where((a) => a.isWarning).length;

        return Scaffold(
          backgroundColor: softBg,
          body: SafeArea(
            child: SingleChildScrollView(
              // 1. Removed global side padding so the top bar can stretch full width
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Full-width header spanning edge to edge
                  _buildTopBar(context, reading.online, warningCount),
                  const SizedBox(height: 18),
                  
                  // 3. Re-applied the 18px side padding ONLY to the content below the header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heroStatusCard(
                          reading: reading,
                          service: service,
                          statusColor: statusColor,
                          heroTempSize: heroTempSize,
                          isSmallScreen: isSmallScreen,
                        ),
                        const SizedBox(height: 14),
                        _lightControlCard(service),
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
                          title: 'Monitoring Node A1',
                          subtitle: 'PM2.5 / Temp / Humidity / Lux active',
                          online: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, bool online, int warningCount) {
    return Container(
      width: double.infinity,
      // Added a bit more vertical padding so it feels spacious
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        // Only round the bottom corners so it sits flush against the top/sides
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryGreen.withValues(alpha: 0.08), 
              border: Border.all(
                color: primaryGreen.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Image.asset(
              'assets/images/logo2.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alima Dashboard',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      online ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                      size: 14,
                      color: online ? primaryGreen : Colors.redAccent,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        online 
                            ? 'Live Sync' 
                            : 'Node Unreachable • Awaiting Uplink',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertsPage()),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7), 
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
                if (warningCount > 0)
                  Positioned(
                    top: 2,
                    right: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
            crossAxisAlignment: isSmallScreen ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _lightControlCard(MockSensorService service) {
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
          const Text(
            'Light Control',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mode: ${service.overrideModeText} • Status: ${service.lightStatusText}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _lightMiniBox(
                  'ON Time',
                  '${service.thresholds.lightOnMinutes} min',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _lightMiniBox(
                  'OFF Time',
                  '${service.thresholds.lightOffMinutes} min',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _lightMiniBox(
                  'Remaining',
                  service.thresholds.overrideMode == LightOverrideMode.auto
                      ? '${service.minutesRemainingInLightCycle} min'
                      : '--',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lightMiniBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
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
          value: reading.pm25.toStringAsFixed(1),
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
          note: 'Normal range configured in thresholds',
          icon: Icons.thermostat_rounded,
          colors: const [Color(0xFF40C057), Color(0xFF2F9E44)],
          valueSize: sensorValueSize,
        ),
        _colorStatCard(
          title: 'Luminance',
          value: '${reading.luminance.toStringAsFixed(0)} lux',
          note: 'Based on timer / override mode',
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
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
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
}
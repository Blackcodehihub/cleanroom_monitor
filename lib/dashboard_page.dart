import 'package:flutter/material.dart';
import 'services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  final String deviceId = "031bdde7-98e1-469c-8819-b989c97d308a";

  Map<String, dynamic>? latestReading;
  List<dynamic> alerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final readingData = await ApiService.getLatestReading(deviceId);
      final alertData = await ApiService.getAlerts();

      setState(() {
        latestReading = readingData;
        alerts = alertData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading dashboard: $e")),
      );
    }
  }

  String getStatus() {
    final temp = latestReading?['temperature'] ?? 0;
    final humidity = latestReading?['humidity'] ?? 0;
    final particles = latestReading?['particle_level'] ?? 0;

    if (temp > 30 || humidity > 65 || particles > 1000) {
      return "WARNING";
    }

    return "SAFE";
  }

  Color getStatusColor(String status) {
    if (status == "SAFE") return primaryGreen;
    if (status == "WARNING") return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 390;
    final double gridAspectRatio = isSmallScreen ? 0.88 : 0.98;
    final double sensorValueSize = isSmallScreen ? 26 : 30;
    final double heroTempSize = isSmallScreen ? 34 : 38;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: softBg,
        body: Center(
          child: CircularProgressIndicator(color: primaryGreen),
        ),
      );
    }

    final status = getStatus();
    final statusColor = getStatusColor(status);

    return Scaffold(
      backgroundColor: softBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchDashboardData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(true),
                const SizedBox(height: 18),
                _heroStatusCard(
                  status: status,
                  statusColor: statusColor,
                  heroTempSize: heroTempSize,
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 14),
                _lightControlCard(),
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
                  title: 'Alima Device 1',
                  subtitle: 'Cleanroom A monitoring device',
                  online: true,
                ),
                const SizedBox(height: 16),
                _recentAlertsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool online) {
    return Column(
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
    );
  }

  Widget _heroStatusCard({
    required String status,
    required Color statusColor,
    required double heroTempSize,
    required bool isSmallScreen,
  }) {
    final temperature = latestReading?['temperature'] ?? '--';
    final updatedAt = latestReading?['created_at'] ?? 'No data';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: isSmallScreen
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$temperature°C',
                      style: TextStyle(
                        fontSize: heroTempSize,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time cleanroom monitoring active',
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
                        _miniReading(label: 'System Status', value: status),
                        _miniReading(label: 'Device', value: 'Online'),
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
                  color: statusColor.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == 'SAFE'
                      ? Icons.cloud_done_rounded
                      : Icons.warning_amber_rounded,
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
                    'Last updated: $updatedAt',
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
                    color: Colors.white.withOpacity(0.20),
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

  Widget _lightControlCard() {
    return Container(
      width: double.infinity,
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Light Control',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mode: Auto • Override: ON/OFF available',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
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

  Widget _sensorGrid({
    required double gridAspectRatio,
    required double sensorValueSize,
  }) {
    final temperature = latestReading?['temperature'] ?? '--';
    final humidity = latestReading?['humidity'] ?? '--';
    final particles = latestReading?['particle_level'] ?? '--';

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: gridAspectRatio,
      children: [
        _colorStatCard(
          title: 'Particles',
          value: '$particles',
          note: 'Air particles',
          icon: Icons.air_rounded,
          colors: const [Color(0xFF22B8CF), Color(0xFF15AABF)],
          valueSize: sensorValueSize,
        ),
        _colorStatCard(
          title: 'Humidity',
          value: '$humidity%',
          note: 'Relative humidity',
          icon: Icons.water_drop_rounded,
          colors: const [Color(0xFFFF922B), Color(0xFFFF6B6B)],
          valueSize: sensorValueSize,
        ),
        _colorStatCard(
          title: 'Temperature',
          value: '$temperature°C',
          note: 'Normal range configured in thresholds',
          icon: Icons.thermostat_rounded,
          colors: const [Color(0xFF40C057), Color(0xFF2F9E44)],
          valueSize: sensorValueSize,
        ),
        _colorStatCard(
          title: 'Luminance',
          value: '-- lux',
          note: 'Light control: auto / override',
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
            backgroundColor: Colors.white.withOpacity(0.22),
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
            color: Colors.black.withOpacity(0.04),
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

  Widget _recentAlertsSection() {
    final recentAlerts = alerts.take(3).toList();

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
        if (recentAlerts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'No recent alerts',
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          ...recentAlerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                      radius: 18,
                      backgroundColor: Colors.orange.withOpacity(0.12),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert['type'] ?? 'Alert',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert['message'] ?? '',
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
import 'package:flutter/material.dart';
import 'services/api_service.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  List<dynamic> alerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    try {
      final data = await ApiService.getAlerts();

      setState(() {
        alerts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print("Error loading alerts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final warningCount = alerts.where((a) => a['severity'] != 'low').length;

    final stableCount = alerts.where((a) => a['severity'] == 'low').length;

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
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _alertCard(alert),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topHeader(BuildContext context, int alertCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Expanded(
              child: Text(
                'Alerts',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Monitor warnings and system updates',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
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
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.16),
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
    );
  }

  Widget _alertCard(dynamic alert) {
    final color = alert['severity'] == 'critical' ? Colors.red : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(15),
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
          CircleAvatar(
            radius: 21,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(Icons.warning_amber_rounded, color: color),
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
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert['message'] ?? '',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  alert['created_at'] ?? '',
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

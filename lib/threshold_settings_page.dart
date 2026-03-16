import 'package:flutter/material.dart';

class ThresholdSettingsPage extends StatefulWidget {
  const ThresholdSettingsPage({super.key});

  @override
  State<ThresholdSettingsPage> createState() => _ThresholdSettingsPageState();
}

class _ThresholdSettingsPageState extends State<ThresholdSettingsPage> {
  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  final TextEditingController pm25MaxController =
      TextEditingController(text: '35');
  final TextEditingController tempMinController =
      TextEditingController(text: '20');
  final TextEditingController tempMaxController =
      TextEditingController(text: '24');
  final TextEditingController humidityMinController =
      TextEditingController(text: '40');
  final TextEditingController humidityMaxController =
      TextEditingController(text: '60');
  final TextEditingController luminanceMinController =
      TextEditingController(text: '3000');
  final TextEditingController luminanceMaxController =
      TextEditingController(text: '9000');

  @override
  void dispose() {
    pm25MaxController.dispose();
    tempMinController.dispose();
    tempMaxController.dispose();
    humidityMinController.dispose();
    humidityMaxController.dispose();
    luminanceMinController.dispose();
    luminanceMaxController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Threshold settings saved successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 390;

    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: const Text(
          'Threshold Settings',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isSmallScreen ? 16 : 18,
          6,
          isSmallScreen ? 16 : 18,
          24,
        ),
        child: Column(
          children: [
            _infoCard(),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'PM2.5 Limit',
              subtitle: 'Set the maximum safe PM2.5 concentration',
              child: _singleField(
                label: 'Maximum PM2.5',
                controller: pm25MaxController,
                suffix: 'µg/m³',
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Temperature Range',
              subtitle: 'Set the acceptable operating temperature range',
              child: _rangeFields(
                minLabel: 'Minimum',
                maxLabel: 'Maximum',
                minController: tempMinController,
                maxController: tempMaxController,
                suffix: '°C',
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Humidity Range',
              subtitle: 'Set the acceptable relative humidity range',
              child: _rangeFields(
                minLabel: 'Minimum',
                maxLabel: 'Maximum',
                minController: humidityMinController,
                maxController: humidityMaxController,
                suffix: '%',
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Luminance Range',
              subtitle: 'Set the acceptable light intensity range',
              child: _rangeFields(
                minLabel: 'Minimum',
                maxLabel: 'Maximum',
                minController: luminanceMinController,
                maxController: luminanceMaxController,
                suffix: 'lux',
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Save Thresholds',
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
            child: Icon(Icons.tune_rounded, color: primaryGreen),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monitoring Threshold Controls',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'These values define when the system should show safe, warning, or critical conditions.',
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
    required Widget child,
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _singleField({
    required String label,
    required TextEditingController controller,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: primaryGreen, width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rangeFields({
    required String minLabel,
    required String maxLabel,
    required TextEditingController minController,
    required TextEditingController maxController,
    required String suffix,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stack = constraints.maxWidth < 320;

        if (stack) {
          return Column(
            children: [
              _singleField(
                label: minLabel,
                controller: minController,
                suffix: suffix,
              ),
              const SizedBox(height: 12),
              _singleField(
                label: maxLabel,
                controller: maxController,
                suffix: suffix,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _singleField(
                label: minLabel,
                controller: minController,
                suffix: suffix,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _singleField(
                label: maxLabel,
                controller: maxController,
                suffix: suffix,
              ),
            ),
          ],
        );
      },
    );
  }
}
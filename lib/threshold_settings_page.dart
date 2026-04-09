import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';

class ThresholdSettingsPage extends StatefulWidget {
  const ThresholdSettingsPage({super.key});

  @override
  State<ThresholdSettingsPage> createState() => _ThresholdSettingsPageState();
}

class _ThresholdSettingsPageState extends State<ThresholdSettingsPage> {
  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  late final TextEditingController pm25MaxController;
  late final TextEditingController tempMinController;
  late final TextEditingController tempMaxController;
  late final TextEditingController humidityMinController;
  late final TextEditingController humidityMaxController;
  late final TextEditingController lightOnController;
  late final TextEditingController lightOffController;

  @override
  void initState() {
    super.initState();
    final settings = MockSensorService.instance.thresholds;

    pm25MaxController =
        TextEditingController(text: settings.pm25Max.toStringAsFixed(0));
    tempMinController =
        TextEditingController(text: settings.tempMin.toStringAsFixed(0));
    tempMaxController =
        TextEditingController(text: settings.tempMax.toStringAsFixed(0));
    humidityMinController =
        TextEditingController(text: settings.humidityMin.toStringAsFixed(0));
    humidityMaxController =
        TextEditingController(text: settings.humidityMax.toStringAsFixed(0));
    lightOnController =
        TextEditingController(text: settings.lightOnMinutes.toString());
    lightOffController =
        TextEditingController(text: settings.lightOffMinutes.toString());
  }

  @override
  void dispose() {
    pm25MaxController.dispose();
    tempMinController.dispose();
    tempMaxController.dispose();
    humidityMinController.dispose();
    humidityMaxController.dispose();
    lightOnController.dispose();
    lightOffController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final service = MockSensorService.instance;

    final pm25Max = double.tryParse(pm25MaxController.text.trim());
    final tempMin = double.tryParse(tempMinController.text.trim());
    final tempMax = double.tryParse(tempMaxController.text.trim());
    final humidityMin = double.tryParse(humidityMinController.text.trim());
    final humidityMax = double.tryParse(humidityMaxController.text.trim());
    final lightOn = int.tryParse(lightOnController.text.trim());
    final lightOff = int.tryParse(lightOffController.text.trim());

    if (pm25Max == null ||
        tempMin == null ||
        tempMax == null ||
        humidityMin == null ||
        humidityMax == null ||
        lightOn == null ||
        lightOff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numeric values')),
      );
      return;
    }

    if (tempMin >= tempMax || humidityMin >= humidityMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum values must be lower than maximum values'),
        ),
      );
      return;
    }

    if (lightOn <= 0 || lightOff <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Light ON/OFF time must be greater than 0'),
        ),
      );
      return;
    }

    service.updateThresholdSettings(
      pm25Max: pm25Max,
      tempMin: tempMin,
      tempMax: tempMax,
      humidityMin: humidityMin,
      humidityMax: humidityMax,
      lightOnMinutes: lightOn,
      lightOffMinutes: lightOff,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Threshold and light schedule saved successfully'),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 390;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: softBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 16 : 18,
                12,
                isSmallScreen ? 16 : 18,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thresholds',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sensor limits, light schedule, and override controls',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoCard(service),
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
                    title: 'Light Schedule',
                    subtitle:
                        'Set how long the lights stay ON and OFF in auto mode',
                    child: _rangeFields(
                      minLabel: 'ON Duration',
                      maxLabel: 'OFF Duration',
                      minController: lightOnController,
                      maxController: lightOffController,
                      suffix: 'min',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _sectionCard(
                    title: 'Light Override',
                    subtitle: 'Manual control for the cleanroom lights',
                    child: _overrideButtons(service),
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
          ),
        );
      },
    );
  }

  Widget _infoCard(MockSensorService service) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.tune_rounded, color: primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Current light mode: ${service.overrideModeText} • Light status: ${service.lightStatusText}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overrideButtons(MockSensorService service) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _overrideButton(
                label: 'Auto',
                selected:
                    service.thresholds.overrideMode == LightOverrideMode.auto,
                onTap: () => service.setLightOverride(LightOverrideMode.auto),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _overrideButton(
                label: 'Force ON',
                selected:
                    service.thresholds.overrideMode == LightOverrideMode.forceOn,
                onTap: () => service.setLightOverride(LightOverrideMode.forceOn),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _overrideButton(
                label: 'Force OFF',
                selected: service.thresholds.overrideMode ==
                    LightOverrideMode.forceOff,
                onTap: () =>
                    service.setLightOverride(LightOverrideMode.forceOff),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _overrideButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primaryGreen : const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
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
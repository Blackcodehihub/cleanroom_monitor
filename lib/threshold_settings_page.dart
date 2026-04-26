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
  late final TextEditingController notificationNumberController;

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
    notificationNumberController =
        TextEditingController(text: settings.notificationNumber);
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
    notificationNumberController.dispose();
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
    final notificationNumber = notificationNumberController.text.trim();

    if (pm25Max == null ||
        tempMin == null ||
        tempMax == null ||
        humidityMin == null ||
        humidityMax == null ||
        lightOn == null ||
        lightOff == null ||
        notificationNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields properly')),
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

    service.updateNotificationNumber(notificationNumber);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Limits saved successfully')),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: softBg,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                    child: _header(service),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _tabs(),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _tabBody(
                          children: [
                            _sectionCard(
                              icon: Icons.air_rounded,
                              title: 'Air Quality Limit',
                              subtitle: 'Set the maximum allowed PM2.5 value.',
                              child: _singleField(
                                label: 'PM2.5 Maximum',
                                controller: pm25MaxController,
                                suffix: 'µg/m³',
                              ),
                            ),
                          ],
                        ),
                        _tabBody(
                          children: [
                            _sectionCard(
                              icon: Icons.thermostat_rounded,
                              title: 'Temperature Range',
                              subtitle: 'Set the safe temperature range.',
                              child: _rangeFields(
                                minLabel: 'Min Temp',
                                maxLabel: 'Max Temp',
                                minController: tempMinController,
                                maxController: tempMaxController,
                                suffix: '°C',
                              ),
                            ),
                            const SizedBox(height: 12),
                            _sectionCard(
                              icon: Icons.water_drop_rounded,
                              title: 'Humidity Range',
                              subtitle: 'Set the safe humidity range.',
                              child: _rangeFields(
                                minLabel: 'Min Humidity',
                                maxLabel: 'Max Humidity',
                                minController: humidityMinController,
                                maxController: humidityMaxController,
                                suffix: '%',
                              ),
                            ),
                          ],
                        ),
                        _tabBody(
                          children: [
                            _sectionCard(
                              icon: Icons.light_mode_rounded,
                              title: 'Light Schedule',
                              subtitle:
                                  'Set how long lights stay ON and OFF in auto mode.',
                              child: _rangeFields(
                                minLabel: 'ON Duration',
                                maxLabel: 'OFF Duration',
                                minController: lightOnController,
                                maxController: lightOffController,
                                suffix: 'min',
                              ),
                            ),
                            const SizedBox(height: 12),
                            _sectionCard(
                              icon: Icons.touch_app_rounded,
                              title: 'Light Override',
                              subtitle: 'Manually control the lights.',
                              child: _overrideButtons(service),
                            ),
                          ],
                        ),
                        _tabBody(
                          children: [
                            _sectionCard(
                              icon: Icons.sms_outlined,
                              title: 'Notification Receiver',
                              subtitle:
                                  'Set the phone number that will receive alert notifications.',
                              child: _singleField(
                                label: 'Contact Number',
                                controller: notificationNumberController,
                                suffix: '',
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text(
                          'Save Limits',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(MockSensorService service) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Limits',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage thresholds, lighting, and alert receiver',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            service.lightStatusText,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Color(0xFFEAF6EC),
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        labelColor: primaryGreen,
        unselectedLabelColor: Colors.black54,
        labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        unselectedLabelStyle:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Air'),
          Tab(text: 'Climate'),
          Tab(text: 'Light'),
          Tab(text: 'Notify'),
        ],
      ),
    );
  }

  Widget _tabBody({required List<Widget> children}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Column(children: children),
    );
  }

  Widget _sectionCard({
    required IconData icon,
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primaryGreen.withValues(alpha: 0.10),
                child: Icon(icon, color: primaryGreen, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
    TextInputType keyboardType = TextInputType.number,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(suffix: suffix),
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
    return Row(
      children: [
        Expanded(
          child: _singleField(
            label: minLabel,
            controller: minController,
            suffix: suffix,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _singleField(
            label: maxLabel,
            controller: maxController,
            suffix: suffix,
          ),
        ),
      ],
    );
  }

  Widget _overrideButtons(MockSensorService service) {
    return Row(
      children: [
        Expanded(
          child: _overrideButton(
            label: 'Auto',
            selected: service.thresholds.overrideMode == LightOverrideMode.auto,
            onTap: () => service.setLightOverride(LightOverrideMode.auto),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _overrideButton(
            label: 'ON',
            selected:
                service.thresholds.overrideMode == LightOverrideMode.forceOn,
            onTap: () => service.setLightOverride(LightOverrideMode.forceOn),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _overrideButton(
            label: 'OFF',
            selected:
                service.thresholds.overrideMode == LightOverrideMode.forceOff,
            onTap: () => service.setLightOverride(LightOverrideMode.forceOff),
          ),
        ),
      ],
    );
  }

  Widget _overrideButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: selected ? primaryGreen : const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black54,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  InputDecoration _inputDecoration({required String suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      suffixText: suffix.isEmpty ? null : suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
    );
  }
}
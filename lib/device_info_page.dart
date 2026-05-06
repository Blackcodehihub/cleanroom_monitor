import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';

class DeviceInformationPage extends StatefulWidget {
  const DeviceInformationPage({super.key});

  @override
  State<DeviceInformationPage> createState() => _DeviceInformationPageState();
}

class _DeviceInformationPageState extends State<DeviceInformationPage> {
  // Sophisticated Color Palette
  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentGreen = Color(0xFFE8F5E9);
  static const Color softBg = Color(0xFFF8F9FA);
  static const Color cardShadow = Color(0x0D000000);

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final reading = service.currentReading;
        final device = service.selectedDevice;

        return Scaffold(
          backgroundColor: softBg,
          appBar: AppBar(
            title: const Text('System Configuration', 
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            children: [
              _heroCard(service, reading),
              const SizedBox(height: 24),
              _sectionHeader('Environment Setup', Icons.layers_outlined),
              const SizedBox(height: 12),
              _roomManagementCard(context, service),
              const SizedBox(height: 24),
              if (device != null) ...[
                _sectionHeader('Hardware Intelligence', Icons.memory_outlined),
                const SizedBox(height: 12),
                _deviceDetailsCard(service, device),
                const SizedBox(height: 16),
                _credentialsCard(device),
              ] else
                _emptyStateCard(),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black38),
        const SizedBox(width: 8),
        Text(title.toUpperCase(), 
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black38, letterSpacing: 1.1)),
      ],
    );
  }

  Widget _heroCard(MockSensorService service, SensorReading reading) {
    final device = service.selectedDevice;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryGreen, darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: primaryGreen.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.settings_input_component_rounded, color: Colors.white, size: 24),
              ),
              _statusBadge(reading.online),
            ],
          ),
          const SizedBox(height: 24),
          Text(device?.deviceName ?? 'No Device Initialized', 
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('Location: ${service.selectedRoomName} • Hardware ID: ${device?.deviceId ?? 'N/A'}', 
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _statusBadge(bool online) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: online ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.redAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: online ? Colors.greenAccent : Colors.redAccent),
          const SizedBox(width: 6),
          Text(online ? 'STABLE' : 'OFFLINE', 
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _roomManagementCard(BuildContext context, MockSensorService service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDeco(),
      child: Column(
        children: [
          // Horizontal Scrollable Chips
          SizedBox(
            height: 45, 
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: service.rooms.map((room) {
                  final isSelected = room.roomId == service.selectedRoomId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      label: Text(room.roomName),
                      selected: isSelected,
                      onSelected: (_) => service.selectRoom(room.roomId),
                      checkmarkColor: primaryGreen,
                      selectedColor: accentGreen,
                      backgroundColor: softBg,
                      side: BorderSide(color: isSelected ? primaryGreen : Colors.black12, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      labelStyle: TextStyle(
                        color: isSelected ? primaryGreen : Colors.black87, 
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: service.rooms.length > 1 
                          ? () => _confirmDelete(context, service, room.roomName) 
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: softBg, thickness: 2)),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () => _showAddSetupModal(context, service),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('REGISTER NEW SYSTEM', 
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen, 
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceDetailsCard(MockSensorService service, CleanroomDevice device) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDeco(),
      child: Column(
        children: [
          _infoTile('Assigned Name', device.deviceName, Icons.badge_outlined),
          _infoTile('Hardware UID', device.deviceId, Icons.qr_code_scanner_rounded),
          _infoTile('Sync Protocol', 'Real-time / ESP-DASH', Icons.sync_rounded),
        ],
      ),
    );
  }

  Widget _credentialsCard(CleanroomDevice device) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDeco(),
      child: Column(
        children: [
          _infoTile('ESP Auth User', device.espUsername, Icons.account_circle_outlined),
          _infoTile('Secure Password', '••••••••', Icons.lock_outline_rounded),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: softBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: primaryGreen),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.w800)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyStateCard() => Container(
    padding: const EdgeInsets.all(40),
    decoration: _cardDeco(),
    child: const Column(
      children: [
        Icon(Icons.sensors_off_rounded, size: 48, color: Colors.black12),
        SizedBox(height: 16),
        Text('No Hardware Initialized', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black26)),
      ],
    ),
  );

  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white, 
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [BoxShadow(color: cardShadow, blurRadius: 20, offset: Offset(0, 10))],
  );

  void _showAddSetupModal(BuildContext context, MockSensorService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: _SetupModalContent(service: service),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MockSensorService service, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Room?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to permanently delete $name? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () { service.deleteSelectedRoom(); Navigator.pop(context); }, 
            child: const Text('DELETE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900))
          ),
        ],
      ),
    );
  }
}

class _SetupModalContent extends StatefulWidget {
  final MockSensorService service;
  const _SetupModalContent({required this.service});

  @override
  State<_SetupModalContent> createState() => _SetupModalContentState();
}

class _SetupModalContentState extends State<_SetupModalContent> {
  int currentStep = 1;
  bool obscurePass = true;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final roomName = TextEditingController();
  final wifiSSID = TextEditingController();
  final wifiPass = TextEditingController();
  final deviceID = TextEditingController();
  final deviceName = TextEditingController();
  final espUser = TextEditingController();
  final espPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, 
        left: 24, 
        right: 24, 
        top: 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text(currentStep == 1 ? 'Part 1: Basic Setup' : 'Part 2: Hardware Registry', 
               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          currentStep == 1 ? _stepOne() : _stepTwo(),
          const SizedBox(height: 32),
          _navigationButtons(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _stepOne() {
    return Form(
      key: _formKey1,
      child: Column(
        children: [
          _input(roomName, 'Designated Room Name', Icons.meeting_room_rounded),
          const SizedBox(height: 12),
          _input(wifiSSID, 'Network SSID', Icons.wifi_rounded),
          const SizedBox(height: 12),
          _input(wifiPass, 'Network Key', Icons.lock_rounded, isPass: true),
        ],
      ),
    );
  }

  Widget _stepTwo() {
    return Form(
      key: _formKey2,
      child: Column(
        children: [
          _input(deviceID, 'Hardware ID (MAC/UID)', Icons.fingerprint_rounded), // Hardware specific icon
          const SizedBox(height: 12),
          _input(deviceName, 'Friendly Device Name', Icons.air_rounded), // Air sensor icon
          const SizedBox(height: 12),
          _input(espUser, 'ESP32 Admin User', Icons.admin_panel_settings_outlined), // Auth icon
          const SizedBox(height: 12),
          _input(espPass, 'ESP32 Auth Password', Icons.password_rounded, isPass: true),
        ],
      ),
    );
  }

  Widget _input(TextEditingController controller, String label, IconData icon, {bool isPass = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPass ? obscurePass : false,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color(0xFF2F9E44), size: 22),
        suffixIcon: isPass ? IconButton(
          icon: Icon(obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded, 
                     color: Colors.black26, size: 20),
          onPressed: () => setState(() => obscurePass = !obscurePass),
        ) : null,
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide.none
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2F9E44), width: 1.5),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required field' : null,
    );
  }

  Widget _navigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentStep == 2) 
          IconButton(
            onPressed: () => setState(() => currentStep = 1), 
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            style: IconButton.styleFrom(backgroundColor: const Color(0xFFF8F9FA), padding: const EdgeInsets.all(16)),
          )
        else
          const Spacer(),
        ElevatedButton(
          onPressed: () {
            if (currentStep == 1 && _formKey1.currentState!.validate()) {
              setState(() => currentStep = 2);
            } else if (currentStep == 2 && _formKey2.currentState!.validate()) {
              widget.service.addRoom(roomName.text);
              widget.service.addDeviceToSelectedRoom(
                deviceId: deviceID.text,
                deviceName: deviceName.text,
                username: espUser.text,
                password: espPass.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('System Linked Successfully!')));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F9E44), 
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(currentStep == 1 ? 'PROCEED' : 'COMPLETE SETUP', style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}
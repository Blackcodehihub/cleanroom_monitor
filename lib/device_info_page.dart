import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';

class DeviceInformationPage extends StatelessWidget {
  const DeviceInformationPage({super.key});

  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color darkGreen = Color(0xFF237A35);
  static const Color softBg = Color(0xFFF4F5F7);
  static const Color cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final reading = service.currentReading;
        final room = service.selectedRoom;
        final device = service.selectedDevice;

        return Scaffold(
          backgroundColor: softBg,
          appBar: AppBar(
            title: const Text(
              'Device Information',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              _heroCard(service, reading),
              const SizedBox(height: 16),
              _roomManagementCard(context, service),
              const SizedBox(height: 14),
              _deviceManagementCard(context, service),
              const SizedBox(height: 14),
              if (device != null) ...[
                _deviceDetailsCard(service, room, device, reading),
                const SizedBox(height: 14),
                _credentialsCard(device),
                const SizedBox(height: 14),
                _liveValuesCard(service, device, reading),
              ] else
                _emptyDeviceCard(context, service),
            ],
          ),
        );
      },
    );
  }

  Widget _heroCard(MockSensorService service, SensorReading reading) {
    final device = service.selectedDevice;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryGreen, darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.memory_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device?.deviceName ?? 'No Device Assigned',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${service.selectedRoomName} • ${device?.deviceId ?? 'No device ID'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _heroBadge(
                      reading.online ? 'Online' : 'Offline',
                      reading.online ? Icons.wifi_rounded : Icons.wifi_off,
                    ),
                    const SizedBox(width: 8),
                    _heroBadge(
                      service.formatTime(reading.timestamp),
                      Icons.schedule_rounded,
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

  Widget _heroBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomManagementCard(BuildContext context, MockSensorService service) {
    return _sectionCard(
      icon: Icons.meeting_room_outlined,
      title: 'Room Management',
      subtitle: 'Select which cleanroom area you want to monitor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: service.rooms.map((room) {
              final selected = room.roomId == service.selectedRoomId;

              return GestureDetector(
                onTap: () => service.selectRoom(room.roomId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? primaryGreen.withValues(alpha: 0.12)
                        : const Color(0xFFF6F7F8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? primaryGreen : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        const Icon(
                          Icons.check_rounded,
                          color: primaryGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        room.roomName,
                        style: TextStyle(
                          color: selected ? primaryGreen : Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _softButton(
                  label: 'Add Room',
                  icon: Icons.add_home_work_outlined,
                  color: primaryGreen,
                  onTap: () => _showAddRoomDialog(context, service),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _softButton(
                  label: 'Delete Room',
                  icon: Icons.delete_outline_rounded,
                  color: Colors.red,
                  onTap: service.rooms.length <= 1
                      ? null
                      : () => _confirmDeleteRoom(context, service),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deviceManagementCard(BuildContext context, MockSensorService service) {
    final room = service.selectedRoom;

    return _sectionCard(
      icon: Icons.developer_board_rounded,
      title: 'Device Management',
      subtitle: 'Manage ESP32 devices assigned to ${room.roomName}',
      child: Column(
        children: [
          if (room.devices.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'No ESP32 device has been assigned to this room.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            )
          else
            ...room.devices.map((device) {
              final selected = device.deviceId == room.selectedDeviceId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => service.selectDevice(device.deviceId),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? primaryGreen.withValues(alpha: 0.09)
                          : const Color(0xFFF6F7F8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? primaryGreen : Colors.transparent,
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 21,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.memory_rounded,
                            color: selected ? primaryGreen : Colors.grey,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.deviceName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Device ID: ${device.deviceId}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: primaryGreen,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _softButton(
                  label: 'Add Device',
                  icon: Icons.add_circle_outline_rounded,
                  color: primaryGreen,
                  onTap: () => _showAddDeviceDialog(context, service),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _softButton(
                  label: 'Delete Device',
                  icon: Icons.delete_outline_rounded,
                  color: Colors.red,
                  onTap: service.selectedDevice == null
                      ? null
                      : () => _confirmDeleteDevice(context, service),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deviceDetailsCard(
    MockSensorService service,
    CleanroomRoom room,
    CleanroomDevice device,
    SensorReading reading,
  ) {
    return _sectionCard(
      icon: Icons.info_outline_rounded,
      title: 'Selected Device Details',
      subtitle: 'Only this device controls the live data shown in the app',
      child: Column(
        children: [
          _infoRow('Room', room.roomName),
          _divider(),
          _infoRow('Device Name', device.deviceName),
          _divider(),
          _infoRow('Device ID', device.deviceId),
          _divider(),
          _infoRow(
            'Connection',
            reading.online ? 'Online' : 'Offline',
            valueColor: reading.online ? primaryGreen : Colors.red,
          ),
          _divider(),
          _infoRow('Last Sync', service.formatTime(reading.timestamp)),
        ],
      ),
    );
  }

  Widget _credentialsCard(CleanroomDevice device) {
    return _sectionCard(
      icon: Icons.lock_outline_rounded,
      title: 'ESP32 Credentials',
      subtitle: 'Prepared for device-level access control',
      child: Column(
        children: [
          _infoRow('Username', device.espUsername),
          _divider(),
          _infoRow('Password', _hiddenPassword(device.espPassword)),
          _divider(),
          _infoRow('Access Mode', 'Device ID + Credentials'),
        ],
      ),
    );
  }

  Widget _liveValuesCard(
    MockSensorService service,
    CleanroomDevice device,
    SensorReading reading,
  ) {
    return _sectionCard(
      icon: Icons.sensors_rounded,
      title: 'Current Live Values',
      subtitle: 'Latest monitoring values from ${device.deviceId}',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _valueBox(
                  label: 'PM2.5',
                  value: reading.pm25.toStringAsFixed(1),
                  unit: 'µg/m³',
                  icon: Icons.air_rounded,
                  color: const Color(0xFF22B8CF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _valueBox(
                  label: 'Temp',
                  value: reading.temperature.toStringAsFixed(1),
                  unit: '°C',
                  icon: Icons.thermostat_rounded,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _valueBox(
                  label: 'Humidity',
                  value: reading.humidity.toStringAsFixed(1),
                  unit: '%',
                  icon: Icons.water_drop_rounded,
                  color: const Color(0xFFFF922B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _valueBox(
                  label: 'Lux',
                  value: reading.luminance.toStringAsFixed(0),
                  unit: 'lux',
                  icon: Icons.wb_sunny_outlined,
                  color: const Color(0xFFF59F00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _statusStrip(service, reading),
        ],
      ),
    );
  }

  Widget _statusStrip(MockSensorService service, SensorReading reading) {
    final color = service.statusColor(reading.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'System Status: ${reading.status}',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueBox({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value $unit',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyDeviceCard(BuildContext context, MockSensorService service) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.orange.withValues(alpha: 0.12),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Device Selected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add an ESP32 device to this room before viewing live sensor data.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _softButton(
            label: 'Add Device',
            icon: Icons.add_circle_outline_rounded,
            color: primaryGreen,
            onTap: () => _showAddDeviceDialog(context, service),
          ),
        ],
      ),
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
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primaryGreen.withValues(alpha: 0.10),
                child: Icon(icon, color: primaryGreen, size: 19),
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.045),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        color: Colors.black.withValues(alpha: 0.08),
      ),
    );
  }

  Widget _softButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final disabled = onTap == null;

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hiddenPassword(String password) {
    if (password.isEmpty) return '••••••';
    final count = password.length.clamp(6, 12);
    return List.generate(count, (_) => '•').join();
  }

  void _showAddRoomDialog(BuildContext context, MockSensorService service) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Room'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Room name',
              hintText: 'Example: Room 3',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                service.addRoom(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDeviceDialog(BuildContext context, MockSensorService service) {
    final deviceIdController = TextEditingController();
    final deviceNameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add ESP32 Device'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: deviceIdController,
                  decoration: const InputDecoration(
                    labelText: 'Device ID',
                    hintText: 'Example: deviceid3',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: deviceNameController,
                  decoration: const InputDecoration(
                    labelText: 'Device Name',
                    hintText: 'Example: ESP32 Room 3',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'ESP32 Username',
                    hintText: 'Example: room3_admin',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'ESP32 Password',
                    hintText: 'Enter device password',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                service.addDeviceToSelectedRoom(
                  deviceId: deviceIdController.text,
                  deviceName: deviceNameController.text,
                  username: usernameController.text,
                  password: passwordController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteRoom(BuildContext context, MockSensorService service) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Room?'),
          content: Text(
            'This will remove ${service.selectedRoom.roomName} and its devices.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                service.deleteSelectedRoom();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteDevice(BuildContext context, MockSensorService service) {
    final device = service.selectedDevice;
    if (device == null) return;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Device?'),
          content: Text(
            'This will remove ${device.deviceName} from ${service.selectedRoom.roomName}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                service.deleteSelectedDevice();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SensorReading {
  final double pm25;
  final double temperature;
  final double humidity;
  final double luminance;
  final DateTime timestamp;
  final bool online;

  SensorReading({
    required this.pm25,
    required this.temperature,
    required this.humidity,
    required this.luminance,
    required this.timestamp,
    required this.online,
  });

  String get status {
    if (!online) return 'OFFLINE';

    final service = MockSensorService.instance;
    final t = service.thresholds;

    final bool critical = pm25 > t.pm25Max ||
        temperature < t.tempMin ||
        temperature > t.tempMax ||
        humidity < t.humidityMin ||
        humidity > t.humidityMax;

    final bool warning = (pm25 >= (t.pm25Max - 10) && pm25 <= t.pm25Max) ||
        (temperature >= t.tempMin && temperature <= t.tempMin + 0.5) ||
        (temperature <= t.tempMax && temperature >= t.tempMax - 0.5) ||
        (humidity >= t.humidityMin && humidity <= t.humidityMin + 2) ||
        (humidity <= t.humidityMax && humidity >= t.humidityMax - 2);

    if (critical) return 'CRITICAL';
    if (warning) return 'WARNING';
    return 'SAFE';
  }
}

class AlertItem {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isWarning;

  AlertItem({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isWarning,
  });
}

enum LightOverrideMode {
  auto,
  forceOn,
  forceOff,
}

class ThresholdSettingsData {
  double pm25Max;
  double tempMin;
  double tempMax;
  double humidityMin;
  double humidityMax;
  int lightOnMinutes;
  int lightOffMinutes;
  LightOverrideMode overrideMode;
  String notificationNumber;

  ThresholdSettingsData({
    required this.pm25Max,
    required this.tempMin,
    required this.tempMax,
    required this.humidityMin,
    required this.humidityMax,
    required this.lightOnMinutes,
    required this.lightOffMinutes,
    required this.overrideMode,
    required this.notificationNumber,
  });
}

class CleanroomDevice {
  final String deviceId;
  final String deviceName;
  final String espUsername;
  final String espPassword;

  CleanroomDevice({
    required this.deviceId,
    required this.deviceName,
    required this.espUsername,
    required this.espPassword,
  });
}

class CleanroomRoom {
  final String roomId;
  String roomName;
  final List<CleanroomDevice> devices;
  String? selectedDeviceId;

  CleanroomRoom({
    required this.roomId,
    required this.roomName,
    required this.devices,
    this.selectedDeviceId,
  });
}

class MockSensorService extends ChangeNotifier {
  MockSensorService._internal() {
    _rooms.addAll([
      CleanroomRoom(
        roomId: 'room1',
        roomName: 'Room 1',
        selectedDeviceId: 'deviceid1',
        devices: [
          CleanroomDevice(
            deviceId: 'deviceid1',
            deviceName: 'ESP32 Cleanroom Main',
            espUsername: 'room1_admin',
            espPassword: 'room1_password',
          ),
        ],
      ),
      CleanroomRoom(
        roomId: 'room2',
        roomName: 'Room 2',
        selectedDeviceId: 'deviceid2',
        devices: [
          CleanroomDevice(
            deviceId: 'deviceid2',
            deviceName: 'ESP32 Room 2 Node',
            espUsername: 'room2_admin',
            espPassword: 'room2_password',
          ),
        ],
      ),
    ]);

    _selectedRoomId = 'room1';

    _currentReading = SensorReading(
      pm25: 18.0,
      temperature: 22.0,
      humidity: 45.0,
      luminance: 8200.0,
      timestamp: DateTime.now(),
      online: true,
    );

    _history.insert(0, _currentReading);

    _alerts.insert(
      0,
      AlertItem(
        title: 'System Started',
        message: 'Mock live monitoring is now running.',
        timestamp: DateTime.now(),
        isWarning: false,
      ),
    );

    _startSimulation();
  }

  static final MockSensorService instance = MockSensorService._internal();

  final Random _random = Random();
  Timer? _timer;

  late SensorReading _currentReading;
  final List<SensorReading> _history = [];
  final List<AlertItem> _alerts = [];

  final List<CleanroomRoom> _rooms = [];
  String _selectedRoomId = 'room1';

  final ThresholdSettingsData _thresholds = ThresholdSettingsData(
    pm25Max: 35,
    tempMin: 20,
    tempMax: 24,
    humidityMin: 40,
    humidityMax: 60,
    lightOnMinutes: 12,
    lightOffMinutes: 6,
    overrideMode: LightOverrideMode.auto,
    notificationNumber: '09123456789',
  );

  DateTime _lightCycleStartedAt = DateTime.now();
  bool _autoLightOn = true;

  SensorReading get currentReading => _currentReading;
  List<SensorReading> get history => List.unmodifiable(_history);
  List<AlertItem> get alerts => List.unmodifiable(_alerts);
  ThresholdSettingsData get thresholds => _thresholds;
  List<CleanroomRoom> get rooms => List.unmodifiable(_rooms);

  CleanroomRoom get selectedRoom {
    return _rooms.firstWhere(
      (room) => room.roomId == _selectedRoomId,
      orElse: () => _rooms.first,
    );
  }

  CleanroomDevice? get selectedDevice {
    final room = selectedRoom;

    if (room.devices.isEmpty) return null;

    return room.devices.firstWhere(
      (device) => device.deviceId == room.selectedDeviceId,
      orElse: () => room.devices.first,
    );
  }

  String get selectedRoomId => selectedRoom.roomId;
  String get selectedRoomName => selectedRoom.roomName;
  String get selectedDeviceId => selectedDevice?.deviceId ?? 'No Device';

  bool get isLightOn {
    switch (_thresholds.overrideMode) {
      case LightOverrideMode.forceOn:
        return true;
      case LightOverrideMode.forceOff:
        return false;
      case LightOverrideMode.auto:
        return _autoLightOn;
    }
  }

  String get lightStatusText {
    if (_thresholds.overrideMode == LightOverrideMode.forceOn) {
      return 'FORCED ON';
    }

    if (_thresholds.overrideMode == LightOverrideMode.forceOff) {
      return 'FORCED OFF';
    }

    return isLightOn ? 'AUTO ON' : 'AUTO OFF';
  }

  String get overrideModeText {
    switch (_thresholds.overrideMode) {
      case LightOverrideMode.auto:
        return 'Auto';
      case LightOverrideMode.forceOn:
        return 'Force ON';
      case LightOverrideMode.forceOff:
        return 'Force OFF';
    }
  }

  int get currentPhaseMinutes {
    final diff = DateTime.now().difference(_lightCycleStartedAt).inMinutes;
    return diff < 0 ? 0 : diff;
  }

  int get currentPhaseDurationMinutes {
    return _autoLightOn
        ? _thresholds.lightOnMinutes
        : _thresholds.lightOffMinutes;
  }

  int get minutesRemainingInLightCycle {
    if (_thresholds.overrideMode != LightOverrideMode.auto) return 0;

    final remaining = currentPhaseDurationMinutes - currentPhaseMinutes;
    return remaining < 0 ? 0 : remaining;
  }

  void selectRoom(String roomId) {
    _selectedRoomId = roomId;

    _addAlert(
      title: 'Room Changed',
      message: 'Now viewing data from ${selectedRoom.roomName}.',
      isWarning: false,
    );

    notifyListeners();
  }

  void selectDevice(String deviceId) {
    final room = selectedRoom;
    room.selectedDeviceId = deviceId;

    _addAlert(
      title: 'Device Changed',
      message: 'Now viewing data from device $deviceId.',
      isWarning: false,
    );

    notifyListeners();
  }

  void addRoom(String roomName) {
    final cleanName = roomName.trim();
    if (cleanName.isEmpty) return;

    final newRoomNumber = _rooms.length + 1;
    final roomId = 'room$newRoomNumber';

    _rooms.add(
      CleanroomRoom(
        roomId: roomId,
        roomName: cleanName,
        devices: [],
      ),
    );

    _selectedRoomId = roomId;

    _addAlert(
      title: 'Room Added',
      message: '$cleanName has been added to this account.',
      isWarning: false,
    );

    notifyListeners();
  }

  void deleteSelectedRoom() {
    if (_rooms.length <= 1) return;

    final removedRoomName = selectedRoom.roomName;
    _rooms.removeWhere((room) => room.roomId == _selectedRoomId);
    _selectedRoomId = _rooms.first.roomId;

    _addAlert(
      title: 'Room Deleted',
      message: '$removedRoomName was removed from the account.',
      isWarning: true,
    );

    notifyListeners();
  }

  void addDeviceToSelectedRoom({
    required String deviceId,
    required String deviceName,
    required String username,
    required String password,
  }) {
    final cleanDeviceId = deviceId.trim();
    final cleanDeviceName = deviceName.trim();
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();

    if (cleanDeviceId.isEmpty ||
        cleanDeviceName.isEmpty ||
        cleanUsername.isEmpty ||
        cleanPassword.isEmpty) {
      return;
    }

    final room = selectedRoom;

    room.devices.add(
      CleanroomDevice(
        deviceId: cleanDeviceId,
        deviceName: cleanDeviceName,
        espUsername: cleanUsername,
        espPassword: cleanPassword,
      ),
    );

    room.selectedDeviceId = cleanDeviceId;

    _addAlert(
      title: 'Device Added',
      message: '$cleanDeviceName has been added to ${room.roomName}.',
      isWarning: false,
    );

    notifyListeners();
  }

  void deleteSelectedDevice() {
    final room = selectedRoom;
    final device = selectedDevice;

    if (device == null) return;

    room.devices.removeWhere((d) => d.deviceId == device.deviceId);
    room.selectedDeviceId =
        room.devices.isNotEmpty ? room.devices.first.deviceId : null;

    _addAlert(
      title: 'Device Deleted',
      message: '${device.deviceName} was removed from ${room.roomName}.',
      isWarning: true,
    );

    notifyListeners();
  }

  void updateThresholdSettings({
    required double pm25Max,
    required double tempMin,
    required double tempMax,
    required double humidityMin,
    required double humidityMax,
    required int lightOnMinutes,
    required int lightOffMinutes,
  }) {
    _thresholds.pm25Max = pm25Max;
    _thresholds.tempMin = tempMin;
    _thresholds.tempMax = tempMax;
    _thresholds.humidityMin = humidityMin;
    _thresholds.humidityMax = humidityMax;
    _thresholds.lightOnMinutes = lightOnMinutes;
    _thresholds.lightOffMinutes = lightOffMinutes;

    notifyListeners();
  }

  void updateNotificationNumber(String number) {
    _thresholds.notificationNumber = number.trim();

    _addAlert(
      title: 'Notification Number Updated',
      message:
          'Alert receiver number changed to ${_thresholds.notificationNumber}.',
      isWarning: false,
    );

    notifyListeners();
  }

  void setLightOverride(LightOverrideMode mode) {
    final oldText = overrideModeText;
    _thresholds.overrideMode = mode;

    if (mode == LightOverrideMode.auto) {
      _lightCycleStartedAt = DateTime.now();
    }

    _addAlert(
      title: 'Light Override Updated',
      message: 'Lighting mode changed from $oldText to $overrideModeText.',
      isWarning: false,
    );

    notifyListeners();
  }

  void _startSimulation() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _generateNextReading();
    });
  }

  void _updateLightCycle() {
    if (_thresholds.overrideMode != LightOverrideMode.auto) return;

    final elapsedMinutes = currentPhaseMinutes;
    final phaseDuration = _autoLightOn
        ? _thresholds.lightOnMinutes
        : _thresholds.lightOffMinutes;

    if (elapsedMinutes >= phaseDuration) {
      _autoLightOn = !_autoLightOn;
      _lightCycleStartedAt = DateTime.now();

      _addAlert(
        title: _autoLightOn ? 'Lights Turned ON' : 'Lights Turned OFF',
        message: _autoLightOn
            ? 'Automatic luminance schedule switched the lights ON.'
            : 'Automatic luminance schedule switched the lights OFF.',
        isWarning: false,
      );
    }
  }

  void _generateNextReading() {
    _updateLightCycle();

    final double nextPm25 = _generateValue(_currentReading.pm25, 10, 45, 4.0);
    final double nextTemp =
        _generateValue(_currentReading.temperature, 19, 26, 0.7);
    final double nextHumidity =
        _generateValue(_currentReading.humidity, 35, 65, 2.0);

    final bool lightOn = isLightOn;
    final double nextLuminance = lightOn
        ? _generateValue(_currentReading.luminance, 7000, 12000, 900)
        : _generateValue(_currentReading.luminance, 200, 2500, 400);

    final bool online =
        selectedDevice == null ? false : _random.nextInt(100) > 3;

    _currentReading = SensorReading(
      pm25: double.parse(nextPm25.toStringAsFixed(1)),
      temperature: double.parse(nextTemp.toStringAsFixed(1)),
      humidity: double.parse(nextHumidity.toStringAsFixed(1)),
      luminance: double.parse(nextLuminance.toStringAsFixed(0)),
      timestamp: DateTime.now(),
      online: online,
    );

    _history.insert(0, _currentReading);

    if (_history.length > 40) {
      _history.removeLast();
    }

    _evaluateAlerts(_currentReading);
    notifyListeners();
  }

  double _generateValue(double current, double min, double max, double step) {
    final double delta = (_random.nextDouble() * step * 2) - step;
    double next = current + delta;

    if (_random.nextInt(10) == 0) {
      next += (_random.nextBool() ? 1 : -1) * step * 1.8;
    }

    if (next < min) next = min;
    if (next > max) next = max;

    return next;
  }

  void _evaluateAlerts(SensorReading reading) {
    if (!reading.online) {
      _addAlert(
        title: 'Device Offline',
        message:
            'The selected ESP32 device is temporarily disconnected or unavailable.',
        isWarning: true,
      );
      return;
    }

    if (reading.pm25 > _thresholds.pm25Max) {
      _addAlert(
        title: 'PM2.5 Critical',
        message:
            'PM2.5 reached ${reading.pm25} µg/m³ and exceeded the safe threshold. Alert receiver: ${_thresholds.notificationNumber}.',
        isWarning: true,
      );
    } else if (reading.pm25 >= (_thresholds.pm25Max - 10)) {
      _addAlert(
        title: 'PM2.5 Warning',
        message:
            'PM2.5 is rising at ${reading.pm25} µg/m³. Alert receiver: ${_thresholds.notificationNumber}.',
        isWarning: true,
      );
    }

    if (reading.temperature < _thresholds.tempMin ||
        reading.temperature > _thresholds.tempMax) {
      _addAlert(
        title: 'Temperature Alert',
        message:
            'Temperature is ${reading.temperature}°C and outside the safe range. Alert receiver: ${_thresholds.notificationNumber}.',
        isWarning: true,
      );
    }

    if (reading.humidity < _thresholds.humidityMin ||
        reading.humidity > _thresholds.humidityMax) {
      _addAlert(
        title: 'Humidity Alert',
        message:
            'Humidity is ${reading.humidity}% and outside the safe range. Alert receiver: ${_thresholds.notificationNumber}.',
        isWarning: true,
      );
    }

    if (reading.status == 'SAFE') {
      _addAlert(
        title: 'System Stable',
        message: 'All environmental parameters are within safe thresholds.',
        isWarning: false,
      );
    }
  }

  void _addAlert({
    required String title,
    required String message,
    required bool isWarning,
  }) {
    if (_alerts.isNotEmpty) {
      final latest = _alerts.first;
      final sameTitle = latest.title == title;
      final secondsGap = DateTime.now().difference(latest.timestamp).inSeconds;

      if (sameTitle && secondsGap < 5) return;
    }

    _alerts.insert(
      0,
      AlertItem(
        title: title,
        message: message,
        timestamp: DateTime.now(),
        isWarning: isWarning,
      ),
    );

    if (_alerts.length > 30) {
      _alerts.removeLast();
    }
  }

  String formatTime(DateTime dateTime) {
    final int hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);

    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  Color statusColor(String status) {
    switch (status) {
      case 'SAFE':
        return const Color(0xFF2F9E44);
      case 'WARNING':
        return Colors.orange;
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
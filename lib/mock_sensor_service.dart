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
    final bool critical = pm25 > 35 ||
        temperature < 20 ||
        temperature > 24 ||
        humidity < 40 ||
        humidity > 60;

    final bool warning = (pm25 >= 25 && pm25 <= 35) ||
        (temperature >= 20 && temperature <= 20.5) ||
        (temperature >= 23.5 && temperature <= 24) ||
        (humidity >= 40 && humidity <= 42) ||
        (humidity >= 58 && humidity <= 60);

    if (!online) return 'OFFLINE';
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

class MockSensorService extends ChangeNotifier {
  MockSensorService._internal() {
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

  SensorReading get currentReading => _currentReading;
  List<SensorReading> get history => List.unmodifiable(_history);
  List<AlertItem> get alerts => List.unmodifiable(_alerts);

  void _startSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _generateNextReading();
    });
  }

  void _generateNextReading() {
    final double nextPm25 = _generateValue(_currentReading.pm25, 10, 45, 4.0);
    final double nextTemp =
        _generateValue(_currentReading.temperature, 19, 26, 0.7);
    final double nextHumidity =
        _generateValue(_currentReading.humidity, 35, 65, 2.0);
    final double nextLuminance =
        _generateValue(_currentReading.luminance, 3000, 12000, 850);

    final bool online = _random.nextInt(100) > 3;

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
        message: 'The cleanroom device is temporarily disconnected.',
        isWarning: true,
      );
      return;
    }

    if (reading.pm25 > 35) {
      _addAlert(
        title: 'PM2.5 Critical',
        message:
            'PM2.5 reached ${reading.pm25} µg/m³ and exceeded the safe threshold.',
        isWarning: true,
      );
    } else if (reading.pm25 >= 25) {
      _addAlert(
        title: 'PM2.5 Warning',
        message: 'PM2.5 is rising at ${reading.pm25} µg/m³.',
        isWarning: true,
      );
    }

    if (reading.temperature < 20 || reading.temperature > 24) {
      _addAlert(
        title: 'Temperature Alert',
        message:
            'Temperature is ${reading.temperature}°C and outside the safe range.',
        isWarning: true,
      );
    }

    if (reading.humidity < 40 || reading.humidity > 60) {
      _addAlert(
        title: 'Humidity Alert',
        message:
            'Humidity is ${reading.humidity}% and outside the safe range.',
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
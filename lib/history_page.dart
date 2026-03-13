import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryFilter selectedFilter = HistoryFilter.daily;

  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 390;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final filteredHistory = _filterHistory(service.history);

        return Scaffold(
          backgroundColor: softBg,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isSmallScreen ? 16 : 18,
                    12,
                    isSmallScreen ? 16 : 18,
                    0,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool stackHeader = constraints.maxWidth < 380;

                      if (stackHeader) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'History',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Daily, weekly, monthly, yearly records',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _countPill(filteredHistory.length),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'History',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Daily, weekly, monthly, yearly records',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          _countPill(filteredHistory.length),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 18,
                  ),
                  child: _filterTabs(),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: filteredHistory.isEmpty
                      ? const Center(
                          child: Text(
                            'No readings available for this period.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            isSmallScreen ? 16 : 18,
                            0,
                            isSmallScreen ? 16 : 18,
                            18,
                          ),
                          itemCount: filteredHistory.length,
                          itemBuilder: (context, index) {
                            final item = filteredHistory[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HistoryCard(
                                time: _formatDateTime(item.timestamp),
                                pm25: '${item.pm25.toStringAsFixed(1)} µg/m³',
                                temp:
                                    '${item.temperature.toStringAsFixed(1)}°C',
                                humidity:
                                    '${item.humidity.toStringAsFixed(1)}%',
                                status: item.status,
                                isSmallScreen: isSmallScreen,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _countPill(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '$count items',
        style: const TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  List<SensorReading> _filterHistory(List<SensorReading> history) {
    final now = DateTime.now();

    return history.where((item) {
      final difference = now.difference(item.timestamp);

      switch (selectedFilter) {
        case HistoryFilter.daily:
          return difference.inDays < 1;
        case HistoryFilter.weekly:
          return difference.inDays < 7;
        case HistoryFilter.monthly:
          return difference.inDays < 30;
        case HistoryFilter.yearly:
          return difference.inDays < 365;
      }
    }).toList();
  }

  Widget _filterTabs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wrapTabs = constraints.maxWidth < 360;

        if (wrapTabs) {
          return Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _filterButton('Daily', HistoryFilter.daily)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: _filterButton('Weekly', HistoryFilter.weekly)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                        child: _filterButton('Monthly', HistoryFilter.monthly)),
                    const SizedBox(width: 6),
                    Expanded(child: _filterButton('Yearly', HistoryFilter.yearly)),
                  ],
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              _filterButton('Daily', HistoryFilter.daily),
              _filterButton('Weekly', HistoryFilter.weekly),
              _filterButton('Monthly', HistoryFilter.monthly),
              _filterButton('Yearly', HistoryFilter.yearly),
            ],
          ),
        );
      },
    );
  }

  Widget _filterButton(String label, HistoryFilter filter) {
    final isSelected = selectedFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = filter;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    final month = _monthName(dateTime.month);
    final day = dateTime.day;
    final year = dateTime.year;

    return '$month $day, $year • $hour:$minute $period';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}

enum HistoryFilter {
  daily,
  weekly,
  monthly,
  yearly,
}

class _HistoryCard extends StatelessWidget {
  final String time;
  final String pm25;
  final String temp;
  final String humidity;
  final String status;
  final bool isSmallScreen;

  const _HistoryCard({
    required this.time,
    required this.pm25,
    required this.temp,
    required this.humidity,
    required this.status,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'SAFE':
        statusColor = const Color(0xFF2F9E44);
        break;
      case 'WARNING':
        statusColor = Colors.orange;
        break;
      case 'CRITICAL':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool stackStatus = constraints.maxWidth < 250;
          final bool stackBoxes = constraints.maxWidth < 330;

          return Column(
            children: [
              if (stackStatus) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    time,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        time,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              if (stackBoxes) ...[
                Row(
                  children: [
                    Expanded(child: _miniBox('PM2.5', pm25)),
                    const SizedBox(width: 10),
                    Expanded(child: _miniBox('Temp', temp)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _miniBox('Humidity', humidity)),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: _miniBox('PM2.5', pm25)),
                    const SizedBox(width: 10),
                    Expanded(child: _miniBox('Temp', temp)),
                    const SizedBox(width: 10),
                    Expanded(child: _miniBox('Humidity', humidity)),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _miniBox(String title, String value) {
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
}
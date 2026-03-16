import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'mock_sensor_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryFilter selectedFilter = HistoryFilter.daily;
  HistoryMetric selectedMetric = HistoryMetric.temperature;

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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
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
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 18,
                    ),
                    child: _filterTabs(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 18,
                    ),
                    child: _metricTabs(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 18,
                    ),
                    child: _chartCard(filteredHistory),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                if (filteredHistory.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No readings available for this period.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      isSmallScreen ? 16 : 18,
                      0,
                      isSmallScreen ? 16 : 18,
                      28,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                              luminance:
                                  '${item.luminance.toStringAsFixed(0)} lux',
                              status: item.status,
                              isSmallScreen: isSmallScreen,
                            ),
                          );
                        },
                        childCount: filteredHistory.length,
                      ),
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
                      child: _filterButton('Weekly', HistoryFilter.weekly),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _filterButton('Monthly', HistoryFilter.monthly),
                    ),
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

  Widget _metricTabs() {
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wrap = constraints.maxWidth < 360;
          if (wrap) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _metricButton('Temp', HistoryMetric.temperature),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _metricButton('Humidity', HistoryMetric.humidity),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: _metricButton('PM2.5', HistoryMetric.pm25)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _metricButton('Lux', HistoryMetric.luminance),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              _metricButton('Temp', HistoryMetric.temperature),
              _metricButton('Humidity', HistoryMetric.humidity),
              _metricButton('PM2.5', HistoryMetric.pm25),
              _metricButton('Lux', HistoryMetric.luminance),
            ],
          );
        },
      ),
    );
  }

  Widget _metricButton(String label, HistoryMetric metric) {
    final isSelected = selectedMetric == metric;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMetric = metric;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEAF6EC) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected ? primaryGreen : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chartCard(List<SensorReading> history) {
    final color = _metricColor();
    final data = history.reversed.toList();

    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), _metricValue(data[i])));
    }

    final double minY;
    final double maxY;

    if (spots.isEmpty) {
      minY = 0;
      maxY = 10;
    } else {
      final values = spots.map((e) => e.y).toList();
      final minVal = values.reduce((a, b) => a < b ? a : b);
      final maxVal = values.reduce((a, b) => a > b ? a : b);
      final padding = ((maxVal - minVal).abs() * 0.2).clamp(1.0, 1000.0);
      minY = minVal - padding;
      maxY = maxVal + padding;
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
            '${_metricTitle()} Trend',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _metricSubtitle(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: spots.isEmpty
                ? const Center(
                    child: Text(
                      'No chart data available.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: (maxY - minY) / 4,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.black.withValues(alpha: 0.06),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black45,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            interval: spots.length > 6
                                ? (spots.length / 4).ceilToDouble()
                                : 1,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black45,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => Colors.black87,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toStringAsFixed(1)} ${_metricUnit()}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          dotData: FlDotData(show: spots.length < 12),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _metricValue(SensorReading reading) {
    switch (selectedMetric) {
      case HistoryMetric.temperature:
        return reading.temperature;
      case HistoryMetric.humidity:
        return reading.humidity;
      case HistoryMetric.pm25:
        return reading.pm25;
      case HistoryMetric.luminance:
        return reading.luminance;
    }
  }

  String _metricTitle() {
    switch (selectedMetric) {
      case HistoryMetric.temperature:
        return 'Temperature';
      case HistoryMetric.humidity:
        return 'Humidity';
      case HistoryMetric.pm25:
        return 'PM2.5';
      case HistoryMetric.luminance:
        return 'Luminance';
    }
  }

  String _metricSubtitle() {
    switch (selectedMetric) {
      case HistoryMetric.temperature:
        return 'Temperature changes over the selected period';
      case HistoryMetric.humidity:
        return 'Humidity changes over the selected period';
      case HistoryMetric.pm25:
        return 'Particle concentration changes over the selected period';
      case HistoryMetric.luminance:
        return 'Light intensity changes over the selected period';
    }
  }

  String _metricUnit() {
    switch (selectedMetric) {
      case HistoryMetric.temperature:
        return '°C';
      case HistoryMetric.humidity:
        return '%';
      case HistoryMetric.pm25:
        return 'µg/m³';
      case HistoryMetric.luminance:
        return 'lux';
    }
  }

  Color _metricColor() {
    switch (selectedMetric) {
      case HistoryMetric.temperature:
        return const Color(0xFF2F9E44);
      case HistoryMetric.humidity:
        return const Color(0xFFFF7A59);
      case HistoryMetric.pm25:
        return const Color(0xFF22B8CF);
      case HistoryMetric.luminance:
        return const Color(0xFFF59F00);
    }
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

enum HistoryMetric {
  temperature,
  humidity,
  pm25,
  luminance,
}

class _HistoryCard extends StatelessWidget {
  final String time;
  final String pm25;
  final String temp;
  final String humidity;
  final String luminance;
  final String status;
  final bool isSmallScreen;

  const _HistoryCard({
    required this.time,
    required this.pm25,
    required this.temp,
    required this.humidity,
    required this.luminance,
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
                    const SizedBox(width: 10),
                    Expanded(child: _miniBox('Lux', luminance)),
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
                    const SizedBox(width: 10),
                    Expanded(child: _miniBox('Lux', luminance)),
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
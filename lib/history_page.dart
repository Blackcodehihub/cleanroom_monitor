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

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final filteredHistory = _filterHistory(service.history);
        final recentLogs = filteredHistory.take(5).toList();

        return Scaffold(
          backgroundColor: softBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                _pageHeader(filteredHistory.length),
                const SizedBox(height: 16),
                _sectionLabel(
                  title: 'Time Range',
                  subtitle: 'Controls chart, summary, and logs',
                ),
                const SizedBox(height: 10),
                _filterTabs(),
                const SizedBox(height: 16),
                _sectionLabel(
                  title: 'Chart Metric',
                  subtitle: 'Controls the trend chart only',
                ),
                const SizedBox(height: 10),
                _metricTabs(),
                const SizedBox(height: 16),
                _chartCard(filteredHistory),
                const SizedBox(height: 16),
                _logSummaryCard(filteredHistory),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Recent Data Logs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: filteredHistory.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AllLogsPage(
                                    logs: filteredHistory,
                                  ),
                                ),
                              );
                            },
                      child: const Text(
                        'View All',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (recentLogs.isEmpty)
                  _emptyCard()
                else
                  ...recentLogs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CompactLogCard(
                        logId:
                            'LOG-${(filteredHistory.length - index).toString().padLeft(3, '0')}',
                        timestamp: _formatShortDateTime(item.timestamp),
                        status: item.status,
                        pm25: '${item.pm25.toStringAsFixed(1)} µg/m³',
                        temp: '${item.temperature.toStringAsFixed(1)}°C',
                        humidity: '${item.humidity.toStringAsFixed(1)}%',
                        luminance: '${item.luminance.toStringAsFixed(0)} lux',
                        remark: _buildRemark(item),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pageHeader(int count) {
    return Row(
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
                'Review sensor trends and recent records',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            '$count logs',
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

  Widget _sectionLabel({
    required String title,
    required String subtitle,
  }) {
    return Column(
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
      ],
    );
  }

  Widget _filterTabs() {
    return _tabContainer(
      children: [
        _filterButton('Daily', HistoryFilter.daily),
        _filterButton('Weekly', HistoryFilter.weekly),
        _filterButton('Monthly', HistoryFilter.monthly),
        _filterButton('Yearly', HistoryFilter.yearly),
      ],
    );
  }

  Widget _metricTabs() {
    return _tabContainer(
      children: [
        _metricButton('Temp', HistoryMetric.temperature),
        _metricButton('Humidity', HistoryMetric.humidity),
        _metricButton('PM2.5', HistoryMetric.pm25),
        _metricButton('Lux', HistoryMetric.luminance),
      ],
    );
  }

  Widget _tabContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: children),
    );
  }

  Widget _filterButton(String label, HistoryFilter filter) {
    final selected = selectedFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: selected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricButton(String label, HistoryMetric metric) {
    final selected = selectedMetric == metric;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedMetric = metric),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF6EC) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: selected ? primaryGreen : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chartCard(List<SensorReading> history) {
    final data = history.reversed.toList();
    final spots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), _metricValue(data[i])));
    }

    double minY = 0;
    double maxY = 10;

    if (spots.isNotEmpty) {
      final values = spots.map((e) => e.y).toList();
      final minVal = values.reduce((a, b) => a < b ? a : b);
      final maxVal = values.reduce((a, b) => a > b ? a : b);
      final range = (maxVal - minVal).abs();
      final padding = range == 0 ? _defaultChartPadding() : range * 0.22;

      minY = minVal - padding;
      maxY = maxVal + padding;

      if (selectedMetric == HistoryMetric.temperature) {
        minY = minY.floorToDouble();
        maxY = maxY.ceilToDouble();
      } else if (selectedMetric == HistoryMetric.humidity) {
        minY = minY.floorToDouble();
        maxY = maxY.ceilToDouble();
      } else if (selectedMetric == HistoryMetric.pm25) {
        minY = minY.floorToDouble();
        maxY = maxY.ceilToDouble();
      } else if (selectedMetric == HistoryMetric.luminance) {
        minY = (minY / 1000).floor() * 1000;
        maxY = (maxY / 1000).ceil() * 1000;
      }

      if (minY == maxY) {
        minY -= _defaultChartPadding();
        maxY += _defaultChartPadding();
      }
    }

    final interval = _chartInterval(minY, maxY);

    return Container(
      height: 265,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_metricTitle()} Trend',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Visual overview for selected time range',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: spots.isEmpty
                ? const Center(
                    child: Text(
                      'No chart data available.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      minX: spots.first.x,
                      maxX: spots.last.x,
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.black.withValues(alpha: 0.07),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize:
                                selectedMetric == HistoryMetric.luminance
                                    ? 54
                                    : 42,
                            interval: interval,
                            getTitlesWidget: (value, meta) {
                              final isBottomEdge =
                                  (value - minY).abs() < interval * 0.35;
                              final isTopEdge =
                                  (value - maxY).abs() < interval * 0.35;

                              if (isBottomEdge || isTopEdge) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  _formatChartLabel(value),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 12,
                          getTooltipItems: (items) {
                            return items.map((item) {
                              return LineTooltipItem(
                                _formatTooltipValue(item.y),
                                TextStyle(
                                  color: _metricColor(),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
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
                          curveSmoothness: 0.30,
                          color: _metricColor(),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: spots.length <= 8),
                          belowBarData: BarAreaData(
                            show: true,
                            color: _metricColor().withValues(alpha: 0.13),
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

  double _defaultChartPadding() {
    switch (selectedMetric) {
      case HistoryMetric.temperature:
        return 1.0;
      case HistoryMetric.humidity:
        return 3.0;
      case HistoryMetric.pm25:
        return 5.0;
      case HistoryMetric.luminance:
        return 1000.0;
    }
  }

  double _chartInterval(double minY, double maxY) {
    final range = (maxY - minY).abs();

    switch (selectedMetric) {
      case HistoryMetric.temperature:
        return range <= 4 ? 1 : 2;
      case HistoryMetric.humidity:
        return range <= 10 ? 2 : 5;
      case HistoryMetric.pm25:
        return range <= 20 ? 5 : 10;
      case HistoryMetric.luminance:
        return range <= 4000 ? 1000 : 2000;
    }
  }

  String _formatChartLabel(double value) {
    switch (selectedMetric) {
      case HistoryMetric.temperature:
      case HistoryMetric.humidity:
        return _cleanNumber(value, decimals: 1);
      case HistoryMetric.pm25:
        return _cleanNumber(value, decimals: 0);
      case HistoryMetric.luminance:
        if (value.abs() >= 1000) {
          return '${_cleanNumber(value / 1000, decimals: 1)}K';
        }
        return _cleanNumber(value, decimals: 0);
    }
  }

  String _cleanNumber(double value, {required int decimals}) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.001) {
      return rounded.toInt().toString();
    }
    return value.toStringAsFixed(decimals);
  }

  String _formatTooltipValue(double value) {
    switch (selectedMetric) {
      case HistoryMetric.temperature:
        return '${value.toStringAsFixed(1)}°C';
      case HistoryMetric.humidity:
        return '${value.toStringAsFixed(1)}%';
      case HistoryMetric.pm25:
        return '${value.toStringAsFixed(1)} µg/m³';
      case HistoryMetric.luminance:
        return '${value.toStringAsFixed(0)} lux';
    }
  }

  Widget _logSummaryCard(List<SensorReading> history) {
    final safe = history.where((e) => e.status == 'SAFE').length;
    final warning = history.where((e) => e.status == 'WARNING').length;
    final critical = history.where((e) => e.status == 'CRITICAL').length;
    final offline = history.where((e) => e.status == 'OFFLINE').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Log Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryChip('Safe', safe, primaryGreen),
              _summaryChip('Warn', warning, Colors.orange),
              _summaryChip('Crit', critical, Colors.red),
              _summaryChip('Off', offline, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: const Center(
        child: Text(
          'No logs available for this period.',
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  List<SensorReading> _filterHistory(List<SensorReading> history) {
    final now = DateTime.now();

    return history.where((item) {
      final diff = now.difference(item.timestamp);
      switch (selectedFilter) {
        case HistoryFilter.daily:
          return diff.inDays < 1;
        case HistoryFilter.weekly:
          return diff.inDays < 7;
        case HistoryFilter.monthly:
          return diff.inDays < 30;
        case HistoryFilter.yearly:
          return diff.inDays < 365;
      }
    }).toList();
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

  Color _metricColor() {
    switch (selectedMetric) {
      case HistoryMetric.temperature:
        return primaryGreen;
      case HistoryMetric.humidity:
        return const Color(0xFFFF922B);
      case HistoryMetric.pm25:
        return const Color(0xFF22B8CF);
      case HistoryMetric.luminance:
        return const Color(0xFFF59F00);
    }
  }

  String _formatShortDateTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _buildRemark(SensorReading reading) {
    if (!reading.online) return 'Device offline';
    if (reading.status == 'CRITICAL') return 'Exceeded threshold';
    if (reading.status == 'WARNING') return 'Monitor closely';
    return 'Within acceptable range';
  }
}

class AllLogsPage extends StatelessWidget {
  final List<SensorReading> logs;

  const AllLogsPage({
    super.key,
    required this.logs,
  });

  static const Color softBg = Color(0xFFF4F5F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: const Text(
          'All Data Logs',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final item = logs[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CompactLogCard(
              logId: 'LOG-${(logs.length - index).toString().padLeft(3, '0')}',
              timestamp: _formatTime(item.timestamp),
              status: item.status,
              pm25: '${item.pm25.toStringAsFixed(1)} µg/m³',
              temp: '${item.temperature.toStringAsFixed(1)}°C',
              humidity: '${item.humidity.toStringAsFixed(1)}%',
              luminance: '${item.luminance.toStringAsFixed(0)} lux',
              remark: _remark(item),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _remark(SensorReading reading) {
    if (!reading.online) return 'Device offline';
    if (reading.status == 'CRITICAL') return 'Exceeded threshold';
    if (reading.status == 'WARNING') return 'Monitor closely';
    return 'Within acceptable range';
  }
}

class _CompactLogCard extends StatelessWidget {
  final String logId;
  final String timestamp;
  final String status;
  final String pm25;
  final String temp;
  final String humidity;
  final String luminance;
  final String remark;

  const _CompactLogCard({
    required this.logId,
    required this.timestamp,
    required this.status,
    required this.pm25,
    required this.temp,
    required this.humidity,
    required this.luminance,
    required this.remark,
  });

  static const Color primaryGreen = Color(0xFF2F9E44);

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                logId,
                style: const TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                timestamp,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _miniValue('PM2.5', pm25)),
              Expanded(child: _miniValue('Temp', temp)),
              Expanded(child: _miniValue('Hum', humidity)),
              Expanded(child: _miniValue('Lux', luminance)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.notes_rounded, size: 14, color: Colors.black38),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  remark,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniValue(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black45,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            color: Colors.black87,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'SAFE':
        return primaryGreen;
      case 'WARNING':
        return Colors.orange;
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
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
  String selectedStatusFilter = 'ALL'; 

  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  @override
  Widget build(BuildContext context) {
    final service = MockSensorService.instance;

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final rawFilteredHistory = _filterHistory(service.history);
        final chartData = _aggregateData(rawFilteredHistory, selectedFilter);
        
        final listDisplayLogs = selectedStatusFilter == 'ALL'
            ? rawFilteredHistory
            : rawFilteredHistory.where((log) => log.status == selectedStatusFilter).toList();
            
        final recentLogs = listDisplayLogs.take(5).toList();

        return Scaffold(
          backgroundColor: softBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                _pageHeader(rawFilteredHistory.length),
                const SizedBox(height: 24),
                
                _sectionLabel(
                  title: 'Telemetry Range',
                  subtitle: 'Data polled automatically at 5-minute intervals',
                ),
                const SizedBox(height: 12),
                _filterTabs(),
                const SizedBox(height: 20),

                _sectionLabel(
                  title: 'Chart Metric',
                  subtitle: 'Select variable for trend analysis',
                ),
                const SizedBox(height: 12),
                _metricTabs(),
                const SizedBox(height: 20),
                
                _chartCard(chartData),
                const SizedBox(height: 16),
                _logSummaryCard(rawFilteredHistory),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedStatusFilter == 'ALL' 
                            ? 'Recent Data Logs' 
                            : 'Recent $selectedStatusFilter Logs',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (selectedStatusFilter != 'ALL')
                      TextButton(
                        onPressed: () => setState(() => selectedStatusFilter = 'ALL'),
                        child: const Text('Clear Filter'),
                      ),
                    TextButton(
                      onPressed: listDisplayLogs.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AllLogsPage(
                                    logs: listDisplayLogs,
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
                  ...recentLogs.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CompactLogCard(
                        logId: 'LOG-${(rawFilteredHistory.length - rawFilteredHistory.indexOf(item)).toString().padLeft(3, '0')}',
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

  List<SensorReading> _aggregateData(List<SensorReading> raw, HistoryFilter filter) {
    if (raw.isEmpty) return [];
    if (filter == HistoryFilter.daily) return raw; 

    Map<String, List<SensorReading>> grouped = {};
    for (var r in raw) {
      String key;
      if (filter == HistoryFilter.weekly || filter == HistoryFilter.monthly) {
        key = "${r.timestamp.year}-${r.timestamp.month}-${r.timestamp.day}"; 
      } else {
        key = "${r.timestamp.year}-${r.timestamp.month}"; 
      }
      grouped.putIfAbsent(key, () => []).add(r);
    }

    List<SensorReading> aggregated = [];
    grouped.forEach((key, list) {
      double avgTemp = list.map((e) => e.temperature).reduce((a, b) => a + b) / list.length;
      double avgHum = list.map((e) => e.humidity).reduce((a, b) => a + b) / list.length;
      double avgPm = list.map((e) => e.pm25).reduce((a, b) => a + b) / list.length;
      double avgLux = list.map((e) => e.luminance).reduce((a, b) => a + b) / list.length;

      aggregated.add(SensorReading(
        timestamp: list.last.timestamp, 
        temperature: avgTemp,
        humidity: avgHum,
        pm25: avgPm,
        luminance: avgLux,
        online: list.last.online, 
      ));
    });
    return aggregated;
  }

  Widget _pageHeader(int count) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alima ISO Console',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Historical Data & Trends',
                style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.wifi, size: 14, color: primaryGreen),
                  const SizedBox(width: 4),
                  const Icon(Icons.battery_charging_full_rounded, size: 14, color: primaryGreen),
                  const SizedBox(width: 6),
                  const Text(
                    'Active 5m Sync Cycle',
                    style: TextStyle(
                      fontSize: 12, 
                      color: primaryGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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

  Widget _sectionLabel({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _segmentedControlContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF), 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: children),
    );
  }

  Widget _filterTabs() {
    return _segmentedControlContainer(
      children: [
        _filterButton('Daily', HistoryFilter.daily),
        _filterButton('Weekly', HistoryFilter.weekly),
        _filterButton('Monthly', HistoryFilter.monthly),
        _filterButton('Yearly', HistoryFilter.yearly),
      ],
    );
  }

  Widget _metricTabs() {
    return _segmentedControlContainer(
      children: [
        _metricButton('Temp', HistoryMetric.temperature),
        _metricButton('Humidity', HistoryMetric.humidity),
        _metricButton('PM2.5', HistoryMetric.pm25),
        _metricButton('Lux', HistoryMetric.luminance),
      ],
    );
  }

  Widget _filterButton(String label, HistoryFilter filter) {
    final selected = selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
              color: selected ? primaryGreen : Colors.black54,
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
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

      if (selectedMetric == HistoryMetric.temperature || 
          selectedMetric == HistoryMetric.humidity || 
          selectedMetric == HistoryMetric.pm25) {
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
    
    double xInterval = 1;
    if (spots.isNotEmpty) {
      xInterval = (spots.length / 4).ceilToDouble();
      if (xInterval < 1) xInterval = 1;
    }

    return Container(
      height: 310, 
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
          const SizedBox(height: 20),
          Expanded(
            child: spots.isEmpty
                ? const Center(child: Text('No chart data available.'))
                : LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      minX: spots.isNotEmpty ? spots.first.x : 0,
                      maxX: spots.isNotEmpty ? spots.last.x : 0,
                      clipData: const FlClipData.all(),
                      
                      extraLinesData: _getSafeZoneLines(),
                      
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) => Colors.black87,
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final timestamp = _formatTooltipTime(data[spot.spotIndex].timestamp);
                              return LineTooltipItem(
                                '${_formatChartLabel(spot.y)} ${_metricUnit()}\n',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: timestamp,
                                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 10),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                      ),
                      
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.black.withValues(alpha: 0.05),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28, 
                            interval: xInterval,
                            getTitlesWidget: (value, meta) {
                              // FIXED: This line stops fl_chart from forcing the max label 
                              // and causing the labels to overlap at the end.
                              if (value % xInterval != 0) {
                                return const SizedBox.shrink();
                              }

                              final index = value.toInt();
                              if (index < 0 || index >= data.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _formatXAxisLabel(data[index].timestamp),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 10, 
                                    fontWeight: FontWeight.w700, 
                                    color: Colors.black45,
                                    height: 1.2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: selectedMetric == HistoryMetric.luminance ? 54 : 42,
                            interval: interval,
                            getTitlesWidget: (value, meta) {
                              if ((value - minY).abs() < interval * 0.35 || (value - maxY).abs() < interval * 0.35) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  _formatChartLabel(value),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.30,
                          color: _metricColor(),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: spots.length <= 8),
                          shadow: Shadow(
                            color: _metricColor().withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                _metricColor().withValues(alpha: 0.25),
                                _metricColor().withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
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

  ExtraLinesData _getSafeZoneLines() {
    double? maxSafe;
    double? minSafe;

    if (selectedMetric == HistoryMetric.temperature) { maxSafe = 25.0; minSafe = 18.0; }
    if (selectedMetric == HistoryMetric.humidity) { maxSafe = 55.0; minSafe = 30.0; }
    if (selectedMetric == HistoryMetric.pm25) { maxSafe = 35.0; }

    List<HorizontalLine> lines = [];
    if (maxSafe != null) {
      lines.add(HorizontalLine(
        y: maxSafe,
        color: Colors.redAccent.withValues(alpha: 0.5),
        strokeWidth: 1.5,
        dashArray: [6, 4],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 5, bottom: 4),
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.redAccent),
          labelResolver: (_) => 'MAX SAFE',
        ),
      ));
    }
    if (minSafe != null) {
      lines.add(HorizontalLine(
        y: minSafe,
        color: Colors.blueAccent.withValues(alpha: 0.5),
        strokeWidth: 1.5,
        dashArray: [6, 4],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.only(right: 5, top: 4),
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.blueAccent),
          labelResolver: (_) => 'MIN SAFE',
        ),
      ));
    }
    return ExtraLinesData(horizontalLines: lines);
  }

  // FIXED: Added minutes back so the Daily labels don't repeat the same hour
  String _formatXAxisLabel(DateTime dateTime) {
    if (selectedFilter == HistoryFilter.daily) {
      final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $amPm'; 
    } else if (selectedFilter == HistoryFilter.weekly) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else if (selectedFilter == HistoryFilter.monthly) {
      return '${dateTime.day}';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[dateTime.month - 1];
    }
  }

  String _formatTooltipTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    if (selectedFilter == HistoryFilter.yearly) {
      return '${months[dateTime.month - 1]} ${dateTime.year}';
    } else if (selectedFilter == HistoryFilter.monthly || selectedFilter == HistoryFilter.weekly) {
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    }
    return '${months[dateTime.month - 1]} ${dateTime.day}, $hour:$minute $period';
  }

  String _metricUnit() {
    switch (selectedMetric) {
      case HistoryMetric.temperature: return '°C';
      case HistoryMetric.humidity: return '%';
      case HistoryMetric.pm25: return 'µg/m³';
      case HistoryMetric.luminance: return 'lx';
    }
  }

  double _defaultChartPadding() {
    switch (selectedMetric) {
      case HistoryMetric.temperature: return 2.0;
      case HistoryMetric.humidity: return 5.0;
      case HistoryMetric.pm25: return 5.0;
      case HistoryMetric.luminance: return 1000.0;
    }
  }

  double _chartInterval(double minY, double maxY) {
    final range = (maxY - minY).abs();
    switch (selectedMetric) {
      case HistoryMetric.temperature: return range <= 6 ? 2 : 4;
      case HistoryMetric.humidity: return range <= 20 ? 5 : 10;
      case HistoryMetric.pm25: return range <= 20 ? 5 : 10;
      case HistoryMetric.luminance: return range <= 4000 ? 1000 : 2000;
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
        return value.abs() >= 1000 ? '${_cleanNumber(value / 1000, decimals: 1)}K' : _cleanNumber(value, decimals: 0);
    }
  }

  String _cleanNumber(double value, {required int decimals}) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.001) return rounded.toInt().toString();
    return value.toStringAsFixed(decimals);
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
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryChip('Safe', safe, primaryGreen, 'SAFE'),
              _summaryChip('Warn', warning, Colors.orange, 'WARNING'),
              _summaryChip('Crit', critical, Colors.red, 'CRITICAL'),
              _summaryChip('Off', offline, Colors.grey, 'OFFLINE'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int value, Color color, String statusKey) {
    final isSelected = selectedStatusFilter == statusKey;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStatusFilter = isSelected ? 'ALL' : statusKey;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isSelected ? 0.25 : 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                value.toString(),
                style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: const Center(
        child: Text('No logs available for this period.', style: TextStyle(color: Colors.black54)),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    );
  }

  List<SensorReading> _filterHistory(List<SensorReading> history) {
    final now = DateTime.now();
    return history.where((item) {
      final diff = now.difference(item.timestamp);
      switch (selectedFilter) {
        case HistoryFilter.daily: return diff.inDays < 1;
        case HistoryFilter.weekly: return diff.inDays < 7;
        case HistoryFilter.monthly: return diff.inDays < 30;
        case HistoryFilter.yearly: return diff.inDays < 365;
      }
    }).toList();
  }

  double _metricValue(SensorReading reading) {
    switch (selectedMetric) {
      case HistoryMetric.temperature: return reading.temperature;
      case HistoryMetric.humidity: return reading.humidity;
      case HistoryMetric.pm25: return reading.pm25;
      case HistoryMetric.luminance: return reading.luminance;
    }
  }

  String _metricTitle() {
    switch (selectedMetric) {
      case HistoryMetric.temperature: return 'Temperature';
      case HistoryMetric.humidity: return 'Humidity';
      case HistoryMetric.pm25: return 'PM2.5';
      case HistoryMetric.luminance: return 'Luminance';
    }
  }

  Color _metricColor() {
    switch (selectedMetric) {
      case HistoryMetric.temperature: return primaryGreen;
      case HistoryMetric.humidity: return const Color(0xFFFF922B);
      case HistoryMetric.pm25: return const Color(0xFF22B8CF);
      case HistoryMetric.luminance: return const Color(0xFFF59F00);
    }
  }

  String _formatShortDateTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
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
  const AllLogsPage({super.key, required this.logs});

  static const Color softBg = Color(0xFFF4F5F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: const Text('All Data Logs', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.035), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(logId, style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w900, fontSize: 12)),
              const Spacer(),
              Text(timestamp, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(14)),
                child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10)),
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
                  style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w700),
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
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: Colors.black87, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'SAFE': return primaryGreen;
      case 'WARNING': return Colors.orange;
      case 'CRITICAL': return Colors.red;
      default: return Colors.grey;
    }
  }
}

enum HistoryFilter { daily, weekly, monthly, yearly }
enum HistoryMetric { temperature, humidity, pm25, luminance }
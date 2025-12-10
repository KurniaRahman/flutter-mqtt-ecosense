import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../models/sensor_data.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text("Jurnal Tanaman", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: history.isEmpty
          ? const Center(child: Text("Menunggu data masuk..."))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _ChartCard("Suhu Udara", history, (d) => d.suhuUdara, Colors.red, "°C"),
                _ChartCard("Kelembapan Udara", history, (d) => d.kelembapanUdara, Colors.lightBlue, "%"),
                _ChartCard("Kelembapan Tanah", history, (d) => d.kelembapanTanah.toDouble(), Colors.blue, "%"),
                _ChartCard("Intensitas Cahaya", history, (d) => d.cahaya, Colors.orange, " Lx"),
                _ChartCard("Kadar CO2", history, (d) => d.co2.toDouble(), Colors.purple, " PPM"),
                _ChartCard("Tegangan", history, (d) => d.tegangan, Colors.amber[800]!, " V"),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _ChartCard(String title, List<HistoryPoint> data, double Function(SensorData) getter, Color color, String unit) {
    // Siapkan Data Spot untuk FL_Chart
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), getter(data[i].data)));
    }

    return Container(
      height: 250,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
              Text(
                "${getter(data.last.data).toStringAsFixed(1)}$unit",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5, // Tampilkan label tiap 5 data
                      getTitlesWidget: (val, meta) {
                        int index = val.toInt();
                        if (index >= 0 && index < data.length) {
                          return Text(
                            DateFormat('Hm').format(data[index].time), // Jam:Menit
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
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
}
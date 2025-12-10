import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sensor_data.dart';
import 'sensor_provider.dart';

// Model data dengan Timestamp untuk Grafik
class HistoryPoint {
  final DateTime time;
  final SensorData data;

  HistoryPoint(this.time, this.data);
}

// Provider untuk menyimpan List Riwayat
class HistoryNotifier extends StateNotifier<List<HistoryPoint>> {
  HistoryNotifier() : super([]);

  void addData(SensorData newData) {
    final now = DateTime.now();
    // Tambahkan data baru ke list
    state = [...state, HistoryPoint(now, newData)];

    // Batasi maksimum 20 data agar memori HP aman & grafik rapi
    if (state.length > 20) {
      state = state.sublist(state.length - 20);
    }
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<HistoryPoint>>((ref) {
  return HistoryNotifier();
});
class SensorData {
  final double suhuUdara;
  final double suhuTanah;
  final double kelembapanUdara;
  final int kelembapanTanah;
  final double cahaya;
  final int co2;
  final double tegangan;
  final bool isConnected;

  SensorData({
    this.suhuUdara = 0.0,
    this.suhuTanah = 0.0,
    this.kelembapanUdara = 0.0,
    this.kelembapanTanah = 0,
    this.cahaya = 0.0,
    this.co2 = 0,
    this.tegangan = 0.0,
    this.isConnected = false,
  });

  // Fungsi untuk update salah satu data tanpa menghapus yang lain
  SensorData copyWith({
    double? suhuUdara,
    double? suhuTanah,
    double? kelembapanUdara,
    int? kelembapanTanah,
    double? cahaya,
    int? co2,
    double? tegangan,
    bool? isConnected,
  }) {
    return SensorData(
      suhuUdara: suhuUdara ?? this.suhuUdara,
      suhuTanah: suhuTanah ?? this.suhuTanah,
      kelembapanUdara: kelembapanUdara ?? this.kelembapanUdara,
      kelembapanTanah: kelembapanTanah ?? this.kelembapanTanah,
      cahaya: cahaya ?? this.cahaya,
      co2: co2 ?? this.co2,
      tegangan: tegangan ?? this.tegangan,
      isConnected: isConnected ?? this.isConnected
    );
  }
}
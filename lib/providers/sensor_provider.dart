import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/sensor_data.dart';
import '../services/storage_service.dart';

// --- PROVIDER UTAMA ---

// 1. Provider Data Sensor (Notifier)
final sensorProvider = StateNotifierProvider<SensorNotifier, SensorData>((ref) {
  // Mengirim 'ref' agar Notifier bisa bicara dengan provider lain
  return SensorNotifier(ref);
});

// 2. Provider Status Koneksi (BARU: Terpisah dari SensorData)
// True = Online, False = Offline
final mqttConnectedProvider = StateProvider<bool>((ref) => false);

// 3. Provider Status Emosi Avatar (Logika Baru)
final avatarStatusProvider = Provider<String>((ref) {
  final data = ref.watch(sensorProvider);

  // Logic Sesuai Request:
  if (data.tegangan > 0 && data.tegangan < 4.0)
    return 'DEAD'; // Batas Tegangan < 4.0
  if (data.co2 > 1200) return 'SICK';
  if (data.suhuUdara > 0 && data.suhuUdara < 20) return 'COLD';
  if (data.suhuUdara > 35) return 'HOT'; // Batas Panas > 35
  if (data.kelembapanTanah >= 30 && data.kelembapanTanah < 60) return 'THIRSTY';
  if (data.cahaya >= 0 && data.cahaya < 300)
    return 'DARK'; // Batas Cahaya < 700

  return 'HAPPY';
});

// --- CLASS LOGIC UTAMA ---
class SensorNotifier extends StateNotifier<SensorData> {
  MqttServerClient? client;
  final Ref ref; // Referensi untuk update provider lain

  SensorNotifier(this.ref) : super(SensorData()) {
    connectMQTT();
  }

  // Fungsi connect dibuat public agar bisa dipanggil dari tombol Save/Retry
  Future<void> connectMQTT() async {
    // Reset koneksi jika ada
    if (client != null &&
        client!.connectionStatus!.state == MqttConnectionState.connected) {
      client!.disconnect();
    }

    // Ambil setting dari Storage HP
    final settings = await StorageService.getSettings();
    String host = settings['host'];
    int port = settings['port'];
    String user = settings['user'];
    String pass = settings['pass'];

    // Setup Client
    client = MqttServerClient(
      host,
      'FlutterApp-${DateTime.now().millisecondsSinceEpoch}',
    );
    client!.port = port;
    client!.secure = false; // Non-SSL (TCP Biasa)
    client!.logging(on: false);
    client!.keepAlivePeriod = 60;

    // --- CALLBACK STATUS KONEKSI (Update Provider Terpisah) ---
    client!.onConnected = () {
      print('✅ MQTT Connected');
      ref.read(mqttConnectedProvider.notifier).state = true;
    };

    client!.onDisconnected = () {
      print('❌ MQTT Disconnected');
      ref.read(mqttConnectedProvider.notifier).state = false;
    };

    // Setup Login Message
    final connMess = MqttConnectMessage()
        .withClientIdentifier(
          'FlutterApp-${DateTime.now().millisecondsSinceEpoch}',
        )
        .authenticateAs(user, pass)
        .startClean();
    client!.connectionMessage = connMess;

    // Eksekusi Konek
    try {
      print('Connecting to $host:$port...');
      await client!.connect();
    } catch (e) {
      print('Exception: $e');
      client!.disconnect();
      ref.read(mqttConnectedProvider.notifier).state = false;
    }

    // Subscribe jika berhasil
    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      _subscribe('polines/data/sensor/suhu_tanah');
      _subscribe('polines/data/sensor/suhu_udara');
      _subscribe('polines/data/sensor/kelembapan_tanah');
      _subscribe('polines/data/sensor/kelembapan_udara');
      _subscribe('polines/data/sensor/intensitas_cahaya');
      _subscribe('polines/data/sensor/intensitas_co2');
      _subscribe('polines/data/sensor/tegangan');

      // Dengarkan Data
      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        final String topic = c[0].topic;
        _updateData(topic, pt);
      });
    }
  }

  void _subscribe(String topic) {
    client!.subscribe(topic, MqttQos.atMostOnce);
  }

  void _updateData(String topic, String payload) {
    final val = double.tryParse(payload) ?? 0.0;

    if (topic.contains('suhu_udara')) state = state.copyWith(suhuUdara: val);
    if (topic.contains('suhu_tanah')) state = state.copyWith(suhuTanah: val);
    if (topic.contains('kelembapan_tanah'))
      state = state.copyWith(kelembapanTanah: val.toInt());
    if (topic.contains('kelembapan_udara'))
      state = state.copyWith(kelembapanUdara: val);
    if (topic.contains('intensitas_cahaya'))
      state = state.copyWith(cahaya: val);
    if (topic.contains('intensitas_co2'))
      state = state.copyWith(co2: val.toInt());
    if (topic.contains('tegangan')) state = state.copyWith(tegangan: val);
  }
}

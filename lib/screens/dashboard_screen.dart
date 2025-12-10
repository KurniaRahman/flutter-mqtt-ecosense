import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/sensor_provider.dart';
import '../providers/history_provider.dart'; // Pastikan import ini ada
import '../widgets/plant_avatar.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import '../services/sound_service.dart'; 


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ambil Data dari Provider
    final sensors = ref.watch(sensorProvider);
    final status = ref.watch(avatarStatusProvider);
    final isConnected = ref.watch(mqttConnectedProvider); 
    ref.listen(avatarStatusProvider, (previous, next) {
      if (previous != next) {
        SoundService.playForStatus(next);
      }
    });

    // --- LISTENER HISTORY ---
    ref.listen(sensorProvider, (previous, next) {
      ref.read(historyProvider.notifier).addData(next);
    });

    List<Map<String, String>> diagnoses = [];
    String message = "Halo! Aku sehat hari ini! 🌱";
    Color bgColor = const Color(0xFFF0FDF4);

    // --- LOGIC CHECK (Sama seperti sebelumnya) ---
    if (sensors.tegangan > 0 && sensors.tegangan < 4.0) {
      diagnoses.add({'title': 'Baterai Lemah', 'action': 'Segera charge baterai sistem!'});
    }
    if (sensors.co2 > 1200) {
      diagnoses.add({'title': 'Udara Kotor', 'action': 'Buka ventilasi udara segera.'});
    }
    if (sensors.suhuUdara > 0 && sensors.suhuUdara < 20) {
      diagnoses.add({'title': 'Kedinginan', 'action': 'Naikkan suhu ruangan.'});
    } else if (sensors.suhuUdara > 35) {
      diagnoses.add({'title': 'Kepanasan', 'action': 'Nyalakan kipas angin.'});
    }
    if (sensors.kelembapanTanah >= 0 && sensors.kelembapanTanah < 60) {
      diagnoses.add({'title': 'Tanah Kering', 'action': 'Siram tanaman secukupnya.'});
    } else if (sensors.kelembapanTanah > 80) {
      diagnoses.add({'title': 'Tanah Basah', 'action': 'Stop penyiraman dulu.'});
    }
    if (sensors.cahaya >= 0 && sensors.cahaya < 700) {
      diagnoses.add({'title': 'Kurang Cahaya', 'action': 'Pindahkan ke tempat terang.'});
    } else if (sensors.cahaya > 1000) { // Update batas silau
      diagnoses.add({'title': 'Terlalu Silau', 'action': 'Beri naungan sedikit.'});
    }

    if (status == 'THIRSTY') {
      bgColor = const Color(0xFFFEF3C7);
      message = "Aku haus... Siram aku dong! 🥤";
    } else if (status == 'HOT') {
      bgColor = const Color(0xFFFEE2E2);
      message = "Gerah banget! Aku butuh udara segar! 🥵";
    } else if (status == 'COLD') {
      bgColor = const Color(0xFFECFEFF);
      message = "Brrr... Dingin sekali! 🥶";
    } else if (status == 'DARK') {
      bgColor = const Color(0xFF1E293B);
      message = "Gelap sekali... Aku takut! 🌑";
    } else if (status == 'SICK') {
      bgColor = const Color(0xFFF3E8FF);
      message = "Uhuk.. Udara kotor sekali 🤢";
    } else if (status == 'DEAD') {
      bgColor = const Color(0xFFF3F4F6);
      message = "Baterai Lemah... Bye bye... ";
    }

    bool isDarkTheme = status == 'DARK';
    Color textColor = isDarkTheme ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        // --- BAGIAN INDIKATOR KONEKSI (TITIK HIJAU/MERAH) ---
        title: Row(
          mainAxisSize: MainAxisSize.min, // Agar posisi di tengah
          children: [
            // Titik Indikator
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isConnected ? Colors.greenAccent : Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isConnected ? Colors.green.withOpacity(0.6) : Colors.red.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
            ).animate(target: isConnected ? 1 : 0)
             .scale(duration: 500.ms, curve: Curves.easeInOut) // Animasi muncul
             .then()
             .shimmer(duration: 2.seconds, delay: 3.seconds), // Animasi berkilau

            const SizedBox(width: 8), // Jarak spasi

            // Teks Judul
            Text(
              "EcoSense",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.history, color: textColor),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
            },
          ),
          IconButton(
            icon: Icon(LucideIcons.settings, color: textColor),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              // 1. AREA AVATAR
Center(
                child: Column(
                  children: [
                    // Bubble Chat (Biarkan sama)
                    Container(
                      // ... (Kode Container Bubble Chat sama) ...
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                    ).animate(key: ValueKey(message)).scale(duration: 400.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 10),
                    
                    // --- 2. AVATAR YANG BISA DI-KLIK (INTERAKTIF) ---
                    GestureDetector(
                      onTap: () {
                        // Fitur: Tap avatar untuk dengar suara lagi
                        SoundService.playForStatus(status);
                        
                        // Opsional: Tambahkan efek visual 'boing' saat diklik
                        // (Perlu state management lokal kalau mau animasi klik, tapi suara saja cukup)
                        print("Avatar diklik: Memainkan suara $status");
                      },
                      child: SizedBox(
                        height: 220,
                        child: PlantAvatar(status: status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. PANEL DIAGNOSIS
              if (diagnoses.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[100]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.alertTriangle, color: Colors.red[600], size: 20),
                          const SizedBox(width: 8),
                          Text("Perlu Tindakan!", style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...diagnoses.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: Colors.red[900], fontSize: 13, fontFamily: 'Nunito'),
                                  children: [
                                    TextSpan(text: "${item['title']}: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: item['action']),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),

              // 3. VITALITAS TANAMAN
              Text(
                "Vitalitas Tanaman".toUpperCase(),
                style: TextStyle(color: textColor.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 10),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isDarkTheme ? 0.1 : 0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    _AnimatedBar(
                      label: "Kadar Air Tanah",
                      value: sensors.kelembapanTanah.toDouble(),
                      max: 100,
                      unit: "%",
                      color: Colors.blue,
                      icon: LucideIcons.droplets,
                    ),
                    const SizedBox(height: 20),
                    _AnimatedBar(
                      label: "Intensitas Cahaya",
                      value: sensors.cahaya,
                      max: 1000,
                      unit: " Lx",
                      color: Colors.amber,
                      icon: LucideIcons.sun,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 4. MONITORING LENGKAP
              Text(
                "Lingkungan Sekitar".toUpperCase(),
                style: TextStyle(color: textColor.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 10),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _SensorGridCard("Suhu Udara", "${sensors.suhuUdara.toStringAsFixed(1)}°C", LucideIcons.thermometer, Colors.red, isDarkTheme),
                  _SensorGridCard("Kelembapan", "${sensors.kelembapanUdara.toStringAsFixed(0)}%", LucideIcons.wind, Colors.lightBlue, isDarkTheme),
                  _SensorGridCard("Kualitas CO2", "${sensors.co2} PPM", LucideIcons.cloudFog, Colors.purple, isDarkTheme),
                  _SensorGridCard("Voltase", "${sensors.tegangan.toStringAsFixed(1)} V", LucideIcons.zap, Colors.orange, isDarkTheme),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _SensorGridCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color.withOpacity(0.5), shape: BoxShape.circle)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.grey[800])),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey[500])),
            ],
          )
        ],
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final String unit;
  final Color color;
  final IconData icon;

  const _AnimatedBar({required this.label, required this.value, required this.max, required this.unit, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    double percent = (value / max).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
              ],
            ),
            Text("${value.toInt()}$unit", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10))),
            LayoutBuilder(
              builder: (context, constraints) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: percent * constraints.maxWidth),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutExpo,
                  builder: (context, width, child) {
                    return Container(
                      height: 12, width: width,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))]),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
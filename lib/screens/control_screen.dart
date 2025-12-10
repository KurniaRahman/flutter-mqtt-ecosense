import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/sensor_provider.dart';

class ControlScreen extends ConsumerWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensors = ref.watch(sensorProvider);
    final notifier = ref.read(sensorProvider.notifier);

    // Warna Tema
    Color activeColor = const Color(0xFF10B981); // Hijau
    Color inactiveColor = Colors.grey[300]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text("Ruang Kendali", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- 1. MASTER SWITCH (AUTO / MANUAL) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                border: Border.all(color: sensors.isAutoMode ? activeColor : Colors.orange, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Mode Sistem", style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                          Text(
                            sensors.isAutoMode ? "OTOMATIS (AI)" : "MANUAL (REMOTE)",
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.w900, 
                              color: sensors.isAutoMode ? activeColor : Colors.orange
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: sensors.isAutoMode,
                        activeColor: activeColor,
                        activeTrackColor: activeColor.withOpacity(0.2),
                        inactiveThumbColor: Colors.orange,
                        inactiveTrackColor: Colors.orange.withOpacity(0.2),
                        onChanged: (val) {
                          // Kirim perintah ke MQTT: '1' = Auto, '0' = Manual
                          notifier.sendCommand('mode', val ? '1' : '0');
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    sensors.isAutoMode 
                        ? "Sistem akan menyalakan kipas & pompa secara otomatis berdasarkan sensor."
                        : "Anda memegang kendali penuh. Silakan nyalakan alat di bawah ini.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. TOMBOL KENDALI ALAT (GRID) ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  // KARTU KIPAS
                  _ControlCard(
                    title: "Kipas Pendingin",
                    icon: LucideIcons.fan,
                    isOn: sensors.isFanOn,
                    // Jika Mode Auto, tombol Disable (null)
                    onChanged: sensors.isAutoMode 
                        ? null 
                        : (val) => notifier.sendCommand('kipas', val ? '1' : '0'),
                    color: Colors.cyan,
                    isLocked: sensors.isAutoMode,
                  ),

                  // KARTU POMPA
                  _ControlCard(
                    title: "Pompa Air",
                    icon: LucideIcons.droplets,
                    isOn: sensors.isMotorOn,
                    // Jika Mode Auto, tombol Disable (null)
                    onChanged: sensors.isAutoMode 
                        ? null 
                        : (val) => notifier.sendCommand('motor', val ? '1' : '0'),
                    color: Colors.blueAccent,
                    isLocked: sensors.isAutoMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET HELPER: KARTU REMOTE ---
class _ControlCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isOn;
  final bool isLocked;
  final Function(bool)? onChanged;
  final Color color;

  const _ControlCard({
    required this.title,
    required this.icon,
    required this.isOn,
    required this.isLocked,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.5 : 1.0, // Redupkan jika terkunci (Auto Mode)
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isOn ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isOn ? color : Colors.transparent, 
            width: 2
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ikon dengan Animasi Putar jika ON
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isOn ? color : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isOn ? Colors.white : Colors.grey, size: 30)
                  .animate(target: isOn ? 1 : 0)
                  .rotate(duration: 1.seconds, curve: Curves.linear), // Animasi putar
            ),
            
            Column(
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 5),
                // Switch ON/OFF
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: isOn,
                    onChanged: onChanged, // Akan null jika isLocked=true
                    activeColor: color,
                  ),
                ),
                if (isLocked)
                  const Text("Auto Mode", style: TextStyle(fontSize: 10, color: Colors.grey))
              ],
            )
          ],
        ),
      ),
    );
  }
}
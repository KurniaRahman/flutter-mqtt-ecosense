import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dashboard_screen.dart'; // Nanti kita buat setelah ini

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pindah ke Dashboard setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO (Sementara pakai Icon Sprout, nanti ganti SVG Logo kamu)
            const Icon(Icons.eco_rounded, size: 100, color: Color(0xFF10B981))
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack) // Efek Muncul Pop
                .then()
                .shimmer(duration: 1200.ms), // Efek Kilau

            const SizedBox(height: 20),

            // Text Judul
            Text(
              "EcoSense",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).primaryColor,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),

            const SizedBox(height: 10),

            const Text(
              "Belajar Bicara dengan Tanaman 🌱",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
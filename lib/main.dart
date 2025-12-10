import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart'; // Nanti kita buat file ini

void main() {
  // Bungkus aplikasi dengan ProviderScope agar Riverpod jalan
  runApp(const ProviderScope(child: EcoSenseApp()));
}

class EcoSenseApp extends StatelessWidget {
  const EcoSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoSense',
      debugShowCheckedModeBanner: false,
      
      // TEMA APLIKASI (Warna Ramah Anak)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), // Hijau Emerald (Warna Utama)
          brightness: Brightness.light,
          primary: const Color(0xFF10B981),
          secondary: const Color(0xFF38BDF8), // Biru Langit
          background: const Color(0xFFF0FDF4), // Hijau sangat muda (Background)
        ),
        
        // Font yang bulat & ramah (Nunito sangat populer untuk app anak)
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ),
        
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF064E3B), // Hijau Gelap
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito', 
          ),
          iconTheme: IconThemeData(color: Color(0xFF064E3B)),
        ),
      ),
      
      // Halaman pertama yang dibuka
      home: const SplashScreen(), 
    );
  }
}
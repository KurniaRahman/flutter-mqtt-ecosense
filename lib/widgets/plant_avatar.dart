import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlantAvatar extends StatelessWidget {
  final String status; // HAPPY, SAD, HOT, dll

  const PlantAvatar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Mapping Status ke File SVG
    String svgFile = 'assets/avatars/plant_happy.svg';
    
    switch (status) {
      case 'THIRSTY': svgFile = 'assets/avatars/plant_thirsty.svg'; break;
      case 'HOT':     svgFile = 'assets/avatars/plant_hot.svg'; break;
      case 'COLD':    svgFile = 'assets/avatars/plant_cold.svg'; break;
      case 'DARK':    svgFile = 'assets/avatars/plant_dark.svg'; break;
      case 'SICK':    svgFile = 'assets/avatars/plant_sick.svg'; break;
      case 'DEAD':    svgFile = 'assets/avatars/plant_dead.svg'; break;
      default:        svgFile = 'assets/avatars/plant_happy.svg';
    }

    // Load Gambar
    Widget avatar = SvgPicture.asset(
      svgFile,
      height: 250, // Ukuran Avatar
      placeholderBuilder: (context) => const CircularProgressIndicator(),
    );

    // Tambahkan Animasi Berdasarkan Status
    if (status == 'HAPPY') {
      return avatar.animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -10, duration: 2.seconds) // Floating
          .rotate(begin: -0.02, end: 0.02);
    } else if (status == 'THIRSTY') {
      return avatar.animate().saturate(begin: 1, end: 0.5); // Jadi agak pudar
    } else if (status == 'HOT') {
      return avatar.animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1, end: 1.05, duration: 600.ms); // Denyut
    } else if (status == 'COLD') {
      return avatar.animate(onPlay: (c) => c.repeat())
          .shake(hz: 8, rotation: 0.05); // Menggigil cepat
    } else if (status == 'SICK') {
       return avatar.animate(onPlay: (c) => c.repeat(reverse: true))
          .rotate(begin: -0.05, end: 0.05, duration: 3.seconds); // Pusing lambat
    }

    return avatar; // Default
  }
}
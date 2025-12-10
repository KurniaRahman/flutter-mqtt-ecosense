import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Key untuk penyimpanan
  static const String _keyHost = 'mqtt_host';
  static const String _keyPort = 'mqtt_port';
  static const String _keyUser = 'mqtt_user';
  static const String _keyPass = 'mqtt_pass';

  // Default Value (Server Original Kamu)
  static const String defaultHost = '103.103.23.207';
  static const int defaultPort = 1883;
  static const String defaultUser = 'monitoring_lingkungan';
  static const String defaultPass = 'admin12';

  // Simpan Config
  static Future<void> saveSettings(String host, int port, String user, String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHost, host);
    await prefs.setInt(_keyPort, port);
    await prefs.setString(_keyUser, user);
    await prefs.setString(_keyPass, pass);
  }

  // Ambil Config (Return Map)
  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'host': prefs.getString(_keyHost) ?? defaultHost,
      'port': prefs.getInt(_keyPort) ?? defaultPort,
      'user': prefs.getString(_keyUser) ?? defaultUser,
      'pass': prefs.getString(_keyPass) ?? defaultPass,
    };
  }
  
  // Reset ke Default
  static Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
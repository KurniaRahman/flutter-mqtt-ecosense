import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/storage_service.dart';
import '../providers/sensor_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller Text Field
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  // Load data dari memori HP ke Text Field
  Future<void> _loadCurrentSettings() async {
    final settings = await StorageService.getSettings();
    setState(() {
      _hostController.text = settings['host'];
      _portController.text = settings['port'].toString();
      _userController.text = settings['user'];
      _passController.text = settings['pass'];
    });
  }

  // Fungsi Simpan
  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // 1. Simpan ke Storage
      await StorageService.saveSettings(
        _hostController.text,
        int.parse(_portController.text),
        _userController.text,
        _passController.text,
      );

      // 2. Refresh Koneksi MQTT di Provider
      // Kita baca notifier-nya lalu panggil method connectMQTT()
      await ref.read(sensorProvider.notifier).connectMQTT();

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pengaturan Disimpan! Menghubungkan ulang..."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke dashboard
      }
    }
  }

  // Fungsi Reset Default
  Future<void> _resetDefault() async {
    await StorageService.resetSettings();
    await _loadCurrentSettings(); // Reload UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reset ke default!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text("Pengaturan", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCcw, color: Colors.red),
            onPressed: _resetDefault,
            tooltip: "Reset Default",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                title: "Server MQTT",
                icon: LucideIcons.server,
                children: [
                  _buildTextField("Host / IP Address", _hostController, LucideIcons.globe),
                  const SizedBox(height: 15),
                  _buildTextField("Port (TCP)", _portController, LucideIcons.zap, isNumber: true),
                ],
              ),
              const SizedBox(height: 20),
              _buildCard(
                title: "Autentikasi",
                icon: LucideIcons.shield,
                children: [
                  _buildTextField("Username", _userController, LucideIcons.user),
                  const SizedBox(height: 15),
                  _buildTextField("Password", _passController, LucideIcons.lock, isPassword: true),
                ],
              ),
              const SizedBox(height: 30),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveSettings,
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(LucideIcons.save),
                label: Text(_isLoading ? "Menyimpan..." : "SIMPAN"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "EcoSense v1.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF10B981)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) => value == null || value.isEmpty ? "Harus diisi" : null,
    );
  }
}
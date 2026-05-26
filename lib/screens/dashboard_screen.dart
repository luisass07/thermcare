import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'history_screen.dart';
import 'emergency_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double temperatura = 36.5;
  String estado = 'Normal';
  Color estadoColor = const Color(0xFF00C48C);
  bool conectado = false;
  int _currentIndex = 0;

  void _simularLectura() {
    setState(() {
      temperatura = 36.0 + (DateTime.now().millisecond % 30) / 10;
      if (temperatura >= 38.0) {
        estado = '⚠️ Fiebre';
        estadoColor = Colors.redAccent;
      } else if (temperatura >= 37.5) {
        estado = 'Temperatura alta';
        estadoColor = Colors.orange;
      } else {
        estado = 'Normal';
        estadoColor = const Color(0xFF00C48C);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      const HistoryScreen(),
      const EmergencyScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('ThermCare',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              conectado ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: conectado ? const Color(0xFF0A7AFF) : Colors.grey,
            ),
            onPressed: () {
              setState(() => conectado = !conectado);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(conectado ? 'ESP32 conectado' : 'Desconectado'),
                  backgroundColor: conectado ? Colors.green : Colors.red,
                ),
              );
            },
          )
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1A2D45),
        selectedItemColor: const Color(0xFF0A7AFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: 'Emergencia'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alertas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2D45),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text('Temperatura actual',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 12),
                Text(
                  '${temperatura.toStringAsFixed(1)} °C',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: estadoColor),
                  ),
                  child: Text(estado,
                      style: TextStyle(
                          color: estadoColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _infoCard('Paciente', 'Usuario', Icons.person),
              const SizedBox(width: 16),
              _infoCard('Última lectura',
                  '${DateTime.now().hour}:${DateTime.now().minute}',
                  Icons.access_time),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A7AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Leer temperatura',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: _simularLectura,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2D45),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF0A7AFF), size: 20),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

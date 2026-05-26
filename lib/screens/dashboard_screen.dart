import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  String nombreUsuario = 'Cargando...';
  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  bool _alertaMostrada = false;

  static const String SERVICE_UUID = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String CHAR_UUID = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';

  // ← CAMBIA ESTE NÚMERO POR EL DEL MÉDICO REAL
  static const String NUMERO_MEDICO = '323 3047483';

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      setState(() {
        nombreUsuario = doc.data()?['nombre'] ?? user.email ?? 'Usuario';
      });
    }
  }

  void _actualizarEstado(double temp) {
    setState(() {
      temperatura = temp;
      if (temperatura >= 38.0) {
        estado = '⚠️ Fiebre';
        estadoColor = Colors.redAccent;
        if (!_alertaMostrada) {
          _alertaMostrada = true;
          _mostrarAlertaFiebre();
        }
      } else if (temperatura >= 37.5) {
        estado = 'Temperatura alta';
        estadoColor = Colors.orange;
        _alertaMostrada = false;
      } else {
        estado = 'Normal';
        estadoColor = const Color(0xFF00C48C);
        _alertaMostrada = false;
      }
    });
  }

  void _mostrarAlertaFiebre() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2D45),
        title: const Text('⚠️ Temperatura Alta',
            style: TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Text(
          'Se detectó fiebre. Se recomienda contactar a tu médico de inmediato.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
            icon: const Icon(Icons.call, color: Colors.white),
            label: const Text('Llamar médico',
                style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse('tel:$NUMERO_MEDICO');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
        ],
      ),
    );
  }

  void _simularLectura() {
    final temp = 36.0 + (DateTime.now().millisecond % 30) / 10;
    _actualizarEstado(temp);
  }

  Future<void> _conectarBluetooth() async {
    if (conectado) {
      await _device?.disconnect();
      setState(() {
        conectado = false;
        _device = null;
        _characteristic = null;
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Buscando ESP32-C3...'),
          backgroundColor: Colors.blue),
    );

    try {
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 5));

      BluetoothDevice? found;
      await for (final results in FlutterBluePlus.scanResults) {
        for (ScanResult r in results) {
          if (r.device.platformName == 'ESP32-C3') {
            found = r.device;
            await FlutterBluePlus.stopScan();
            break;
          }
        }
        if (found != null) break;
      }

      if (found == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('ESP32-C3 no encontrado'),
              backgroundColor: Colors.red),
        );
        return;
      }

      await found.connect();
      List<BluetoothService> services = await found.discoverServices();

      for (BluetoothService service in services) {
        if (service.uuid.toString() == SERVICE_UUID) {
          for (BluetoothCharacteristic c in service.characteristics) {
            if (c.uuid.toString() == CHAR_UUID) {
              _characteristic = c;
              await c.setNotifyValue(true);
              c.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  final tempStr = String.fromCharCodes(value);
                  final temp = double.tryParse(tempStr);
                  if (temp != null) _actualizarEstado(temp);
                }
              });
            }
          }
        }
      }

      setState(() {
        conectado = true;
        _device = found;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ ESP32-C3 conectado'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red),
      );
    }
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
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              conectado
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              color: conectado
                  ? const Color(0xFF0A7AFF)
                  : Colors.grey,
            ),
            onPressed: _conectarBluetooth,
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
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Historial'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emergency), label: 'Emergencia'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Alertas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Perfil'),
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
                    style:
                        TextStyle(color: Colors.grey, fontSize: 16)),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: estadoColor),
                  ),
                  child: Text(estado,
                      style: TextStyle(
                          color: estadoColor,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _infoCard('Paciente', nombreUsuario, Icons.person),
              const SizedBox(width: 16),
              _infoCard(
                  'Última lectura',
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
                backgroundColor: conectado
                    ? Colors.green
                    : const Color(0xFF0A7AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                conectado
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth,
                color: Colors.white,
              ),
              label: Text(
                conectado
                    ? 'Conectado — leyendo...'
                    : 'Conectar ESP32-C3',
                style: const TextStyle(
                    color: Colors.white, fontSize: 16),
              ),
              onPressed: _conectarBluetooth,
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
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12)),
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

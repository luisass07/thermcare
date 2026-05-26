import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, dynamic>> notificaciones = const [
    {
      'titulo': '⚠️ Temperatura alta detectada',
      'descripcion': 'Se registró 38.2°C a las 3:00 PM',
      'hora': 'Hace 2 horas',
      'color': Colors.redAccent,
    },
    {
      'titulo': '✅ Temperatura normal',
      'descripcion': 'Se registró 36.5°C a las 1:00 PM',
      'hora': 'Hace 4 horas',
      'color': Color(0xFF00C48C),
    },
    {
      'titulo': '🔵 Dispositivo conectado',
      'descripcion': 'ESP32 conectado exitosamente',
      'hora': 'Hace 5 horas',
      'color': Color(0xFF0A7AFF),
    },
    {
      'titulo': '⚠️ Fiebre detectada',
      'descripcion': 'Se registró 38.8°C a las 10:00 AM',
      'hora': 'Hace 7 horas',
      'color': Colors.orange,
    },
    {
      'titulo': '✅ Temperatura normal',
      'descripcion': 'Se registró 36.8°C a las 8:00 AM',
      'hora': 'Hace 9 horas',
      'color': Color(0xFF00C48C),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notificaciones',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Alertas y eventos recientes',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: notificaciones.length,
              itemBuilder: (context, index) {
                final n = notificaciones[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2D45),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: (n['color'] as Color).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 50,
                        decoration: BoxDecoration(
                          color: n['color'] as Color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n['titulo'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(n['descripcion'],
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(n['hora'],
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

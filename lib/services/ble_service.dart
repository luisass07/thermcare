import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static BluetoothDevice? deviceConnected;
  static BluetoothCharacteristic? characteristic;

  static Future<BluetoothDevice?> scanAndConnect() async {
    BluetoothDevice? found;

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    await for (final result in FlutterBluePlus.scanResults) {
      for (ScanResult r in result) {
        if (r.device.platformName == 'ESP32-C3') {
          found = r.device;
          await FlutterBluePlus.stopScan();
          break;
        }
      }
      if (found != null) break;
    }

    if (found != null) {
      await found.connect();
      deviceConnected = found;
    }

    return found;
  }

  static Future<void> disconnect() async {
    await deviceConnected?.disconnect();
    deviceConnected = null;
  }
}
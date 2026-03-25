import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

enum DeviceLevel {
  low,
  medium,
  mediumHigh,
  high,
  ultraHigh,
}

class DeviceClassifier {
  
  static Future<DeviceLevel> getDeviceLevel() async {
    final info = await DeviceInfoPlugin().androidInfo;

    final int sdk = info.version.sdkInt;
    final int cores = Platform.numberOfProcessors;
    final int ramGB = await _estimateRam();

    final hardware = info.hardware.toLowerCase();

    //Android muy viejo
    if (sdk < 26) return DeviceLevel.low;

    // RAM insuficiente real
    if (ramGB < 3) return DeviceLevel.low;

    //CPUs extremadamente lentos conocidos
    if (hardware.contains('mt6762') ||  // Helio P22
        hardware.contains('mt6765') ||  // Helio P35
        hardware.contains('exynos 850')) {
      return DeviceLevel.low;
    }

    //gama media segura
    if (ramGB <= 4 || cores <= 6) {
      return DeviceLevel.medium;
    }

    // gama buena
    return DeviceLevel.high;
  }

  /*static Future<int> _getCpuCores() async {
    try {
      if (Platform.isAndroid || Platform.isLinux) {
        final file = File('/proc/cpuinfo');
        if (await file.exists()) {
          final content = await file.readAsLines();
          // líneas que empiezan con "processor"
          final processors =
              content.where((l) => l.toLowerCase().startsWith('processor')).length;
          if (processors > 0) return processors;
        }
      }
    } catch (_) {
      // ignore
    }

    // Fallback portable
    try {
      return Platform.numberOfProcessors;
    } catch (_) {
      return 4; // valor por defecto razonable
    }
  }*/

  static Future<int> _estimateRam() async {
    try {
      if (Platform.isAndroid || Platform.isLinux) {
        final file = File('/proc/meminfo');

        if (await file.exists()) {
          final lines = await file.readAsLines();

          final memLine = lines.firstWhere(
            (l) => l.toLowerCase().startsWith('memtotal'),
            orElse: () => '',
          );

          if (memLine.isNotEmpty) {
            final match = RegExp(r'\d+').firstMatch(memLine);

            if (match != null) {
              final kb = int.parse(match.group(0)!);
              final gb = kb / 1024 / 1024;

              // ⭐ redondeo inteligente
              if (gb >= 10) return 12;
              if (gb >= 7) return 8;
              if (gb >= 5) return 6;
              if (gb >= 3) return 4;
              if (gb >= 2) return 3;

              return 2;
            }
          }
        }
      }
    } catch (_) {}

    // fallback conservador
    return 3;
  }
}

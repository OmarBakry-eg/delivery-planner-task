import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

enum BuildFlavor { dev, prod }

class AppConfig {
  static const String _boxName = 'app_config';
  static const String _flavorKey = 'flavor';
  static BuildFlavor _flavor = BuildFlavor.prod;

  static BuildFlavor get flavor => _flavor;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    // Initialize timezone database once for the app
    tz.initializeTimeZones();
    final box = await Hive.openBox(_boxName);
    final stored = box.get(_flavorKey) as String?;
    if (stored != null) {
      _flavor = BuildFlavor.values.firstWhere(
        (f) => f.name == stored,
        orElse: () => BuildFlavor.prod,
      );
    }
  }

  static Future<void> setFlavorAndPersist(BuildFlavor flavor) async {
    _flavor = flavor;
    final box = await Hive.openBox(_boxName);
    await box.put(_flavorKey, flavor.name);
  }

  static String get appName {
    switch (_flavor) {
      case BuildFlavor.dev:
        return 'Delivery Dispatcher Dev';
      case BuildFlavor.prod:
        return 'Delivery Dispatcher';
    }
  }

  static String get appId {
    switch (_flavor) {
      case BuildFlavor.dev:
        return 'com.deliverydispatcher.dev';
      case BuildFlavor.prod:
        return 'com.deliverydispatcher.app';
    }
  }

  static double get codTolerance {
    switch (_flavor) {
      case BuildFlavor.dev:
        return 2.00;
      case BuildFlavor.prod:
        return 1.00;
    }
  }

  static bool get isDebug => _flavor == BuildFlavor.dev;
}

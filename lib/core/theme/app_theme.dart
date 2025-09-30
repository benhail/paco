import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color seed = Color(0xFF0D652D);

  static ThemeData light(ColorScheme? dynamicScheme) {
    final scheme = dynamicScheme ?? ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }

  static ThemeData dark(ColorScheme? dynamicScheme) {
    final scheme = dynamicScheme ??
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}

/// Scroll con rebote en iOS/macOS, clamping en el resto.
class HybridScrollBehavior extends MaterialScrollBehavior {
  const HybridScrollBehavior(); // 👈 constructor const (necesario para usar `const` al instanciar)
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
    }
    return const ClampingScrollPhysics();
  }
}

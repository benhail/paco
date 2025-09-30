import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/presentation/root_shell.dart';

class PacoApp extends StatelessWidget {
  const PacoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    Widget buildApp({ColorScheme? light, ColorScheme? dark}) {
      return MaterialApp(
        title: 'Paco',
        theme: AppTheme.light(light),
        darkTheme: AppTheme.dark(dark),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        scrollBehavior: const HybridScrollBehavior(),
        home: const RootShell(),
      );
    }

    if (isAndroid) {
      return DynamicColorBuilder(
        builder: (light, dark) => buildApp(light: light, dark: dark),
      );
    }
    return buildApp();
  }
}

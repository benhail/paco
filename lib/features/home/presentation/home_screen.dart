import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/adaptive/adaptive_date_picker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Hoy')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👋 Bienvenido a Paco', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                final picked = await showAdaptiveDateTimePicker(context);
                if (picked == null) return;
                final formatted = DateFormat('yyyy-MM-dd HH:mm').format(picked);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Recordatorio para: $formatted')),
                  );
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Programar recordatorio'),
            ),
            const SizedBox(height: 12),
            Text(
              'Este botón usa picker Cupertino en iOS y Material en Android.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

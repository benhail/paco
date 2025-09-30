import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showAdaptiveDateTimePicker(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final now = DateTime.now();
  final init = initial ?? now.add(const Duration(hours: 1));
  final first = firstDate ?? now.subtract(const Duration(days: 365 * 5));
  final last = lastDate ?? now.add(const Duration(days: 365 * 5));

  if (Platform.isIOS) {
    // iOS: usamos el context inmediatamente (antes de await).
    DateTime temp = init;
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: const Text('Cancelar'),
                  ),
                  const Text('Selecciona fecha y hora',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(temp),
                    child: const Text('OK'),
                  ),
                ],
              ),
              SizedBox(
                height: 220,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: init,
                  minimumDate: first,
                  maximumDate: last,
                  use24hFormat: true,
                  onDateTimeChanged: (d) => temp = d,
                ),
              ),
            ],
          ),
        );
      },
    );
    return result;
  } else {
    // Android / otros: showDatePicker -> await -> (reusar context) showTimePicker
    final date = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: first,
      lastDate: last,
    );
    if (date == null) return null;

    // ✅ Asegura que el widget que pasó `context` sigue montado antes de reusarlo
    if (!context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(init),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

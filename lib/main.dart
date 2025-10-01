import 'package:flutter/material.dart';
import 'package:paco/app.dart';
import 'package:paco/data/local/db.dart';
import 'package:paco/features/tasks/data/tasks_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  TasksRepository.init(db); // 👈 síncrono (ver cambio abajo)
  runApp(const PacoApp());
}

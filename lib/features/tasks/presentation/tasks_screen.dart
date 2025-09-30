import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tareas')),
      body: const Center(child: Text('Aquí irá la lista de tareas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Más adelante: abrir form / picker adaptativo para crear tarea.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('FAB de Tareas presionado')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
    );
  }
}

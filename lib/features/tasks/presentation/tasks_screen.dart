import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paco/core/adaptive/adaptive_date_picker.dart';
import 'package:paco/features/tasks/data/tasks_repository.dart';
import 'package:paco/features/tasks/domain/task.dart';

/// Result returned by the "New task" dialog.
class _QuickTaskResult {
  final String title;
  final DateTime? dueAt;
  const _QuickTaskResult(this.title, this.dueAt);
}

/// Self-contained dialog to create a new task (manages its own internal state).
class _QuickTaskDialog extends StatefulWidget {
  const _QuickTaskDialog();

  @override
  State<_QuickTaskDialog> createState() => _QuickTaskDialogState();
}

class _QuickTaskDialogState extends State<_QuickTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  DateTime? _pickedDate;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showAdaptiveDateTimePicker(context);
    if (!mounted) return;
    if (d != null) {
      setState(() => _pickedDate = d);
    }
  }

  void _onSave() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    // Remove focus before closing to avoid iOS asserts.
    FocusScope.of(context).unfocus();

    final t = _titleCtrl.text.trim();
    Navigator.of(context).pop(_QuickTaskResult(t, _pickedDate));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva tarea'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleCtrl,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Pon un título' : null,
              onFieldSubmitted: (_) => _onSave(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _pickedDate == null
                        ? 'Elegir fecha/hora'
                        : DateFormat('yyyy-MM-dd HH:mm').format(_pickedDate!),
                  ),
                ),
                const SizedBox(width: 8),
                if (_pickedDate != null)
                  IconButton(
                    tooltip: 'Quitar fecha',
                    onPressed: () => setState(() => _pickedDate = null),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = TasksRepository.I; // Resolve lazily to avoid early init issues.

    return Scaffold(
      appBar: AppBar(title: const Text('Tareas')),
      body: StreamBuilder<List<Task>>(
        stream: repo.watchAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? const <Task>[];

          if (items.isEmpty) return const _EmptyState();

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = items[i];
              final due = t.dueAt != null
                  ? DateFormat('EEE d MMM, HH:mm').format(t.dueAt!)
                  : 'Sin fecha';

              return ListTile(
                leading: Checkbox(
                  value: t.done,
                  onChanged: (_) {
                    // Stream will reflect new value automatically.
                    repo.toggleDone(t.id);
                  },
                ),
                title: Text(
                  t.title,
                  style: t.done
                      ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        )
                      : null,
                ),
                subtitle: Text(due),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => repo.remove(t.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickAdd,
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
    );
  }

  Future<void> _showQuickAdd() async {
    final result = await showDialog<_QuickTaskResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _QuickTaskDialog(),
    );

    if (!mounted || result == null) return;

    await TasksRepository.I.add(
      Task(title: result.title, dueAt: result.dueAt),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarea creada')),
    );
  }
}

// ---------- Empty state UI ----------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Sin tareas por ahora',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca “Nueva tarea” para crear tu primera.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:drift/drift.dart' as dr;
import 'package:uuid/uuid.dart';

import 'package:paco/data/local/db.dart';
import 'package:paco/features/tasks/domain/task.dart';

class TasksRepository {
  TasksRepository._(this._db);

  static TasksRepository? _instance;
  static TasksRepository get I {
    final inst = _instance;
    assert(inst != null, 'TasksRepository no inicializado. Llama TasksRepository.init(db) en main().');
    return inst!;
  }

  final AppDatabase _db;
  final _uuid = const Uuid();

  /// Inicializa una sola vez. Si ya existe, no hace nada.
  static void init(AppDatabase db) {
    _instance ??= TasksRepository._(db);
  }

  // ---- Lectura
  Stream<List<Task>> watchAll() => _db.watchTasks().map((rows) {
        return rows
            .map((r) => Task(
                  id: r.id,
                  title: r.title,
                  dueAt: r.dueAt,
                  done: r.done,
                ))
            .toList(growable: false);
      });

  Future<List<Task>> fetchAll() async {
    final rows = await _db.listTasks();
    return rows
        .map((r) => Task(id: r.id, title: r.title, dueAt: r.dueAt, done: r.done))
        .toList(growable: false);
  }

  // ---- Escritura
  Future<void> add(Task t) async {
    final id = (t.id.isEmpty) ? _uuid.v4() : t.id;
    await _db.insertTask(TasksTableCompanion(
      id: dr.Value(id),
      title: dr.Value(t.title),
      dueAt: dr.Value(t.dueAt),
      done: dr.Value(t.done),
    ));
  }

  Future<void> toggleDone(String id) async {
    final list = await _db.listTasks();
    final found = list.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Task not found'),
    );
    await _db.setDone(id, !found.done);
  }

  Future<void> remove(String id) => _db.deleteTask(id);
}

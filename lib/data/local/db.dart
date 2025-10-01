import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'db.g.dart';

/// Tabla de tareas.
class TasksTable extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get title => text()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TasksTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  @override
  int get schemaVersion => 1;

  // Lectura
  Future<List<TasksTableData>> listTasks() {
    return (select(tasksTable)
          ..orderBy([
            // 1) Nulls primero
            (t) => OrderingTerm(
                  expression: t.dueAt.isNull(),
                  mode: OrderingMode.desc, // true(1)=null primero
                ),
            // 2) Luego por fecha ascendente
            (t) => OrderingTerm(
                  expression: t.dueAt,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  Stream<List<TasksTableData>> watchTasks() {
    return (select(tasksTable)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.dueAt.isNull(),
                  mode: OrderingMode.desc,
                ),
            (t) => OrderingTerm(
                  expression: t.dueAt,
                  mode: OrderingMode.asc,
                ),
          ]))
        .watch();
  }

  // Escritura
  Future<void> insertTask(TasksTableCompanion entry) =>
      into(tasksTable).insert(entry);

  Future<int> setDone(String id, bool value) {
    return (update(tasksTable)..where((t) => t.id.equals(id)))
        .write(TasksTableCompanion(done: Value(value)));
  }

  Future<int> deleteTask(String id) =>
      (delete(tasksTable)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'paco.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

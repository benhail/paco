import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class Task {
  final String id;
  final String title;
  final DateTime? dueAt;
  final bool done;

  Task({
    String? id,
    required this.title,
    this.dueAt,
    this.done = false,
  }) : id = id ?? _uuid.v4();

  Task copyWith({String? title, DateTime? dueAt, bool? done}) {
    return Task(
      id: id,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      done: done ?? this.done,
    );
  }
}

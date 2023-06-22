import 'TasksModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;

class TasksDBWorker {
  TasksDBWorker._();
  static final TasksDBWorker db = TasksDBWorker._();

  Database? _db;
  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    var path = join(utils.docDir!.path, "tasks.db");
    var db = await openDatabase(
        path,
        version: 1,
        onOpen: (db) { },
        onCreate: (Database inDB, int inVersion) async {
          await inDB.execute(
              "CREATE TABLE IF NOT EXISTS tasks ("
                  "id INTEGER PRIMARY KEY,"
                  "description TEXT,"
                  "dueDate TEXT,"
                  "completed TEXT"
                  ")"
          );
        }
    );
    return db;
  }

  Task taskFromMap(Map inMap) {
    return Task()
      ..id = inMap["id"]
      ..description = inMap["description"]
      ..dueDate = inMap["dueDate"]
      ..completed = inMap["completed"];
  }

  Map<String, dynamic> taskToMap(Task inTask) {
    return Map<String, dynamic>()
      ..["id"] = inTask.id
      ..["description"] = inTask.description
      ..["dueDate"] = inTask.dueDate
      ..["completed"] = inTask.completed;
  }

  Future create(Task inTask) async {
    Database db = await database;
    var value = await db.rawQuery(
        "SELECT MAX(id) + 1 AS id FROM tasks"
    );
    int? id = value.first["id"] as int?;
    if(id == null) {
      id = 1;
    }

    return await db.rawInsert(
        "INSERT INTO tasks (id, description, dueDate, completed) "
            "VALUES (?, ?, ?, ?)",
        [id, inTask.description, inTask.dueDate, inTask.completed]
    );
  }

  Future<Task> get(int inID) async {
    Database db = await database;
    var rec = await db.query(
        "tasks", where: "id = ?", whereArgs: [inID]
    );
    return taskFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("tasks");
    return recs.isNotEmpty
        ? recs.map((m) => taskFromMap(m)).toList()
        : [];
  }

  Future update(Task inTask) async {
    Database db = await database;
    return await db.update("tasks", taskToMap(inTask),
        where: "id = ?", whereArgs: [inTask.id]
    );
  }

  Future delete(int inID) async {
    Database db = await database;
    return await db.delete(
        "tasks", where: "id = ?", whereArgs: [inID]
    );
  }
}
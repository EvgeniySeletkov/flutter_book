import 'NotesModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;

class NotesDBWorker {
  NotesDBWorker._();
  static final NotesDBWorker db = NotesDBWorker._();

  Database? _db;
  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    var path = join(utils.docDir!.path, "notes.db");
    var db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) { },
      onCreate: (Database inDB, int inVersion) async {
        await inDB.execute(
          "CREATE TABLE IF NOT EXISTS notes ("
              "id INTEGER PRIMARY KEY,"
              "title TEXT,"
              "content TEXT,"
              "color TEXT"
          ")"
        );
      }
    );
    return db;
  }

  Note noteFromMap(Map inMap) {
    return Note()
      ..id = inMap["id"]
      ..title = inMap["title"]
      ..content = inMap["content"]
      ..color = inMap["color"];
  }

  Map<String, dynamic> noteToMap(Note inNote) {
    return Map<String, dynamic>()
        ..["id"] = inNote.id
        ..["title"] = inNote.title
        ..["content"] = inNote.content
        ..["color"] = inNote.color;
  }

  Future create(Note inNote) async {
    Database db = await database;
    var value = await db.rawQuery(
      "SELECT MAX(id) + 1 AS id FROM notes"
    );
    int? id = value.first["id"] as int?;
    if(id == null) {
      id = 1;
    }

    return await db.rawInsert(
      "INSERT INTO notes (id, title, content, color) "
      "VALUES (?, ?, ?, ?)",
      [id, inNote.title, inNote.content, inNote.color]
    );
  }

  Future<Note> get(int inID) async {
    Database db = await database;
    var rec = await db.query(
      "notes", where: "id = ?", whereArgs: [inID]
    );
    return noteFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("notes");
    return recs.isNotEmpty
      ? recs.map((m) => noteFromMap(m)).toList()
      : [];
  }

  Future update(Note inNote) async {
    Database db = await database;
    return await db.update("notes", noteToMap(inNote),
      where: "id = ?", whereArgs: [inNote.id]
    );
  }

  Future delete(int inID) async {
    Database db = await database;
    return await db.delete(
      "notes", where: "id = ?", whereArgs: [inID]
    );
  }
}
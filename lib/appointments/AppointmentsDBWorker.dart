import 'package:flutter_book/appointments/AppointmentsModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;

class AppointmentsDBWorker {
  AppointmentsDBWorker._();
  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  Database? _db;
  Future get database async {
    if (_db == null) {
      _db = await init();
    }

    return _db;
  }

  Future<Database> init() async {
    var path = join(utils.docDir!.path, "appointments.db");
    var db = await openDatabase(
        path,
        version: 1,
        onOpen: (db) { },
        onCreate: (Database inDB, int inVersion) async {
          await inDB.execute(
              "CREATE TABLE IF NOT EXISTS appointments ("
                  "id INTEGER PRIMARY KEY,"
                  "title TEXT,"
                  "description TEXT,"
                  "apptDate TEXT,"
                  "apptTime TEXT"
                  ")"
          );
        }
    );
    return db;
  }

  Appointment appointmentFromMap(Map inMap) {
    return Appointment()
      ..id = inMap["id"]
      ..title = inMap["title"]
      ..description = inMap["description"]
      ..apptDate = inMap["apptDate"]
      ..apptTime = inMap["apptTime"];
  }

  Map<String, dynamic> appointmentToMap(Appointment inAppointment) {
    return Map<String, dynamic>()
      ..["id"] = inAppointment.id
      ..["title"] = inAppointment.title
      ..["description"] = inAppointment.description
      ..["apptDate"] = inAppointment.apptDate
      ..["apptTime"] = inAppointment.apptTime;
  }

  Future create(Appointment inAppointment) async {
    Database db = await database;
    var value = await db.rawQuery(
        "SELECT MAX(id) + 1 AS id FROM appointments"
    );
    int? id = value.first["id"] as int?;
    if(id == null) {
      id = 1;
    }

    return await db.rawInsert(
        "INSERT INTO appointments (id, title, description, apptDate, apptTime) "
            "VALUES (?, ?, ?, ?, ?)",
        [id, inAppointment.title, inAppointment.description,
          inAppointment.apptDate, inAppointment.apptTime]
    );
  }

  Future<Appointment> get(int inID) async {
    Database db = await database;
    var rec = await db.query(
        "appointments", where: "id = ?", whereArgs: [inID]
    );
    return appointmentFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("appointments");
    return recs.isNotEmpty
        ? recs.map((m) => appointmentFromMap(m)).toList()
        : [];
  }

  Future update(Appointment inAppointment) async {
    Database db = await database;
    return await db.update("appointments", appointmentToMap(inAppointment),
        where: "id = ?", whereArgs: [inAppointment.id]
    );
  }

  Future delete(int inID) async {
    Database db = await database;
    return await db.delete(
        "appointments", where: "id = ?", whereArgs: [inID]
    );
  }
}
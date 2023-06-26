import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_book/utils.dart' as utils;
import 'ContactsModel.dart';

class ContactsDBWorker {
  ContactsDBWorker._();
  static final ContactsDBWorker db = ContactsDBWorker._();

  Database? _db;
  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    var path = join(utils.docDir!.path, "contacts.db");
    var db = await openDatabase(
        path,
        version: 1,
        onOpen: (db) { },
        onCreate: (Database inDB, int inVersion) async {
          await inDB.execute(
              "CREATE TABLE IF NOT EXISTS contacts ("
                  "id INTEGER PRIMARY KEY,"
                  "name TEXT,"
                  "email TEXT,"
                  "phone TEXT,"
                  "birthday TEXT"
                  ")"
          );
        }
    );
    return db;
  }

  Contact contactFromMap(Map inMap) {
    return Contact()
      ..id = inMap["id"]
      ..name = inMap["name"]
      ..phone = inMap["phone"]
      ..email = inMap["email"]
      ..birthday = inMap["birthday"];
  }

  Map<String, dynamic> contactToMap(Contact inContact) {
    return Map<String, dynamic>()
      ..["id"] = inContact.id
      ..["name"] = inContact.name
      ..["phone"] = inContact.phone
      ..["email"] = inContact.email
      ..["birthday"] = inContact.birthday;
  }

  Future create(Contact inContact) async {
    Database db = await database;
    var value = await db.rawQuery(
        "SELECT MAX(id) + 1 AS id FROM contacts"
    );
    int? id = value.first["id"] as int?;
    if(id == null) {
      id = 1;
    }

    return await db.rawInsert(
        "INSERT INTO contacts (id, name, phone, email, birthday) "
            "VALUES (?, ?, ?, ?, ?)",
        [id, inContact.name, inContact.phone, inContact.email, inContact.birthday]
    );
  }

  Future<Contact> get(int inID) async {
    Database db = await database;
    var rec = await db.query(
        "contacts", where: "id = ?", whereArgs: [inID]
    );
    return contactFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("contacts");
    return recs.isNotEmpty
        ? recs.map((m) => contactFromMap(m)).toList()
        : [];
  }

  Future update(Contact inContact) async {
    Database db = await database;
    return await db.update("contacts", contactToMap(inContact),
        where: "id = ?", whereArgs: [inContact.id]
    );
  }

  Future delete(int inID) async {
    Database db = await database;
    return await db.delete(
        "contacts", where: "id = ?", whereArgs: [inID]
    );
  }
}
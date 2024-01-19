// import 'dart:io' as io;

// import 'package:path_provider/path_provider.dart';
// import 'package:sqf_lite/Notes.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DBHelper {
//   static Database? _db;
//   Future<Database?> get db async {
//     if (_db != null) {
//       return _db;
//     }
//     _db = await initDatabase();
//     return _db;
//   }

//   initDatabase() async {
//     io.Directory documentDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentDirectory.path, 'noted.db');
//     var db = await openDatabase(path, version: 1, onCreate: _onCreate);
//     return db;
//   }

//   _onCreate(Database db, int version) async {
//     await db.execute(
//         'CREATE TABLE employee (id INTEGER PRIMARY KEY, title TEXT NOT NULL, age INTEGER NOT NULL, description TEXT NOT NULL, email TEXT)');
//   }

//   Future<NotesModel> insert(NotesModel notesModel) async {
//     var dbClient = await db;
//     await dbClient!.insert('employee', notesModel.toMap());
//     return notesModel;
//   }

//   Future<List<NotesModel>> getNotesList() async {
//     var dbClient = await db;
//     final List<Map<String, Object?>> queryResult =
//         await dbClient!.query('employee');
//     return queryResult.map((e) => NotesModel.fromMap(e)).toList();
//   }

//   Future<int> delet(int id) async {
//     var dbClient = await db;
//     return await dbClient!.delete('employee', where: 'id = ?', whereArgs: [id]);
//   }

//   Future<int> update(NotesModel notesModel) async {
//     var dbClient = await db;
//     return await dbClient!.update('employee', notesModel.toMap(),
//         where: 'id = ?', whereArgs: [notesModel.id]);
//   }
// }
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqf_lite/Notes.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'noted.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE employee (id INTEGER PRIMARY KEY, title TEXT NOT NULL, age INTEGER NOT NULL, description TEXT NOT NULL, email TEXT)');
  }

  Future<NotesModel> insert(NotesModel notesModel) async {
    var dbClient = await db;
    notesModel.id = await dbClient!.insert('employee', notesModel.toMap());

    return notesModel;
  }

  Future<List<NotesModel>> getNotesList() async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('employee');
    return queryResult.map((e) => NotesModel.fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient!.delete('employee', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(NotesModel notesModel) async {
    var dbClient = await db;
    return await dbClient!.update('employee', notesModel.toMap(),
        where: 'id = ?', whereArgs: [notesModel.id]);
  }

  Future<void> updateWithDialog(
      BuildContext context, NotesModel notesModel) async {
    TextEditingController titleController =
        TextEditingController(text: notesModel.title);
    TextEditingController ageController =
        TextEditingController(text: notesModel.age.toString());
    TextEditingController descriptionController =
        TextEditingController(text: notesModel.description);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                notesModel.title = titleController.text;
                notesModel.age = int.tryParse(ageController.text) ?? 0;
                notesModel.description = descriptionController.text;

                await update(notesModel);

                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

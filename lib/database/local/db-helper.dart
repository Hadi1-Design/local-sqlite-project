import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  //singleton
  LocalDatabase._();
  static final LocalDatabase getInstance = LocalDatabase._();

  static final String TABLE_NOTE = "note"; //name and below are columns
  static final String COLUMN_NOTE_SNO = "s_no";
  static final String COLUMN_NOTE_TITLE = "Title";
  static final String COLUMN_NOTE_CONTENT = "Content";

  Database? myDB;

  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;
  }

  Future<Database> openDB() async {
    Directory appdir =
        await getApplicationDocumentsDirectory(); //founded the directory
    String dbpath = join(appdir.path, "noteDB.db"); //created the db file path

    return await openDatabase(
      dbpath,
      onCreate: (db, version) async {
        //first time installing app, db will not exist, so we will create it

        //create tables using create table query
        await db.execute(
          "create table ${TABLE_NOTE} (${COLUMN_NOTE_SNO} integer primary key autoincrement, ${COLUMN_NOTE_TITLE} text,${COLUMN_NOTE_CONTENT} text)",
        );
      },
      version: 1,
    );
  }

  //queries for CRUD
  //insertion
  Future<bool> adddata({required String title, required String content}) async {
    var db = await getDB();
    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: title,
      COLUMN_NOTE_CONTENT: content,
    });
    return rowsEffected > 0;
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    var db = await getDB();
    List<Map<String, dynamic>> fetcheddata = await db.query(
      TABLE_NOTE, //means select * from table
    );
    return fetcheddata;
  }

  Future<bool> updatedata({
    required String title,
    required String content,
    required int id,
  }) async {
    var db = await getDB();
    int rowEffected = await db.update(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: title,
      COLUMN_NOTE_CONTENT: content,
    }, where: '$COLUMN_NOTE_SNO = $id');
    return rowEffected > 0;
  }

  Future<bool> deletedata({required id}) async {
    var db = await getDB();
    int rowEffected = await db.delete(
      TABLE_NOTE,
      where: "$COLUMN_NOTE_SNO = ?",
      whereArgs: [
        '$id',
      ], //same work like in updatedata, but professional format of applying condition
    );
    return rowEffected > 0;
  }
}

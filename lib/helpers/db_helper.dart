import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'timetable.db'),
        onCreate: (db, version) async {
      print('here');
      await db.execute(
          'CREATE TABLE tt (hr INT PRIMARY KEY, mon TEXT , tue TEXT ,wed TEXT,thu TEXT,fri TEXT,sat TEXT)');

      for (var i = 8; i <= 17; i++) {
        await db.rawInsert('INSERT INTO tt  VALUES($i,"","","","","","")');
        print(i);
      }
      return;
    }, version: 1);
  }

  static Future<void> update(
      String table, String column, String course, int hr) async {
    final db = await DBHelper.database();
    int count = await db.rawUpdate(
      'UPDATE $table SET $column = "$course" where hr = $hr',
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }
}

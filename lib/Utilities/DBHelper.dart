import 'dart:async';
import 'dart:io' as io;
import 'package:notify/model/NotifyModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database _db;

  //Doctor Info Table
  static const String notifyid = 'notifyid';
  static const String message = 'message';

  static const String tableNotification = 'Notify_tbl';

  static const String DB_NAME = 'Notify_Db.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

//  Create Database
  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 4, onCreate: _onCreate);
    return db;
  }

// Add Tables In Database

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $tableNotification($notifyid INTEGER PRIMARY KEY AUTOINCREMENT, $message TEXT)');
  }

//Insert Record In Post Car Table

  Future<int> insertNotificationInfo(ModelNotification noti) async {
    var dbClient = await db;
    var result = await dbClient.insert(tableNotification, noti.toMap());
    return result;
  }

  Future<List<ModelNotification>> getNotificationInfoList() async {
    var notificationinfoMapList =
        await getNotifyInfoMapList(); // Get 'Map List' from database
    int count = notificationinfoMapList
        .length; // Count the number of map entries in db table

    List<ModelNotification> notiinfoList = List<ModelNotification>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      notiinfoList
          .add(ModelNotification.fromMapObject(notificationinfoMapList[i]));
    }

    return notiinfoList;
  }

  Future<int> deleteNotificationInfo(int id) async {
    var dbClient = await db;
    int result = await dbClient
        .rawDelete('DELETE FROM $tableNotification WHERE $notifyid = $id');
    return result;
  }

  Future<int> updateNotificationInfo(ModelNotification notiinfo) async {
    var dbClient = await db;
    var result = await dbClient.update(tableNotification, notiinfo.toMap(),
        where: '$notifyid = ?', whereArgs: [notiinfo.notifyid]);
    return result;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<List<Map<String, dynamic>>> getNotifyInfoMapList() async {
    var dbClient = await db;

    var result =
        await dbClient.query(tableNotification, orderBy: '$notifyid ASC');
    return result;
  }

  Future<int> getNotifyCount() async {
    var dbClient = await db;
    List<Map<String, dynamic>> x =
        await dbClient.rawQuery('SELECT COUNT (*) from $tableNotification');
    int result = Sqflite.firstIntValue(x);
    return result;
  }
}

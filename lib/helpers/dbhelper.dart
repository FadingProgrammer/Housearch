import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Future<Database> initDb() async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, "data.db");

    // final exist = await databaseExists(dbpath);
    // if (exist) {
    //   // database already exists
    //   // open database
    //   // print("db already exsits");
    //   return await openDatabase(path);
    // } else {
    //   // db does not exist create a new one
    //   // print("creating a copy from assets");
    //   try {
    //     await Directory(dirname(path)).create(recursive: true);
    //   } catch (_) {}
    ByteData data = await rootBundle.load(join("assets", "data.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await File(path).writeAsBytes(bytes, flush: true);
    // print("db copied");
    // }
    return await openDatabase(path);
  }
}

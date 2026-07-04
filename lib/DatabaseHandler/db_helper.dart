import 'package:pointycastle/export.dart';
import 'package:projet_blockchain/Model/user.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

class DbHelper {
  static const String dbName = 'test.db';
  static const String tableUser = 'user';
  static const int version = 1;

  static const String columnUserName = 'userName';
  static const String columnPassword = 'password';
  static const String columnPublicKeyModulus = 'publicKeyModulus';
  static const String columnPublicKeyExponent = 'publicKeyExponent';
  static const String columnPrivateKeyModulus = 'privateKeyModulus';
  static const String columnPrivateKeyExponent = 'privateKeyExponent';
  static const String columnPrivateKeyComponentP = 'privateKeyComponentP';
  static const String columnPrivateKeyComponentQ = 'privateKeyComponentQ';

  static final DbHelper instance = DbHelper._internal();
  //static DbHelper get instance => _instance;
  static Database? _db; // initially

  DbHelper._internal();

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await _initDb();
    return _db;
  }

  _initDb() async {
    return await openDatabase(join(await getDatabasesPath(), dbName),
        version: version, onCreate: _onCreate);
  }

  _onCreate(Database db, int intVersion) async {
    await db.execute("CREATE TABLE $tableUser ("
        " $columnUserName TEXT, "
        " $columnPassword TEXT, "
        "$columnPublicKeyModulus TEXT,"
        "$columnPublicKeyExponent TEXT,"
        "$columnPrivateKeyModulus TEXT,"
        "$columnPrivateKeyExponent TEXT,"
        "$columnPrivateKeyComponentP TEXT,"
        "$columnPrivateKeyComponentQ TEXT,"
        " PRIMARY KEY ($columnUserName)"
        ")");
  }

  //enregistrer les donnée de l'utilisateur dans la bdd
  Future<int?> insert(User user) async {
    Database? database = await instance.db;
    print("insert : $database");
    var res = await database?.insert(tableUser, user.toMap());
    return res;
  }

  // select a user from the db based on his email adrress
  Future<User?> getUser(String userName, String password) async {
    Database? database = await instance.db;
    print("database location : $database");
    var maps = await database?.query(tableUser,
        columns: [
          columnUserName,
          columnPassword,
          columnPublicKeyModulus,
          columnPublicKeyExponent,
          columnPrivateKeyModulus,
          columnPrivateKeyExponent,
          columnPrivateKeyComponentP,
          columnPrivateKeyComponentQ
        ],
        where: '$columnUserName = ? and $columnPassword = ?',
        whereArgs: [userName, password]);
    if (maps != null) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>?> getKeyPair(
      String userName, String password) async {
    Database? database = await instance.db;
    print("database location : $database");
    var maps = await database?.query(tableUser,
        columns: [
          columnPublicKeyModulus,
          columnPublicKeyExponent,
          columnPrivateKeyModulus,
          columnPrivateKeyExponent,
          columnPrivateKeyComponentP,
          columnPrivateKeyComponentQ
        ],
        where: '$columnUserName = ? and $columnPassword = ?',
        whereArgs: [userName, password]);

    return null;
  }

  Future<List<String>> getUsername() async {
    Database? database = await instance.db;
    var result = await database?.query(tableUser, columns: [columnUserName]);

    return result?.map((map) => map[columnUserName] as String).toList() ?? [];
  }

  Future<int> delete(String userName) async {
    Database? database = await instance.db;
    print("delete : $database");
    return await database!
        .delete(tableUser, where: '$columnUserName = ?', whereArgs: [userName]);
  }
}

import 'package:sqflite/sqflite.dart';

class Sqlite {
  static Future<Database> initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = '$databasesPath/mylibrary.db';

    Database dbInstance = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE mybooks (id TEXT PRIMARY KEY, title TEXT,author TEXT,thumbnail TEXT,link TEXT,publisher TEXT,info TEXT,format TEXT,description TEXT)');
    });
    return dbInstance;
  }
}

class MyBook {
  final String id;
  final String title;
  final String? author;
  final String? thumbnail;
  final String link;
  final String? publisher;
  final String? info;
  final String? description;
  final String? format;

  MyBook(
      {required this.id,
      required this.title,
      required this.author,
      required this.thumbnail,
      required this.link,
      required this.publisher,
      required this.info,
      required this.format,
      required this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'thumbnail': thumbnail,
      'link': link,
      'publisher': publisher,
      'info': info,
      'format': format,
      'description': description
    };
  }

  @override
  String toString() {
    return 'MyBook{id: $id,title: $title,author: $author,thumbnail: $thumbnail,link: $link,publisher: $publisher,info: $info,format: $format,description:$description}';
  }
}

class MyLibraryDb {
  Database dbInstance;
  String tableName = 'mybooks';

  MyLibraryDb({required this.dbInstance});

  Future<void> insert(MyBook book) async {
    await dbInstance.insert(
      tableName,
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    await dbInstance.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<MyBook?> getId(String id) async {
    List<Map<String, dynamic>> data =
        await dbInstance.query(tableName, where: 'id = ?', whereArgs: [id]);
    List<MyBook> book = listMapToMyBook(data);
    if (book.isNotEmpty) {
      return book.first;
    }
    return null;
  }

  Future<bool> checkIdExists(String id) async {
    List<Map<String, dynamic>> data =
        await dbInstance.query(tableName, where: 'id = ?', whereArgs: [id]);
    List<MyBook> book = listMapToMyBook(data);
    if (book.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<List<MyBook>> getAll() async {
    final List<Map<String, dynamic>> maps = await dbInstance.query(tableName);
    return listMapToMyBook(maps);
  }

  List<MyBook> listMapToMyBook(List<Map<String, dynamic>> maps) {
    List<MyBook> myBookList = List.generate(maps.length, (i) {
      return MyBook(
          id: maps[i]['id'],
          title: maps[i]['title'],
          author: maps[i]['author'],
          thumbnail: maps[i]['thumbnail'],
          link: maps[i]['link'],
          publisher: maps[i]['publisher'],
          info: maps[i]['info'],
          format: maps[i]['format'],
          description: maps[i]['description']);
    });
    return myBookList.reversed.toList();
  }
}
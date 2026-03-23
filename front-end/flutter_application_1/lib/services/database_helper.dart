import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  DatabaseHelper._init();

  Future<Database> get database async { // Verifica se o banco já foi inicializado, se não, inicializa
    if (_database != null) return _database!;
    _database = await _initDB('phone_numbers.db'); // iniciou o banco
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); // encontrou um local seguro no sistema
    final path = join(dbPath, filePath); // Une as pastas como node

    return await openDatabase(path, version: 1, onCreate: _createDB); // abre o db
  }

  Future _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE historico (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero TEXT NOT NULL,
        data_hora TEXT NOT NULL
      )
    '''); // Cria a tabela
  }

  Future<int> registrarChamada(String numero) async {
    final db = await instance.database;
    return await db.insert('historico', {
      'numero': numero,
      'data_hora': DateTime.now().toIso8601String(), // salva data como string
    });
  }

  Future<List<Map<String, dynamic>>> getCallList() async{
    final db = await instance.database;

    return await db.query('historico', orderBy: 'id DESC');
  }

  Future<int> deleteCall(int id) async{
    final db = await instance.database;
    return await db.delete(
      'historico',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contatoTable = "contatoTable";
final String idColumn = "idColumn";
final String nomeColumn = "nomeColumn";
final String emailColumn = "emailColumn";
final String telefoneColumn = "telefoneColumn";
final String imagemColumn = "imagemColumn";

class ContatoHelper {
  static final ContatoHelper _instance = ContatoHelper.internal();

  factory ContatoHelper() => _instance;

  ContatoHelper.internal();

  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await initDatabase();
      return _database;
    }
  }

  Future<Database> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contato.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newVersion) async {
      await db.execute(
          "CREATE TABLE $contatoTable($idColumn INTEGER PRIMARY KEY, $nomeColumn TEXT, "
          "$emailColumn TEXT, $telefoneColumn TEXT, $imagemColumn TEXT)");
    });
  }

  Future<Contato> saveContato(Contato contato) async {
    Database dbContato = await database;
    contato.id = await dbContato.insert(contatoTable, contato.toMap());
    return contato;
  }

  Future<Contato> getContato(int id) async {
    Database dbContato = await database;
    List<Map> maps = await dbContato.query(contatoTable,
        columns: [
          idColumn,
          nomeColumn,
          emailColumn,
          telefoneColumn,
          imagemColumn
        ],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if(maps.length > 0){
      return Contato.fromMap(maps.first);
    }else{
      return null;
    }
  }

  Future<int> deleteContato(int id) async{
    Database dbContato = await database;
    return await dbContato.delete(contatoTable,
        where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContato(Contato contato) async{
    Database dbContato = await database;
    return await dbContato.update(contatoTable,
        contato.toMap(), where: "$idColumn = ?", whereArgs: [contato.id]);
  }

  Future<List> getAllContato() async{
    Database dbContato = await database;
    List listMap = await dbContato.rawQuery("SELECT * FROM $contatoTable");
    List<Contato> listContato = List();
    for(Map m in listMap){
      listContato.add(Contato.fromMap(m));
    }
    return listContato;
  }

  Future<int> getQuantidade() async{
    Database dbContato = await database;
    return Sqflite.firstIntValue(await dbContato.rawQuery("SELECT COUNT(*) FROM $contatoTable"));
  }

  Future close() async{
    Database dbContato = await database;
    dbContato.close();
  }


}

class Contato {
  int id;
  String nome;
  String email;
  String telefone;
  String imagem;

  Contato();

  //Construtor
  Contato.fromMap(Map map) {
    id = map[idColumn];
    nome = map[nomeColumn];
    email = map[emailColumn];
    telefone = map[telefoneColumn];
    imagem = map[imagemColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeColumn: nome,
      emailColumn: email,
      telefoneColumn: telefone,
      imagemColumn: imagem
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contato(id: $id, nome: $nome, email: $email, telefone: $telefone, imagem: $imagem)";
  }
}

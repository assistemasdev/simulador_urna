import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';

final String vereadorTable = "vereadorTable";
// Colunas vereador
final String idvereadorTable = "idvereadorTable";
final String numerovereadorTable = "numerovereadorTable";
final String nomevereadorTable = "nomevereadorTable";
final String partidovereadorTable = "partidovereadorTable";
// Fim
final String prefeitoTable = "prefeitoTable";
// Colunas prefeito
final String idprefeitoTable = "idprefeitoTable";
final String numeroprefeitoTable = "numeroprefeitoTable";
final String nomeprefeitoTable = "nomeprefeitoTable";
final String partidoprefeitoTable = "partidoprefeitoTable";
// Fim
final String votosTable = "votosTable";
// Coluna votos
final String idVoto = "idVoto";
final String votoVereador = "votoVereador";
final String votoPrefeito = "votoPrefeito";

// Fim
class UrnaHelper {
  static final UrnaHelper _instance = UrnaHelper.internal();

  factory UrnaHelper() => _instance;

  UrnaHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "urna_eletronica.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $vereadorTable($idvereadorTable INTEGER PRIMARY KEY, $numerovereadorTable TEXT, $nomevereadorTable TEXT,"
          "$partidovereadorTable TEXT)");
      await db.execute(
          "CREATE TABLE $prefeitoTable($idprefeitoTable INTEGER PRIMARY KEY, $numeroprefeitoTable TEXT, $nomeprefeitoTable TEXT,"
          "$partidoprefeitoTable TEXT)");
      await db.execute(
          "CREATE TABLE $votosTable($idVoto PRIMARY KEY, $votoVereador TEXT, $votoPrefeito TEXT)");
    });
  }

  Future<VereadorData> saveVereador(VereadorData vereador) async {
    Database dbUrna = await db;
    vereador.id = await dbUrna.insert(vereadorTable, vereador.toMap());
    return vereador;
  }

  Future<List> getAllVereadores() async {
    Database dbUrna = await db;
    List listMap = await dbUrna.rawQuery("SELECT * FROM $vereadorTable");
    List<VereadorData> listVereador = List();
    for (Map m in listMap) {
      listVereador.add(VereadorData.fromMap(m));
    }
    return listVereador;
  }

  Future<PrefeitoData> savePrefeito(PrefeitoData prefeito) async {
    Database dbUrna = await db;
    prefeito.id = await dbUrna.insert(prefeitoTable, prefeito.toMap());
    return prefeito;
  }

  Future<List> getAllPrefeitos() async {
    Database dbUrna = await db;
    List listMap = await dbUrna.rawQuery("SELECT * FROM $prefeitoTable");
    List<PrefeitoData> listPrefeito = List();
    for (Map m in listMap) {
      listPrefeito.add(PrefeitoData.fromMap(m));
    }
    return listPrefeito;
  }

  Future<Votos> saveVotos(Votos voto) async {
    Database dbUrna = await db;
    voto.id = await dbUrna.insert(votosTable, voto.toMap());
    return voto;
  }

  Future<List> getAllVotos() async {
    Database dbUrna = await db;
    List listMap = await dbUrna.rawQuery("SELECT * FROM $votosTable");
    List<Votos> listVotos = List();
    for (Map m in listMap) {
      listVotos.add(Votos.fromMap(m));
    }
    return listVotos;
  }

  Future<File> _getCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/votos.csv');
  }

  Future<File> createCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    if (directory != null) {
      return File('${directory.path}/votos.csv').create(recursive: true);
    } else {
      return File('${directory.path}/votos.csv');
    }
  }

  query() async {
    Database dbUrna = await db;
    var result = await dbUrna
        .rawQuery("SELECT $votoVereador, $votoPrefeito FROM $votosTable");
    var csv = mapListToCsv(result);
    final file = await _getCSV();
    return file.writeAsString(csv);
  }

  deleteQuery() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("DELETE FROM $votosTable"));
  }

  deleteFile() async {
    final directory = await getApplicationDocumentsDirectory();
    directory.deleteSync(recursive: true);
  }

  /// Convert a map list to csv
  String mapListToCsv(List<Map<String, dynamic>> mapList,
      {ListToCsvConverter converter}) {
    if (mapList == null) {
      return null;
    }
    converter ??= const ListToCsvConverter();
    var data = <List>[];
    var keys = <String>[];
    var keyIndexMap = <String, int>{};

    // Add the key and fix previous records
    int _addKey(String key) {
      var index = keys.length;
      keyIndexMap[key] = index;
      keys.add(key);
      for (var dataRow in data) {
        dataRow.add(null);
      }
      return index;
    }

    for (var map in mapList) {
      // This list might grow if a new key is found
      var dataRow = List(keyIndexMap.length);
      // Fix missing key
      map.forEach((key, value) {
        var keyIndex = keyIndexMap[key];
        if (keyIndex == null) {
          // New key is found
          // Add it and fix previous data
          keyIndex = _addKey(key);
          // grow our list
          dataRow = List.from(dataRow, growable: true)..add(value);
        } else {
          dataRow[keyIndex] = value;
        }
      });
      data.add(dataRow);
    }
    return converter.convert(<List>[]
      ..add(keys)
      ..addAll(data));
  }

  Future close() async {
    Database dbUrna = await db;
    dbUrna.close();
  }
}

class VereadorData {
  int id;
  String numero;
  String nome;
  String partido;

  VereadorData();

  VereadorData.fromMap(Map map) {
    id = map[idvereadorTable];
    numero = map[numerovereadorTable];
    nome = map[nomevereadorTable];
    partido = map[partidovereadorTable];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      numerovereadorTable: numero,
      nomevereadorTable: nome,
      partidovereadorTable: partido
    };
    if (id != null) {
      map[idvereadorTable] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Vereadores(id: $id, numero: $numero, nome: $nome, partido: $partido)";
  }
}

class PrefeitoData {
  int id;
  String numero;
  String nome;
  String partido;

  PrefeitoData();

  PrefeitoData.fromMap(Map map) {
    id = map[idprefeitoTable];
    numero = map[numeroprefeitoTable];
    nome = map[nomeprefeitoTable];
    partido = map[partidoprefeitoTable];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      numeroprefeitoTable: numero,
      nomeprefeitoTable: nome,
      partidoprefeitoTable: partido
    };
    if (id != null) {
      map[idprefeitoTable] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Prefeito(id: $id, numero: $numero, nome: $nome, partido: $partido)";
  }
}

class Votos {
  int id;
  String vereador;
  String prefeito;

  Votos();

  Votos.fromMap(Map map) {
    id = map[idVoto];
    vereador = map[votoVereador];
    prefeito = map[votoPrefeito];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      votoVereador: vereador,
      votoPrefeito: prefeito,
    };
    if (id != null) {
      map[idVoto] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Prefeito(id: $id, vereador: $vereador, prefeito: $prefeito)";
  }
}

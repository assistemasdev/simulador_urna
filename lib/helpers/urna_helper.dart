import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';
import 'package:urna_eletronica/config/election_config.dart';

final String votosTable = "votosTable";
final String idVoto = "idVoto";
final String dataVotoColumn = "dataVoto"; // NOVO: coluna de data

// Colunas para eleições municipais (mantidas para compatibilidade)
final String votoVereador = "votoVereador";
final String votoPrefeito = "votoPrefeito";

// Colunas para eleições gerais (novas)
final String votoDeputadoFederal = "votoDeputadoFederal";
final String votoDeputadoEstadual = "votoDeputadoEstadual";
final String votoSenador = "votoSenador";
final String votoGovernador = "votoGovernador";
final String votoPresidente = "votoPresidente";
final String enderecoPesquisaColumn = "endereco_pesquisa"; // NOVO: coluna do local/endereço da pesquisa

class UrnaHelper {
  static final UrnaHelper _instance = UrnaHelper.internal();

  factory UrnaHelper() => _instance;

  UrnaHelper.internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "urna_eletronica.db");

    return await openDatabase(
      path,
      version: 4, // v1: antigo, v2: cargos novos, v3: coluna dataVoto, v4: coluna endereco_pesquisa
      onCreate: (Database db, int version) async {
        await _createAllTables(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await _migrateToVersion2(db);
        }
        if (oldVersion < 3) {
          await _migrateToVersion3(db);
        }
        if (oldVersion < 4) {
          await _migrateToVersion4(db);
        }
      }
    );
  }

  Future<void> _createAllTables(Database db) async {
    await db.execute('''
      CREATE TABLE $votosTable(
        $idVoto INTEGER PRIMARY KEY AUTOINCREMENT,
        $dataVotoColumn TEXT,
        $enderecoPesquisaColumn TEXT,
        $votoVereador TEXT,
        $votoPrefeito TEXT,
        $votoDeputadoFederal TEXT,
        $votoDeputadoEstadual TEXT,
        $votoSenador TEXT,
        $votoGovernador TEXT,
        $votoPresidente TEXT
      )
    ''');
  }

  Future<void> _migrateToVersion2(Database db) async {
    try {
      await db.execute("ALTER TABLE $votosTable ADD COLUMN $votoDeputadoFederal TEXT");
    } catch (e) {}
    
    try {
      await db.execute("ALTER TABLE $votosTable ADD COLUMN $votoDeputadoEstadual TEXT");
    } catch (e) {}
    
    try {
      await db.execute("ALTER TABLE $votosTable ADD COLUMN $votoSenador TEXT");
    } catch (e) {}
    
    try {
      await db.execute("ALTER TABLE $votosTable ADD COLUMN $votoGovernador TEXT");
    } catch (e) {}
    
    try {
      await db.execute("ALTER TABLE $votosTable ADD COLUMN $votoPresidente TEXT");
    } catch (e) {}
  }

  /// Migração v2 -> v3: adiciona coluna dataVoto em bancos antigos
  Future<void> _migrateToVersion3(Database db) async {
    try {
      await db.execute("ALTER TABLE $votosTable ADD COLUMN $dataVotoColumn TEXT");
    } catch (e) {}
  }

  /// Migração v3 -> v4: adiciona coluna endereco_pesquisa em bancos antigos.
  /// Sem essa coluna, saveVoto() falhava ao tentar inserir uma chave que
  /// não existe na tabela, e NENHUM voto era salvo (INSERT falha por completo).
  Future<void> _migrateToVersion4(Database db) async {
    try {
      await db.execute("ALTER TABLE $votosTable ADD COLUMN $enderecoPesquisaColumn TEXT");
    } catch (e) {}
  }

  /// Salva um voto genérico. Adiciona a data/hora automaticamente.
  Future<void> saveVoto(Map<String, String> votos) async {
    Database dbUrna = await db;
    final Map<String, String> dados = Map<String, String>.from(votos);
    dados[dataVotoColumn] = DateTime.now().toIso8601String();
    await dbUrna.insert(votosTable, dados);
  }

  /// Método legado para compatibilidade
  Future<void> saveVotos(Votos voto) async {
    Database dbUrna = await db;
    await dbUrna.insert(votosTable, voto.toMap());
  }

  /// Retorna todos os votos (mais recentes primeiro)
  Future<List<Map<String, dynamic>>> getAllVotos() async {
    Database dbUrna = await db;
    return await dbUrna.rawQuery(
      "SELECT * FROM $votosTable ORDER BY $idVoto DESC"
    );
  }

  /// APAGAR TODOS OS VOTOS — usado pelo FAB e dashboard
  Future<void> deleteAllVotos() async {
    Database dbUrna = await db;
    await dbUrna.delete(votosTable);
    
    // Remove também o relatório antigo (se existir)
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/relatorio_votos.txt');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Se der erro ao apagar o arquivo, não impede a operação principal
    }
  }

  Future<File> _getCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/votos.csv');
  }

  Future<File> createCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/votos.csv').create(recursive: true);
  }

  /// Exporta votos para CSV baseado na eleição atual (legado, mantido)
  query() async {
    Database dbUrna = await db;
    final cargos = ElectionConfig.getCargosAtivos();
    
    List<String> columns = cargos.map((c) => c.tableVotos).toList();
    String columnsStr = columns.join(', ');
    
    var result = await dbUrna.rawQuery("SELECT $columnsStr FROM $votosTable");
    
    var csv = mapListToCsv(result);
    final file = await _getCSV();
    return file.writeAsString(csv);
  }

  /// Método legado — preferir usar deleteAllVotos()
  deleteQuery() async {
    Database dbContact = await db;
    return await dbContact.rawQuery("DELETE FROM $votosTable");
  }

  deleteFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/votos.csv');
    if (await file.exists()) {
      await file.delete();
    }
  }

  String mapListToCsv(List<Map<String, dynamic>> mapList, {Csv? converter}) {
    converter ??= Csv();
    var data = <List>[];
    var keys = <String>[];
    var keyIndexMap = <String, int>{};

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
      var dataRow = List<dynamic>.filled(keyIndexMap.length, null);
      map.forEach((key, value) {
        var keyIndex = keyIndexMap[key];
        if (keyIndex == null) {
          keyIndex = _addKey(key);
          dataRow = List.from(dataRow, growable: true)..add(value);
        } else {
          dataRow[keyIndex] = value;
        }
      });
      data.add(dataRow);
    }
    return converter.encode(<List>[]
      ..add(keys)
      ..addAll(data));
  }

  Future close() async {
    Database dbUrna = await db;
    dbUrna.close();
  }
}

/// Classe legada para compatibilidade (não mais usada no fluxo principal)
class Votos {
  int? id;
  String? vereador;
  String? prefeito;

  Votos();

  Votos.fromMap(Map map) {
    id = map[idVoto];
    vereador = map[votoVereador];
    prefeito = map[votoPrefeito];
  }

  Map<String, dynamic> toMap() {
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
    return "Votos(id: $id, vereador: $vereador, prefeito: $prefeito)";
  }
}

/// Classe para voto genérico (nova)
class VotoGenerico {
  int? id;
  Map<String, String>? votos;

  VotoGenerico({this.id, this.votos});

  VotoGenerico.fromMap(Map<String, dynamic> map) {
    id = map[idVoto];
    votos = {};
    map.forEach((key, value) {
      if (key != idVoto && value != null) {
        votos![key] = value.toString();
      }
    });
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (id != null) {
      map[idVoto] = id;
    }
    map.addAll(votos ?? {});
    return map;
  }

  @override
  String toString() {
    return "VotoGenerico(id: $id, votos: $votos)";
  }
}
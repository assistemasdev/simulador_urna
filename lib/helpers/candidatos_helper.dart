import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:urna_eletronica/model/candidato.dart';

class CandidatosHelper {
  static final CandidatosHelper _instance = CandidatosHelper.internal();
  factory CandidatosHelper() => _instance;
  CandidatosHelper.internal();

  // Dois arquivos separados
  static const String CSV_PRESIDENTE = 'assets/csv/presevice_novo.csv';
  static const String CSV_GOVSENDEP = 'assets/csv/govsendep_novo.csv';

  List<Candidato>? _cache;

  String _normalizarNumero(String s) {
    String n = s.trim();
    while (n.length > 1 && n.startsWith('0')) {
      n = n.substring(1);
    }
    return n;
  }

  String _limpar(String s) => s.toString().trim();

  /// Carrega TODOS os candidatos dos dois arquivos
  Future<List<Candidato>> carregarTodos() async {
    if (_cache != null) return _cache!;

    final lista = <Candidato>[];

    // Carrega Presidente e Vice-Presidente
    lista.addAll(await _carregarDeArquivo(CSV_PRESIDENTE));

    // Carrega Governador, Senador, Deputados e Suplentes
    lista.addAll(await _carregarDeArquivo(CSV_GOVSENDEP));

    print('[CSV] ✅ Total geral de candidatos carregados: ${lista.length}');
    return _cache = lista;
  }

  /// Método interno que faz o parse de um arquivo CSV específico
  Future<List<Candidato>> _carregarDeArquivo(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      final Uint8List bytes = data.buffer.asUint8List();

      String raw;
      try {
        raw = utf8.decode(bytes);
        if (raw.startsWith('\ufeff')) {
          raw = raw.substring(1);
        }
      } catch (e) {
        print('[CSV] Arquivo não é UTF-8 estrito. Usando fallback para Latin-1...');
        raw = latin1.decode(bytes);
      }

      // Normaliza quebras de linha
      raw = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      // Detecta o delimitador
      final primeiraLinha = raw.split('\n').first;
      final int semis = ';'.allMatches(primeiraLinha).length;
      final int tabs = '\t'.allMatches(primeiraLinha).length;
      final String fieldDelimiter = (tabs > semis) ? '\t' : ';';

      final linhas = CsvToListConverter(
        fieldDelimiter: fieldDelimiter,
        textDelimiter: '"',
        eol: '\n',
        shouldParseNumbers: false,
        allowInvalid: true,
      ).convert(raw);

      if (linhas.isEmpty) return <Candidato>[];

      final header = linhas.first.map((e) => _limpar(e.toString())).toList();
      final iCargo = header.indexOf('DS_CARGO');
      final iSq = header.indexOf('SQ_CANDIDATO');
      final iNumero = header.indexOf('NR_CANDIDATO');
      final iNome = header.indexOf('NM_URNA_CANDIDATO');
      final iPartido = header.indexOf('SG_PARTIDO');

      final listaArquivo = <Candidato>[];
      for (var i = 1; i < linhas.length; i++) {
        final l = linhas[i];
        if (l.isEmpty) continue;

        String valor(int idx) =>
            (idx < 0 || idx >= l.length) ? '' : _limpar(l[idx].toString());

        final cargo = valor(iCargo).toUpperCase();
        final numero = _normalizarNumero(valor(iNumero));
        if (cargo.isEmpty || numero.isEmpty) continue;

        listaArquivo.add(Candidato(
          cargo: cargo,
          sqCandidato: valor(iSq),
          numero: numero,
          nome: valor(iNome),
          partido: valor(iPartido),
        ));
      }

      print('[CSV] ✅ Carregados ${listaArquivo.length} candidatos de $path');
      return listaArquivo;
    } catch (e, st) {
      print('[CSV] ❌ ERRO ao carregar $path: $e');
      print(st);
      return <Candidato>[];
    }
  }

  /// Busca um candidato pelo cargo e número
  Future<Candidato?> buscar(String dsCargo, String numero) async {
    final todos = await carregarTodos();
    final numNorm = _normalizarNumero(numero);
    for (final c in todos) {
      if (c.cargo == dsCargo && c.numero == numNorm) return c;
    }
    return null;
  }

  /// Busca o Vice correto (Presidente → Vice-Presidente, Governador → Vice-Governador)
  Future<Candidato?> buscarVice(String numero, String cargoPrincipal) async {
    final todos = await carregarTodos();
    final numNorm = _normalizarNumero(numero);

    String cargoViceEsperado = '';
    if (cargoPrincipal == 'PRESIDENTE') {
      cargoViceEsperado = 'VICE-PRESIDENTE';
    } else if (cargoPrincipal == 'GOVERNADOR') {
      cargoViceEsperado = 'VICE-GOVERNADOR';
    } else {
      return null;
    }

    for (final c in todos) {
      if (c.cargo == cargoViceEsperado && c.numero == numNorm) return c;
    }
    return null;
  }
}
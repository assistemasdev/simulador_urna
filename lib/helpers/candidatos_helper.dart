import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:urna_eletronica/model/candidato.dart';

class CandidatosHelper {
  static final CandidatosHelper _instance = CandidatosHelper.internal();
  factory CandidatosHelper() => _instance;
  CandidatosHelper.internal();

  static const String CSV_PATH = 'assets/csv/candidatos.csv';
  List<Candidato>? _cache;

  String _normalizarNumero(String s) {
    String n = s.trim();
    while (n.length > 1 && n.startsWith('0')) {
      n = n.substring(1);
    }
    return n;
  }

  String _limpar(String s) => s.toString().trim();

  Future<List<Candidato>> carregarTodos() async {
    if (_cache != null) return _cache!;

    try {
      final ByteData data = await rootBundle.load(CSV_PATH);
      final Uint8List bytes = data.buffer.asUint8List();

      String raw;
      try {
        raw = utf8.decode(bytes);
      } catch (_) {
        raw = latin1.decode(bytes);
      }

      if (raw.startsWith('\ufeff')) raw = raw.substring(1);
      raw = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

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

      if (linhas.isEmpty) return _cache = <Candidato>[];

      final header = linhas.first.map((e) => _limpar(e.toString())).toList();
      final iCargo = header.indexOf('DS_CARGO');
      final iSq = header.indexOf('SQ_CANDIDATO');
      final iNumero = header.indexOf('NR_CANDIDATO');
      final iNome = header.indexOf('NM_URNA_CANDIDATO');
      final iPartido = header.indexOf('SG_PARTIDO');

      final lista = <Candidato>[];
      for (var i = 1; i < linhas.length; i++) {
        final l = linhas[i];
        if (l == null || l.isEmpty) continue;

        String valor(int idx) => (idx < 0 || idx >= l.length) ? '' : _limpar(l[idx].toString());

        final cargo = valor(iCargo).toUpperCase();
        final numero = _normalizarNumero(valor(iNumero));
        if (cargo.isEmpty || numero.isEmpty) continue;

        lista.add(Candidato(
          cargo: cargo,
          sqCandidato: valor(iSq),
          numero: numero,
          nome: valor(iNome),
          partido: valor(iPartido),
        ));
      }

      print('[CSV] ✅ Total de candidatos carregados: ${lista.length}');
      return _cache = lista;
    } catch (e, st) {
      print('[CSV] ❌ ERRO ao carregar: $e');
      print(st);
      return _cache = <Candidato>[];
    }
  }

  Future<Candidato?> buscar(String dsCargo, String numero) async {
    final todos = await carregarTodos();
    final numNorm = _normalizarNumero(numero);
    for (final c in todos) {
      if (c.cargo == dsCargo && c.numero == numNorm) return c;
    }
    return null;
  }

  // Lógica dinâmica para buscar o Vice correto
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
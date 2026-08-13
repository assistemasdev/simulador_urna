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

  List<Candidato> _cache;

  String _normalizarNumero(String s) {
    if (s == null) return '';
    String n = s.trim();
    while (n.length > 1 && n.startsWith('0')) {
      n = n.substring(1);
    }
    return n;
  }

  String _limpar(String s) => (s ?? '').toString().trim();

  Future<List<Candidato>> carregarTodos() async {
    if (_cache != null) return _cache;

    try {
      // Lê como BYTES: arquivos TSE são Latin-1, loadString() quebra em UTF-8
      final ByteData data = await rootBundle.load(CSV_PATH);
      final Uint8List bytes = data.buffer.asUint8List();

      String raw;
      try {
        raw = utf8.decode(bytes);
        print('[CSV] Encoding: UTF-8');
      } catch (_) {
        raw = latin1.decode(bytes);
        print('[CSV] Encoding: Latin-1 ✅');
      }

      if (raw.startsWith('\ufeff')) raw = raw.substring(1);
      raw = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      final primeiraLinha = raw.split('\n').first;
      final int semis = ';'.allMatches(primeiraLinha).length;
      final int tabs = '\t'.allMatches(primeiraLinha).length;
      final String fieldDelimiter = (tabs > semis) ? '\t' : ';';
      print('[CSV] Separador: "$fieldDelimiter" (;=$semis, TAB=$tabs)');

      final linhas = CsvToListConverter(
        fieldDelimiter: fieldDelimiter,
        textDelimiter: '"',
        eol: '\n',
        shouldParseNumbers: false,
        allowInvalid: true,
      ).convert(raw);

      print('[CSV] Linhas: ${linhas.length}');
      if (linhas.isEmpty) return _cache = <Candidato>[];

      final header = linhas.first.map((e) => _limpar(e.toString())).toList();
      final iCargo = header.indexOf('DS_CARGO');
      final iSq = header.indexOf('SQ_CANDIDATO');
      final iNumero = header.indexOf('NR_CANDIDATO');
      final iNome = header.indexOf('NM_URNA_CANDIDATO');
      final iPartido = header.indexOf('SG_PARTIDO');
      print('[CSV] Índices: cargo=$iCargo sq=$iSq num=$iNumero nome=$iNome part=$iPartido');

      if (iNumero < 0 || iCargo < 0) {
        print('[CSV] ❌ Coluna não encontrada! Cabeçalho: $header');
        return _cache = <Candidato>[];
      }

      final lista = <Candidato>[];
      for (var i = 1; i < linhas.length; i++) {
        final l = linhas[i];
        if (l == null || l.isEmpty) continue;

        String valor(int idx) =>
            (idx == null || idx < 0 || idx >= l.length) ? '' : _limpar(l[idx].toString());

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

      print('[CSV] ✅ Candidatos carregados: ${lista.length}');
      final sued = lista.where((c) => c.numero == '8080').toList();
      if (sued.isNotEmpty) {
        print('[CSV] 🎯 Teste 8080: ${sued.first.nome} / ${sued.first.cargo}');
      } else {
        print('[CSV] ⚠️ 8080 NÃO está na lista parseada!');
      }

      return _cache = lista;
    } catch (e, st) {
      // QUALQUER erro cai aqui e aparece no console
      print('[CSV] ❌ ERRO FATAL ao carregar: $e');
      print(st);
      return _cache = <Candidato>[];
    }
  }

  Future<Candidato> buscar(String dsCargo, String numero) async {
    final todos = await carregarTodos();
    final numNorm = _normalizarNumero(numero);
    print('[BUSCA] "$dsCargo" / "$numNorm" entre ${todos.length} candidatos');
    for (final c in todos) {
      if (c.cargo == dsCargo && c.numero == numNorm) return c;
    }
    return null;
  }

  Future<Candidato> buscarVice(String numero) async {
    final todos = await carregarTodos();
    final numNorm = _normalizarNumero(numero);
    for (final c in todos) {
      if (c.cargo == 'VICE-GOVERNADOR' && c.numero == numNorm) return c;
    }
    return null;
  }
}
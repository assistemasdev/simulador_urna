import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:urna_eletronica/config/election_config.dart';
import 'package:urna_eletronica/helpers/urna_helper.dart';
import 'package:urna_eletronica/helpers/candidatos_helper.dart';

/// Gera o relatório de votação (resumo + detalhamento) para compartilhamento.
class RelatorioHelper {
  static final RelatorioHelper _instance = RelatorioHelper.internal();
  factory RelatorioHelper() => _instance;
  RelatorioHelper.internal();

  final UrnaHelper _helper = UrnaHelper();

  /// Gera o arquivo do relatório (.txt) pronto para enviar
  Future<File> gerarRelatorio() async {
    final votos = await _helper.getAllVotos();
    final cronologico = votos.reversed.toList(); // mais antigo primeiro
    final candidatos = await _carregarCandidatos();
    final cargos = ElectionConfig.getCargosAtivos();

    final sb = StringBuffer();

    // ===== CABEÇALHO =====
    sb.writeln('RELATORIO DE VOTACAO');
    sb.writeln('Gerado em: ${_formatarData(DateTime.now().toIso8601String())}');
    sb.writeln('Total de votos: ${votos.length}');
    sb.writeln();

    // ===== RESUMO POR CARGO (QUANTIDADE DE VOTOS) =====
    for (final cargo in cargos) {
      sb.writeln('--- ${cargo.nome.toUpperCase()} ---');

      final contagem = <String, int>{};
      for (final voto in votos) {
        final numero = voto[cargo.tableVotos] == null
            ? ''
            : voto[cargo.tableVotos].toString();
        contagem[numero] = (contagem[numero] ?? 0) + 1;
      }

      if (contagem.isEmpty) {
        sb.writeln('(nenhum voto)');
      } else {
        // Ordena do mais votado pro menos votado
        final ordenados = contagem.keys.toList()
          ..sort((a, b) => contagem[b].compareTo(contagem[a]));
        for (final numero in ordenados) {
          sb.writeln(
              '${_descreverVoto(candidatos[cargo.cargo], numero)}: ${contagem[numero]} voto(s)');
        }
      }
      sb.writeln();
    }

    // ===== DETALHAMENTO (DATA DE CADA VOTO) =====
    sb.writeln('--- DETALHAMENTO (DATA DE CADA VOTO) ---');
    for (final voto in cronologico) {
      final partes = <String>[];
      for (final cargo in cargos) {
        final numero = voto[cargo.tableVotos] == null
            ? ''
            : voto[cargo.tableVotos].toString();
        partes.add('${cargo.nome}: ${numero.isEmpty ? '-' : numero}');
      }
      sb.writeln('${_formatarData(voto['dataVoto'])} => ${partes.join(' | ')}');
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/resultado_votos.txt');
    await file.writeAsString(sb.toString());
    return file;
  }

  /// Gera CSV: uma linha por voto, colunas = cargos ativos + Data no final
  Future<File> gerarCSV() async {
    final votos = await _helper.getAllVotos();
    final cargos = ElectionConfig.getCargosAtivos();

    final linhas = <List<String>>[];

    // Cabeçalho: cada cargo + Data por último
    final cabecalho = <String>[];
    for (final cargo in cargos) {
      cabecalho.add(cargo.nome);
    }
    cabecalho.add('Data');
    linhas.add(cabecalho);

    // Uma linha por voto (do mais antigo pro mais novo)
    for (final voto in votos.reversed.toList()) {
      final linha = <String>[];
      for (final cargo in cargos) {
        final valor = voto[cargo.tableVotos];
        linha.add(valor == null ? '' : valor.toString());
      }
      linha.add(_formatarData(voto['dataVoto']));
      linhas.add(linha);
    }

    // fieldDelimiter ';' para abrir certinho no Excel pt-BR
    final csv = const ListToCsvConverter(fieldDelimiter: ';').convert(linhas);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/resultado_votos.csv');
    await file.writeAsString(csv);
    return file;
  }

  // ===== INTERNO =====

  /// Carrega numero -> {nome, partido} a partir do CSV único de candidatos
  Future<Map<Cargo, Map<String, Map<String, String>>>> _carregarCandidatos() async {
    final todos = await CandidatosHelper().carregarTodos();
    final resultado = <Cargo, Map<String, Map<String, String>>>{};

    for (final cargo in ElectionConfig.getCargosAtivos()) {
      final porNumero = <String, Map<String, String>>{};
      for (final c in todos) {
        if (c.cargo == cargo.dsCargo) {
          porNumero[c.numero] = {
            'nome': c.nome,
            'partido': c.partido,
          };
        }
      }
      resultado[cargo.cargo] = porNumero;
    }
    return resultado;
  }

  String _descreverVoto(
      Map<String, Map<String, String>> candidatos, String numero) {
    if (numero == null || numero.isEmpty) return '(sem voto)';
    if (numero == 'BRANCO') return 'VOTO EM BRANCO';
    final c = candidatos == null ? null : candidatos[numero];
    if (c == null) return 'VOTO NULO [$numero]';
    return '${c['nome']} (${c['partido']}) [$numero]';
  }

  String _formatarData(dynamic iso) {
    if (iso == null) return '-';
    final dt = DateTime.tryParse(iso.toString());
    if (dt == null) return iso.toString();
    String dois(int v) => v.toString().padLeft(2, '0');
    return '${dois(dt.day)}/${dois(dt.month)}/${dt.year} '
        '${dois(dt.hour)}:${dois(dt.minute)}:${dois(dt.second)}';
  }
}
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:urna_eletronica/config/election_config.dart';
import 'package:urna_eletronica/helpers/urna_helper.dart';
import 'package:urna_eletronica/helpers/candidatos_helper.dart';

class RelatorioHelper {
  static final RelatorioHelper _instance = RelatorioHelper.internal();
  factory RelatorioHelper() => _instance;
  RelatorioHelper.internal();

  final UrnaHelper _helper = UrnaHelper();

  /// Gera o relatório de texto (.txt) com resumo e detalhamento
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

    // ===== RESUMO POR CARGO =====
    for (final cargo in cargos) {
      sb.writeln('--- ${cargo.nome.toUpperCase()} ---');

      final contagem = <String, int>{};
      for (final voto in votos) {
        final numero = voto[cargo.tableVotos] == null ? '' : voto[cargo.tableVotos].toString();
        contagem[numero] = (contagem[numero] ?? 0) + 1;
      }

      if (contagem.isEmpty) {
        sb.writeln('(nenhum voto)');
      } else {
        final ordenados = contagem.keys.toList()
          ..sort((a, b) => contagem[b]!.compareTo(contagem[a]!));
        for (final numero in ordenados) {
          sb.writeln('${_descreverVoto(candidatos[cargo.cargo]!, numero)}: ${contagem[numero]} voto(s)');
        }
      }
      sb.writeln();
    }

    // ===== DETALHAMENTO (COM ENDEREÇO) =====
    sb.writeln('--- DETALHAMENTO (DATA E LOCAL DE CADA VOTO) ---');
    for (final voto in cronologico) {
      final endereco = voto['endereco_pesquisa'] ?? 'Endereço não informado';
      final partes = <String>[];
      
      for (final cargo in cargos) {
        final numero = voto[cargo.tableVotos] == null ? '' : voto[cargo.tableVotos].toString();
        partes.add('${cargo.nome}: ${numero.isEmpty ? '-' : numero}');
      }
      
      // Formato: [Endereço] Data => Cargo: numero | Cargo: numero
      sb.writeln('[$endereco] ${_formatarData(voto['dataVoto'])} => ${partes.join(' | ')}');
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/resultado_votos.txt');
    await file.writeAsString(sb.toString());
    return file;
  }

  /// Gera o CSV: uma linha por voto, colunas = Endereço + Cargos + Data
  Future<File> gerarCSV() async {
    final votos = await _helper.getAllVotos();
    final cargos = ElectionConfig.getCargosAtivos();

    final linhas = <List<String>>[];

    // 1. Cabeçalho: Endereço da Pesquisa + cada cargo + Data por último
    final cabecalho = <String>['Endereço da Pesquisa'];
    for (final cargo in cargos) {
      cabecalho.add(cargo.nome);
    }
    cabecalho.add('Data');
    linhas.add(cabecalho);

    // 2. Uma linha por voto (do mais antigo pro mais novo)
    for (final voto in votos.reversed.toList()) {
      final linha = <String>[];
      
      // Adiciona o endereço (com fallback caso seja um voto antigo sem essa coluna)
      linha.add(voto['endereco_pesquisa'] ?? 'Não informado');
      
      // Adiciona os votos de cada cargo
      for (final cargo in cargos) {
        final valor = voto[cargo.tableVotos];
        linha.add(valor == null ? '' : valor.toString());
      }
      
      // Adiciona a data formatada
      linha.add(_formatarData(voto['dataVoto']));
      linhas.add(linha);
    }

    // fieldDelimiter ';' para abrir certinho no Excel pt-BR
    final csv = Csv(fieldDelimiter: ';').encode(linhas);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/resultado_votos.csv');
    await file.writeAsString(csv);
    return file;
  }

  // ===== MÉTODOS INTERNOS DE AUXÍLIO =====

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

  String _descreverVoto(Map<String, Map<String, String>> candidatos, String numero) {
    if (numero.isEmpty) return '(sem voto)';
    if (numero == 'BRANCO') return 'VOTO EM BRANCO';
    final c = candidatos[numero];
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
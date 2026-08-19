# Quick fix — relatório CSV não populado

## Sintoma reportado
"o relatorio CSV não está sendo populado"

## Causa raiz (não era o CSV)
`Memory.saveVote()` grava a chave `endereco_pesquisa` no mapa de voto e chama `UrnaHelper.saveVoto()`, que faz `dbUrna.insert(votosTable, dados)`. A coluna `endereco_pesquisa` **nunca foi criada** no schema SQLite (`_createAllTables()`) nem em nenhuma das migrações existentes (v1→v2, v2→v3). SQLite/sqflite rejeita o `INSERT` inteiro quando uma chave não corresponde a nenhuma coluna da tabela — **nenhum voto estava sendo salvo**, silenciosamente, porque a chamada era fire-and-forget (`saveVote();` sem `await`/`catch` em `_confirma()`).

Resultado: `getAllVotos()` sempre retornava lista vazia → `RelatorioHelper.gerarCSV()`/`gerarRelatorio()` sempre geravam só o cabeçalho. O bug é anterior à migração Flutter desta sessão — foi introduzido quando a feature de endereço/pesquisa foi adicionada (commits `d74844d`/`6818bb5`) sem migração de banco correspondente.

## Fix aplicado
`lib/helpers/urna_helper.dart`:
- Nova constante `enderecoPesquisaColumn = "endereco_pesquisa"`.
- Coluna adicionada em `_createAllTables()` (instalações novas).
- Nova `_migrateToVersion4()` com `ALTER TABLE ... ADD COLUMN` (instalações existentes — banco sobe de v3 pra v4 automaticamente no próximo `openDatabase`).

`lib/model/memory.dart`:
- `saveVote()` agora captura exceção do `saveVoto()`, loga (`print`) e reprop (`rethrow`) — antes falhava 100% silencioso. Não adiciona feedback de erro na UI (fora de escopo deste fix; nenhum outro ponto do fluxo de voto tem essa affordance hoje).

## Verificação
`flutter analyze lib/helpers/urna_helper.dart lib/model/memory.dart` → No issues found.
Teste funcional real (votar → CSV populado) fica coberto por T11 (UAT da migração Flutter), que ainda está pendente — é o próximo passo natural pra confirmar este fix na prática.

## Nota
Este bug não tem relação com a migração Flutter 1.22.6→3.44.7 em andamento (`migracao-flutter-dart`) — é um bug de schema pré-existente, só ficou visível/relevante agora que o app builda de novo.

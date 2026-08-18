# Tasks — Migração Flutter/Dart 1.22.6 → 3.44.7

Design pulado: sem decisão arquitetural nova, é migração de SDK/dependências sobre a arquitetura existente (ver `.specs/codebase/ARCHITECTURE.md`).

## Status geral
[ ] Em planejamento [x] Em execução [ ] Concluído

## Arquivos em `lib/` (17 total, referência para todas as tasks)
`config/election_config.dart`, `helpers/candidatos_helper.dart`, `helpers/relatorio_helper.dart`, `helpers/urna_helper.dart`, `main.dart`, `model/candidato.dart`, `model/memory.dart`, `model/prefeito.dart`, `model/vereador.dart`, `pages/address_screen.dart`, `pages/dashboard.dart`, `pages/display.dart`, `pages/home_page.dart`, `pages/keyboard.dart`, `util/data.dart`, `util/nav.dart`, `widgets/app_buttons.dart`

## Tarefas

### T01 — Instalar Flutter 3.44.7 via FVM ✅
**O quê:** Instalar a versão nova do SDK sem remover a 1.22.6 (rollback fica disponível)
**Onde:** `.fvmrc`, `.fvm/versions/`
**Depende de:** nenhuma
**Reutiliza:** FVM já configurado no projeto
**Paralela:** N
**Feito quando:**
- [x] `fvm install 3.44.7` concluído
- [x] `.fvmrc` aponta para `3.44.7`
- [x] `fvm flutter --version` confirma 3.44.7
**Gate:** `fvm flutter --version` → contém `3.44.7` — **PASSOU**
**Rastreabilidade:** R01
**Nota de execução:** 1.22.6 permanece no cache global do FVM (`C:\Users\atlanta\fvm\versions`), disponível via `fvm use 1.22.6` para rollback — só deixou de ser a versão "Local" do projeto. `fvm use 3.44.7 --force` foi necessário porque o `pubspec.yaml` ainda declara `sdk: ">=2.7.0 <3.0.0"` (será corrigido em T02) — o warning de incompatibilidade é esperado nesta etapa.

---

### T02 — Atualizar `pubspec.yaml`: SDK constraint e dependências ✅
**O quê:** Trocar `environment.sdk` pra faixa compatível com Dart 3.x; atualizar/trocar todas as dependências (`audioplayers` → `^6.x`, `share_extend` → `share_plus`, `flushbar` → `another_flushbar`, `sqflite`/`path_provider`/`csv`/`cupertino_icons`/`animated_text_kit` → versões atuais null-safe)
**Onde:** `pubspec.yaml`
**Depende de:** T01
**Reutiliza:** nenhuma
**Paralela:** N
**Feito quando:**
- [x] `environment.sdk` reflete Dart compatível com Flutter 3.44 (`>=3.10.0 <4.0.0`)
- [x] Todas as 7 dependências diretas atualizadas/substituídas: `cupertino_icons ^1.0.9`, `another_flushbar ^2.2.4`, `animated_text_kit ^4.3.0`, `audioplayers ^6.8.1`, `sqflite ^2.4.3`, `path_provider ^2.1.6`, `csv ^8.0.0`, `share_plus ^13.3.0`
- [x] `flutter pub get` roda sem erro de conflito de versão
**Gate:** `fvm flutter pub get` → exit 0, sem erros de resolução — **PASSOU** (97 dependências atualizadas; `flushbar` e `share_extend` corretamente removidos da árvore)
**Rastreabilidade:** R02, R06, R07, R08, R09
**Nota de execução:** versões confirmadas via pub.dev em 2026-08-18 (não fabricadas). `flutter pub outdated` aponta 8 pacotes transitivos com versão mais nova disponível — não bloqueante, não investigado agora (fora do escopo desta task).

---

### T03 — Migração null-safety em `lib/` ✅
**O quê:** Migração manual (não automática — ver nota) nos 17 arquivos — adicionar `?`/`!`/`required`, remover checks de nulo redundantes do Dart antigo
**Onde:** `config/election_config.dart`, `helpers/candidatos_helper.dart`, `helpers/relatorio_helper.dart`, `helpers/urna_helper.dart`, `model/candidato.dart`, `model/memory.dart`, `model/prefeito.dart`, `model/vereador.dart`, `widgets/app_buttons.dart` (9 dos 17 — os demais não tinham erro de null-safety)
**Depende de:** T02
**Reutiliza:** nenhuma
**Paralela:** N
**Feito quando:**
- [x] Todos os erros classificados como null-safety/linguagem Dart 3 corrigidos (campos `required`/nullable, `List()` sem construtor default, promoção de tipo com `!` em campos não-`final`)
- [x] Nenhum uso de opt-out de null-safety
**Gate:** `fvm flutter analyze lib/` → zero erros de null-safety — **PASSOU** (102 → 32 issues; os 32 restantes são 100% de T04/T05/T06/T07/T08/T09, confirmado issue por issue)
**Rastreabilidade:** R03
**Nota de execução:** `dart migrate` **não existe mais** no Dart 3.12.2 (ferramenta removida do SDK, só existiu entre Dart 2.12–2.19) — migração foi manual, guiada pelo `flutter analyze`. `Memory` (model/memory.dart) já tinha os null-checks corretos no código pré-existente (`candidato != null`, `vice != null`) — não precisou de mudança, os warnings resolveram sozinhos ao tornar `buscar`/`buscarVice` `Future<Candidato?>`. Classes legadas `Votos`/`VotoGenerico` em `urna_helper.dart` confirmadas mortas (zero call sites em `lib/`) — corrigidas com o mínimo necessário (nullable), não deletadas (fora do escopo desta migração). Achado novo: `dashboard.dart` usa `helper.query()`/`mapListToCsv` (fluxo CSV legado, `votos.csv`) — bloqueado por T09, não só T04/T07 como o tasks.md original previa; T07 precisa ganhar `dashboard.dart` no escopo (`_shareCSV` usa `ShareExtend` também).

---

### T04 — Substituir `RaisedButton`/`FlatButton`
**O quê:** Trocar por `ElevatedButton`/`TextButton` (API de estilo mudou de `color`/`textColor` para `style: ElevatedButton.styleFrom(...)`)
**Onde:** `pages/home_page.dart`, `pages/dashboard.dart`, `pages/address_screen.dart`
**Depende de:** T03
**Reutiliza:** nenhuma
**Paralela:** N (mesmos arquivos que T05/T06/T07/T08 — sequencial para evitar conflito)
**Feito quando:**
- [ ] Zero ocorrências de `RaisedButton`/`FlatButton` em `lib/`
- [ ] Visual dos botões mantido (cores/tamanhos equivalentes)
**Gate:** grep `RaisedButton|FlatButton` em `lib/` → 0 resultados
**Rastreabilidade:** R04

---

### T05 — Reverter workaround de `ScaffoldMessenger`
**O quê:** Trocar `GlobalKey<ScaffoldState>` + `.currentState.showSnackBar()` de volta para `ScaffoldMessenger.of(context).showSnackBar()` (decisão de 2026-08-18 em STATE.md, motivada pela ausência do `ScaffoldMessenger` no SDK antigo — deixa de existir com a migração)
**Onde:** `pages/address_screen.dart`, `pages/home_page.dart`
**Depende de:** T03
**Reutiliza:** nenhuma
**Paralela:** N (mesmo arquivo que T04/T06/T07/T08)
**Feito quando:**
- [ ] `_scaffoldKey` removido dos dois arquivos
- [ ] `ScaffoldMessenger.of(context).showSnackBar(...)` funcionando (testar manualmente: endereço vazio → snackbar; apagar registros → snackbar)
**Gate:** grep `GlobalKey<ScaffoldState>` em `lib/pages/` → 0 resultados
**Rastreabilidade:** R05

---

### T06 — Portar chamadas de `audioplayers` pra API 6.x
**O quê:** Reescrever `AudioCache`/`AudioPlayer` em `playSoundConfirm()` conforme o migration guide oficial do pacote (API 0.15.x → 6.x é reescrita completa, não é find-and-replace)
**Onde:** `pages/home_page.dart`
**Depende de:** T02, T03
**Reutiliza:** nenhuma — ler `https://github.com/bluefireteam/audioplayers/blob/main/migration_guides.md` (ou changelog) antes de portar
**Paralela:** N (mesmo arquivo que T04/T05/T07/T08)
**Feito quando:**
- [ ] `playSoundConfirm()` toca `som.mp3` sem erro
- [ ] Teste manual: confirmar voto toca o som esperado
**Gate:** `fvm flutter analyze lib/pages/home_page.dart` limpo + teste manual de som
**Rastreabilidade:** R06

---

### T07 — Portar compartilhamento `share_extend` → `share_plus`
**O quê:** Trocar `ShareExtend.share(file.path, "file")` pela API do `share_plus` (`Share.shareXFiles([XFile(file.path)])`)
**Onde:** `pages/home_page.dart`, `pages/dashboard.dart` (achado em T03: `_shareCSV()` também usa `ShareExtend`, compartilha o CSV legado `votos.csv`)
**Depende de:** T02, T03
**Reutiliza:** nenhuma
**Paralela:** N (mesmo arquivo que T04/T05/T06/T08)
**Feito quando:**
- [ ] Botão "Enviar Relatório" (home_page) compartilha o CSV corretamente (teste manual)
- [ ] Botão "Compartilhar pesquisa" (dashboard) compartilha o CSV legado corretamente (teste manual)
**Gate:** teste manual — os dois pontos de compartilhamento abrem o share sheet do Android com o arquivo certo
**Rastreabilidade:** R07

---

### T08 — Portar `flushbar` → `another_flushbar`
**O quê:** Trocar import e API de `Flushbar(...)..show(context)` conforme `another_flushbar` (API é próxima, mas checar breaking changes no construtor)
**Onde:** `pages/home_page.dart` (`_onClickVoidConfirm`, `_onClickVoidBlanck`)
**Depende de:** T02, T03
**Reutiliza:** nenhuma
**Paralela:** N (mesmo arquivo que T04/T05/T06/T07)
**Feito quando:**
- [ ] Mensagem "Para confirmar seu voto..." aparece ao apertar CONFIRMA sem voto (teste manual)
- [ ] Mensagem "Para votar em BRANCO..." aparece no cenário correto (teste manual)
**Gate:** teste manual dos dois cenários de erro
**Rastreabilidade:** R08

---

### T09 — Verificar breaking changes em `sqflite`/`path_provider`/`csv`
**O quê:** Checar changelog de cada pacote entre a versão antiga e a atual; ajustar chamadas em helpers se a API mudou
**Onde:** `helpers/urna_helper.dart` (sqflite), `helpers/relatorio_helper.dart` (path_provider, csv), `helpers/candidatos_helper.dart` (csv)
**Depende de:** T02, T03
**Reutiliza:** nenhuma
**Paralela:** S — arquivos diferentes de T04–T08, pode rodar em paralelo com eles se houver mais de um executor
**Feito quando:**
- [ ] `fvm flutter analyze lib/helpers/` sem erros
- [ ] Teste manual: registrar um voto grava no SQLite; gerar relatório lê os votos e exporta CSV corretamente
**Gate:** `fvm flutter analyze lib/helpers/` limpo + teste manual de persistência/relatório
**Rastreabilidade:** R09

---

### T10 — Build Android limpo
**O quê:** Confirmar que `assembleDebug` passa sem qualquer patch fora do projeto (fecha o bloqueio B02)
**Onde:** projeto inteiro (validação, não implementação)
**Depende de:** T01–T09
**Reutiliza:** nenhuma
**Paralela:** N
**Feito quando:**
- [ ] `flutter build apk --debug` conclui com sucesso
- [ ] Nenhum patch aplicado em `.fvm/versions/*/packages/flutter_tools/gradle/flutter.gradle`
- [ ] B02 fechado em `STATE.md`
**Gate:** `fvm flutter build apk --debug` → BUILD SUCCESSFUL
**Rastreabilidade:** R10

---

### T11 — UAT do fluxo completo de votação
**O quê:** Percorrer manualmente o fluxo real: tela de endereço → votar nos 5 cargos (Presidente/Vice, Deputado Federal, Deputado Estadual, Senador, Governador) → confirmar → relatório
**Onde:** app rodando em dispositivo/emulador Android
**Depende de:** T10
**Reutiliza:** nenhuma
**Paralela:** N
**Feito quando:**
- [ ] Endereço obrigatório barra votação vazia (snackbar aparece — valida T05)
- [ ] Cada um dos 5 cargos aceita número de candidato e mostra o candidato certo
- [ ] Voto em branco funciona (valida T08)
- [ ] Tentar confirmar sem voto mostra aviso (valida T08)
- [ ] Som toca ao confirmar (valida T06)
- [ ] Tela de fim aparece e volta pra tela de endereço
- [ ] Relatório é gerado e compartilhado (valida T07)
- [ ] Apagar registros funciona e mostra snackbar (valida T05)
**Gate:** checklist acima 100% marcado manualmente pelo operador
**Rastreabilidade:** R11

---

## Ordem de execução recomendada

```
T01 → T02 → T03 → [T04, T05, T06, T07, T08 sequenciais entre si — mesmo arquivo home_page.dart/address_screen.dart]
                 → T09 [P] (pode rodar em paralelo com o bloco acima — arquivos diferentes)
       → T10 → T11
```

Nota: apesar de T04–T08 tocarem majoritariamente `home_page.dart`, cada uma tem critério de verificação próprio — não consolidar em uma tarefa só, mas executar em sequência (não em paralelo real) para evitar conflito de edição no mesmo arquivo.

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
- [x] Zero ocorrências de `RaisedButton`/`FlatButton` em `lib/`
- [x] Visual dos botões mantido (cores/tamanhos equivalentes — mesmo `backgroundColor`/`foregroundColor`/`padding`/`shape` migrados para `styleFrom`)
**Gate:** grep `RaisedButton|FlatButton` em `lib/` → 0 resultados — **PASSOU**
**Rastreabilidade:** R04
**Nota de execução:** `dashboard.dart` já usava `TextButton.icon` — não precisou de mudança.

---

### T05 — Reverter workaround de `ScaffoldMessenger`
**O quê:** Trocar `GlobalKey<ScaffoldState>` + `.currentState.showSnackBar()` de volta para `ScaffoldMessenger.of(context).showSnackBar()` (decisão de 2026-08-18 em STATE.md, motivada pela ausência do `ScaffoldMessenger` no SDK antigo — deixa de existir com a migração)
**Onde:** `pages/address_screen.dart`, `pages/home_page.dart`
**Depende de:** T03
**Reutiliza:** nenhuma
**Paralela:** N (mesmo arquivo que T04/T06/T07/T08)
**Feito quando:**
- [x] `_scaffoldKey` removido dos dois arquivos
- [ ] `ScaffoldMessenger.of(context).showSnackBar(...)` funcionando (testar manualmente: endereço vazio → snackbar; apagar registros → snackbar) — **pendente T11 (UAT), app ainda não builda**
**Gate:** grep `GlobalKey<ScaffoldState>` em `lib/pages/` → 0 resultados — **PASSOU**
**Rastreabilidade:** R05

---

### T06 — Portar chamadas de `audioplayers` pra API 6.x
**O quê:** Reescrever `AudioCache`/`AudioPlayer` em `playSoundConfirm()` conforme o migration guide oficial do pacote (API 0.15.x → 6.x é reescrita completa, não é find-and-replace)
**Onde:** `pages/home_page.dart`
**Depende de:** T02, T03
**Reutiliza:** nenhuma — ler `https://github.com/bluefireteam/audioplayers/blob/main/migration_guides.md` (ou changelog) antes de portar
**Paralela:** N (mesmo arquivo que T04/T05/T07/T08)
**Feito quando:**
- [x] `playSoundConfirm()` toca `som.mp3` sem erro de compilação (`AudioPlayer().play(AssetSource("som.mp3"))`)
- [ ] Teste manual: confirmar voto toca o som esperado — **pendente T11 (app ainda não builda)**
**Gate:** `fvm flutter analyze lib/model/memory.dart lib/pages/home_page.dart` sem erros de audioplayers — **PASSOU**
**Rastreabilidade:** R06
**Nota de execução:** `home_page.dart` tinha uma cópia morta/duplicada de `playSoundConfirm()` (nunca chamada) — portada também, não removida.

---

### T07 — Portar compartilhamento `share_extend` → `share_plus`
**O quê:** Trocar `ShareExtend.share(file.path, "file")` pela API do `share_plus` (`Share.shareXFiles([XFile(file.path)])`)
**Onde:** `pages/home_page.dart`, `pages/dashboard.dart` (achado em T03: `_shareCSV()` também usa `ShareExtend`, compartilha o CSV legado `votos.csv`)
**Depende de:** T02, T03
**Reutiliza:** nenhuma
**Paralela:** N (mesmo arquivo que T04/T05/T06/T08)
**Feito quando:**
- [x] Compila sem erro nos dois arquivos (`SharePlus.instance.share(ShareParams(files: [XFile(path)]))`)
- [ ] Teste manual dos dois pontos de compartilhamento — **pendente T11**
**Gate:** `fvm flutter analyze lib/pages/home_page.dart lib/pages/dashboard.dart` sem erros de share — **PASSOU**
**Rastreabilidade:** R07

---

### T08 — Portar `flushbar` → `another_flushbar`
**O quê:** Trocar import e API de `Flushbar(...)..show(context)` conforme `another_flushbar` (API é próxima, mas checar breaking changes no construtor)
**Onde:** `pages/home_page.dart` (`_onClickVoidConfirm`, `_onClickVoidBlanck`)
**Depende de:** T02, T03
**Reutiliza:** nenhuma
**Paralela:** N (mesmo arquivo que T04/T05/T06/T07)
**Feito quando:**
- [x] Compila sem erro (`import 'package:another_flushbar/flushbar.dart'`, API idêntica — `titleText`/`messageText` suportados)
- [ ] Teste manual dos dois cenários de erro — **pendente T11**
**Gate:** `fvm flutter analyze lib/` sem erros de flushbar — **PASSOU** (25 → 14 issues, restam só T09)
**Rastreabilidade:** R08

---

### T09 — Verificar breaking changes em `sqflite`/`path_provider`/`csv` ✅
**O quê:** Checar changelog de cada pacote entre a versão antiga e a atual; ajustar chamadas em helpers se a API mudou
**Onde:** `helpers/urna_helper.dart` (sqflite + csv/`mapListToCsv`), `helpers/relatorio_helper.dart` (path_provider, csv), `helpers/candidatos_helper.dart` (csv). Achado durante execução: `pages/display.dart` também precisou de fix (`animated_text_kit`, fora do escopo original de "Onde" mas mesma natureza — breaking change de dependência)
**Depende de:** T02, T03
**Reutiliza:** nenhuma
**Paralela:** S — arquivos diferentes de T04–T08, pode rodar em paralelo com eles se houver mais de um executor
**Feito quando:**
- [x] `fvm flutter analyze lib/` sem erros (0 erros, 1 warning inofensivo pré-existente)
- [ ] Teste manual: registrar um voto grava no SQLite; gerar relatório lê os votos e exporta CSV corretamente — **pendente T11**
**Gate:** `fvm flutter analyze lib/` → **PASSOU** (14 → 1 issue, só dead_code pré-existente)
**Rastreabilidade:** R09
**Nota de execução:** `sqflite`/`path_provider` não tiveram breaking changes que afetassem o código (só version bump). `csv`: `CsvToListConverter`/`ListToCsvConverter` (removidos) → classe unificada `Csv` com `decode()`/`encode()`, não é mais `const`-constructível. `List(n)` sem construtor default (removido no Dart 3) → `List<dynamic>.filled(n, null)`. `animated_text_kit`: `FadeAnimatedTextKit` deprecado → `AnimatedTextKit(animatedTexts: [FadeAnimatedText(...)])`; parâmetro `alignment` não tem equivalente direto na API nova — risco visual menor, a confirmar em T11.

---

### T10 — Build Android limpo ✅
**O quê:** Confirmar que `assembleDebug` passa sem qualquer patch fora do projeto (fecha o bloqueio B02)
**Onde:** projeto inteiro. Na prática, exigiu migrar toda a estrutura Gradle do projeto (`android/settings.gradle`→`.kts`, `android/build.gradle`→`.kts`, `android/app/build.gradle`→`.kts`, `gradle-wrapper.properties`, `gradle.properties`, `AndroidManifest.xml`) — não estava no escopo original de "Onde" (que previa só validação), ver nota de execução
**Depende de:** T01–T09
**Reutiliza:** template gerado por `flutter create` com a mesma versão (3.44.7), usado como referência de arquivos Gradle corretos — evitou fabricar sintaxe Kotlin DSL
**Paralela:** N
**Feito quando:**
- [x] `flutter build apk --debug` conclui com sucesso (`√ Built build\app\outputs\flutter-apk\app-debug.apk`)
- [x] Nenhum patch aplicado em `.fvm/versions/*/packages/flutter_tools/gradle/flutter.gradle` (a tentativa foi bloqueada por permissão no bloqueio B02 original; migrar a estrutura Gradle resolveu sem precisar disso)
- [x] B02 fechado em `STATE.md`
**Gate:** `fvm flutter build apk --debug` → **BUILD SUCCESSFUL** (2 execuções confirmadas, 849s primeira/50,7s segunda com cache)
**Rastreabilidade:** R10
**Nota de execução — escopo maior que o previsto:** o bloqueio B02 original (`flutter.gradle` antigo vs. Gradle 7 estrito) desapareceu sozinho ao trocar de Flutter SDK, mas surgiram 2 problemas novos, não previstos na spec original:
1. **JDK errado sendo usado:** Flutter prioriza o JDK embutido do Android Studio sobre `JAVA_HOME`. O JBR do Android Studio instalado é Java 25 — na primeira tentativa isso quebrou com Gradle 7.5 (bytecode incompatível); a causa real não era "JDK ruim", era Gradle desatualizado. `flutter config --jdk-dir` foi setado para o JBR do Android Studio (correto para esta versão do Flutter).
2. **Flutter 3.44.7 exige a estrutura Gradle declarativa (Kotlin DSL)** — o projeto usava o estilo antigo (`apply from:`, Groovy `.gradle`). Migrado para `.gradle.kts` completo (settings/root/app), Gradle 9.1.0, AGP 9.0.1, Kotlin 2.3.20, `compileOptions`/`jvmTarget` Java 17. Arquivos Groovy antigos removidos (duplicidade quebraria o build). `AndroidManifest.xml` teve o atributo `package=` removido (substituído por `namespace` no Gradle, padrão atual).
3. **`minSdk` forçado de 23 para `flutter.minSdkVersion` (24) pelo próprio Flutter** — migração automática e permanente do SDK (`min_sdk_version_migration.dart`), reaplicada a cada build. Tentei preservar 23 (valor explícito original do projeto) duas vezes; o Flutter reverteu as duas vezes. **Consequência real para o produto:** dispositivos Android 6.0 (API 23) deixam de rodar o app a partir desta migração — decisão não solicitada, mas inevitável para continuar no Flutter 3.44. Sinalizado ao operador.

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

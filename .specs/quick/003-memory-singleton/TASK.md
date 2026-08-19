# Quick fix — endereço não populado no relatório CSV

## Sintoma reportado
"todos estão sendo populados menos o endereço no relatorio csv" — confirma que o fix anterior (`002-csv-nao-populado`, coluna faltante no schema) funcionou: votos salvam. Só o endereço fica vazio.

## Causa raiz
`Memory` **não era singleton** — risco já sinalizado em `.specs/codebase/CONCERNS.md` no mapeamento inicial, agora confirmado como bug real:

- `address_screen.dart`: `final Memory memory = Memory();`
- `home_page.dart`: `final Memory memory = Memory();`

Duas instâncias diferentes. `AddressScreen._iniciarVotacao()` chama `memory.setEndereco(...)` na sua própria instância; `HomePage` usa outra instância, com `_endereco` sempre `''` (nunca recebe o valor). Como `_endereco` é string vazia (não `null`), `saveVote()` grava `''` no banco, e o fallback `voto['endereco_pesquisa'] ?? 'Não informado'` no `gerarCSV()` nunca dispara (só dispara pra `null`, não pra string vazia) — resultado: célula sempre vazia no CSV.

Os demais campos (votos por cargo) funcionam porque são todos escritos e lidos dentro da mesma instância de `HomePage` durante a votação — só o endereço atravessa a fronteira entre as duas telas/instâncias.

## Fix aplicado
`lib/model/memory.dart`: `Memory` convertida em singleton, usando o mesmo padrão já existente em `UrnaHelper`/`CandidatosHelper` no mesmo arquivo/codebase (`static final _instance` + `factory` + construtor `.internal()`) — não introduz convenção nova.

## Verificação
`flutter analyze` nos 3 arquivos afetados → No issues found.
Teste funcional real fica coberto por T11 (UAT), ainda pendente.

## Consequência (esperada, não colateral)
Como `Memory` agora é verdadeiramente compartilhada durante toda a vida do app, o fluxo "PRÓXIMO VOTO" (`resetForNewVote()` + `Navigator.pop()` de volta pra `AddressScreen`) passa a funcionar como o código já pressupunha — reset em uma instância que continua sendo a mesma usada depois.

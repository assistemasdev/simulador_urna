# Quick fix — responsividade para celular (tela de endereço)

## Contexto
Pedido inicial: "faça responsivo para também celulares". Enquadrado via 3 perguntas ao operador antes de tocar em código (ver decisões abaixo) — escopo real é bem menor do que "responsivo" sugere à primeira vista.

## Decisões do operador (2026-08-18)
1. **Escopo:** só corrigir risco de overflow/quebra, não redesenhar pra usabilidade em tela pequena. A tela de votação (`home_page.dart`) já escala via `FittedBox` num canvas fixo 1280×800 — aceito ficar pequena em celular.
2. **Orientação:** manter travada em paisagem (`main.dart` inalterado) — celular gira, não ganha modo retrato.
3. **Ordem:** fazer agora, antes de T11 (UAT da migração Flutter) — vai ser validado junto no mesmo teste manual.

## O que foi corrigido
Único ponto de risco real: `lib/pages/address_screen.dart` tinha um `Container(width: 600, ...)` fixo, sem `FittedBox`/scroll — podia estourar horizontalmente em telas menores que 600dp e verticalmente em celulares landscape de tela curta (altura física pequena).

Fix: `Center > SingleChildScrollView > ConstrainedBox(maxWidth: 600) > Container`. Cap de largura vira responsivo (encolhe em telas estreitas), scroll cobre overflow vertical em telas curtas.

`home_page.dart`/`display.dart`/`keyboard.dart` não precisaram de mudança — já protegidos contra overflow pelo `FittedBox` existente.

## Verificação
`flutter analyze lib/pages/address_screen.dart` → No issues found.
Teste visual em tela pequena fica coberto pelo T11 (UAT da migração), que já estava pendente.

## Rastreabilidade
Não pertence à feature `migracao-flutter-dart` — é uma correção de UI independente, feita durante o mesmo período de trabalho.

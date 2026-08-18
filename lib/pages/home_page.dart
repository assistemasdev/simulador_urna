import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urna_eletronica/helpers/urna_helper.dart';
import 'package:urna_eletronica/model/memory.dart';
import 'package:urna_eletronica/pages/display.dart';
import 'package:urna_eletronica/pages/keyboard.dart';
import 'package:urna_eletronica/helpers/relatorio_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UrnaHelper helper = UrnaHelper();
  final RelatorioHelper relatorio = RelatorioHelper();
  final Memory memory = Memory();
  StreamController<String> controller = StreamController();
  bool _showEndScreen = false;

  _onPressed(String text) {
    setState(() {
      if (_showEndScreen) {
        _showEndScreen = false;
        memory.resetVote();
        memory.resetForNewVote();
        return;
      }

      if (text == 'BRANCO' && memory.value.isEmpty) {
        memory.applyCommand(text);
      } else if (text == 'BRANCO' && memory.value.isNotEmpty) {
        _onClickVoidBlanck();
      } else if (text == 'CONFIRMA' && memory.value.isEmpty) {
        _onClickVoidConfirm();
      } else {
        memory.applyCommand(text);
        controller.sink.add(memory.value);

        if (memory.voteFinished) {
          _showEndScreen = true; // SEM TIMER, apenas muda o estado
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller.stream.listen((data) {
      if (data.length == memory.currentCargo.digitos) {
        memory.loadCandidatos(data);
      }
    });
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 1280, height: 800,
              child: Stack(
                children: <Widget>[
                  if (_showEndScreen)
                    Center(
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('FIM', style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Colors.black)),
                            SizedBox(height: 20),
                            Text('Voto computado com sucesso!', style: TextStyle(fontSize: 30, color: Colors.black)),
                            SizedBox(height: 50),
                            ElevatedButton(
                              onPressed: () {
                                memory.resetForNewVote(); // Limpa TUDO, inclusive endereço
                                Navigator.pop(context); // Volta para a AddressScreen
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text('PRÓXIMO VOTO', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(height: 30),
                            TextButton(
                              onPressed: () {
                                memory.resetForNewVote();
                                Navigator.pop(context);
                              },
                              child: Text('Cancelar / Voltar', style: TextStyle(fontSize: 18, color: Colors.red)),
                            )
                          ],
                        ),
                      ),
                    )
                  else ...[
                    Display(memory.value, memory.currentCargoIndex, memory.candidatoId, memory.currentCargo.nome, memory.currentCargo.digitos),
                    Keyboard(_onPressed)
                  ],
                  Positioned(
                    right: 0, bottom: 0,
                    child: GestureDetector(
                      onTap: () => _showMenu(context),
                      child: Container(width: 70, height: 70, color: Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Relatório de Votos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Icon(Icons.share, color: Colors.green),
              ),
              title: Text('Enviar Relatório'),
              subtitle: Text('Compartilhar como CSV'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final file = await relatorio.gerarCSV();
                  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erro ao gerar relatório: $e")),
                  );
                }
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red[100],
                child: Icon(Icons.delete_forever, color: Colors.red),
              ),
              title: Text('Apagar Registros'),
              subtitle: Text('Remover todos os votos salvos'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmarApagar(context);
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmarApagar(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text("Apagar todos os registros?"),
          ],
        ),
        content: Text(
          "Essa ação não pode ser desfeita. Todos os votos serão removidos permanentemente.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await helper.deleteAllVotos();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("✓ Registros apagados com sucesso"),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Erro ao apagar: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              "Apagar",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  _onClickVoidConfirm() {
    Flushbar(
      margin: EdgeInsets.fromLTRB(150, 0, 150, 0),
      backgroundColor: Colors.deepOrange,
      titleText: Text(
        "Atenção",
        style: TextStyle(fontSize: 40, color: Colors.white),
      ),
      messageText: Text(
        "Para confirmar seu voto é necessário digitar o número do candidato ou votar em Branco.",
        style: TextStyle(fontSize: 25, color: Colors.white),
      ),
      duration: Duration(seconds: 5),
    )..show(context);
  }

  _onClickVoidBlanck() {
    Flushbar(
      margin: EdgeInsets.fromLTRB(150, 0, 150, 0),
      backgroundColor: Colors.deepOrange,
      titleText: Text(
        "Atenção",
        style: TextStyle(fontSize: 40, color: Colors.white),
      ),
      messageText: Text(
        "Para votar em BRANCO o campo de voto deve estar vazio. Aperte CORRIGE para apagar o campo de voto",
        style: TextStyle(fontSize: 25, color: Colors.white),
      ),
      duration: Duration(seconds: 5),
    )..show(context);
  }

  Future<void> playSoundConfirm() async {
    final player = AudioPlayer();
    await player.play(AssetSource("som.mp3"));
  }
}
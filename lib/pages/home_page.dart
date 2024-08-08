import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:urna_eletronica/helpers/urna_helper.dart';
import 'package:urna_eletronica/model/memory.dart';
import 'package:urna_eletronica/pages/display.dart';
import 'package:urna_eletronica/pages/keyboard.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UrnaHelper helper = UrnaHelper();

  Votos v = Votos();

  final Memory memory = Memory();

  StreamController<String> controller = StreamController();

  _onPressed(String text) {
    setState(() {
      if (text == 'BRANCO' && memory.value.isEmpty) {
        memory.applyCommand(text);
      } else if (text == 'BRANCO' && memory.value.isNotEmpty) {
        _onClickVoidBlanck();
      } else if (text == 'CONFIRMA' &&
          memory.buffer[0].length < 2 &&
          memory.buffer[1].length <= 1) {
        _onClickVoidConfirm();
      } else {
        print(text);
        print(memory.value);
        memory.applyCommand(text);
        controller.sink.add(memory.value);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    Stream<String> output = controller.stream;

    output.listen((data) {
      print("Escutando " + data);
      if (data.length == 5) {
        memory.loadVereadores(data);
      } else if (memory.bufferIndex == 1 && data.length == 2) {
        memory.loadPrefeitos('$data');
        //print();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Display(memory.value, memory.bufferIndex, memory.buffer,
            memory.vereadorId, memory.prefeitoId),
        Keyboard(_onPressed)
      ],
    ));
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
        "Para confirmar seu voto é necessário escolher os dois primeiros números ou votar em Branco.",
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

  Future<AudioPlayer> playSoundConfirm() async {
    AudioCache cache = new AudioCache();
    //At the next line, DO NOT pass the entire reference such as assets/yes.mp3. This will not work.
    //Just pass the file name only.
    return await cache.play("som.mp3");
  }
}

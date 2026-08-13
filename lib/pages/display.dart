import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class Display extends StatelessWidget {
  final String text;
  final int currentCargoIndex;
  final List candidatoId;
  final String cargoNome;
  final int digitos;

  Display(this.text, this.currentCargoIndex, this.candidatoId, this.cargoNome,
      this.digitos);

  // ===== TAMANHOS DAS IMAGENS (ajuste aqui se quiser) =====
  static const double IMG_TITULAR_W = 250; // antes: 300
  static const double IMG_TITULAR_H = 300; // antes: 350
  static const double IMG_VICE_W = 150;    // antes: 200
  static const double IMG_VICE_H = 150;    // antes: 200

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20.0,
      top: 40.0,
      width: 800.0,
      height: 695.0,
      child: Stack(
        children: <Widget>[
          Container(
            color: Colors.grey[300],
            child: text == 'BRANCO' ? blankcolumn() : normalcolumn(),
          ),
          // Imagem principal do candidato (menor, sem cobrir os textos)
          candidatoId.length >= 4
              ? Positioned(
                  top: 60,
                  right: 0,
                  child: Image.asset(
                    candidatoId[3],
                    height: IMG_TITULAR_H,
                    width: IMG_TITULAR_W,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: IMG_TITULAR_H,
                        width: IMG_TITULAR_W,
                        color: Colors.grey[400],
                        child: Icon(Icons.person, size: 100, color: Colors.white),
                      );
                    },
                  ))
              : SizedBox(),
          // Vice: imagem + nome embaixo (menor)
          candidatoId.length >= 5
              ? Positioned(
                  bottom: 30,
                  right: 0,
                  child: Column(
                    children: [
                      Image.asset(
                        candidatoId[4],
                        height: IMG_VICE_H,
                        width: IMG_VICE_W,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: IMG_VICE_H,
                            width: IMG_VICE_W,
                            color: Colors.grey[400],
                            child: Icon(Icons.person, size: 60, color: Colors.white),
                          );
                        },
                      ),
                      if (candidatoId.length >= 6)
                        Container(
                          width: IMG_VICE_W,
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          child: Text(
                            candidatoId[5],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Row _digitBoxes() {
    return Row(
      children: List.generate(digitos, (i) {
        String digit = (i < text.length) ? text[i] : '';
        return Container(
          width: 60,
          height: 80,
          margin: EdgeInsets.only(right: 6),
          color: Colors.white,
          child: Center(
            child: Text(
              digit,
              style: TextStyle(fontSize: 50, letterSpacing: 1.2),
            ),
          ),
        );
      }),
    );
  }

  Column blankcolumn() {
    return Column(
      children: <Widget>[
        text.isNotEmpty
            ? _title()
            : SizedBox(
                height: 20,
              ),
        SizedBox(
          height: 80,
        ),
        _label(),
        SizedBox(
          height: 80,
        ),
        text.isNotEmpty ? _blanckVoteAnimation() : SizedBox(),
        SizedBox(
          height: 130,
        ),
        text.isNotEmpty ? _footer() : SizedBox()
      ],
    );
  }

  Column normalcolumn() {
    return Column(
      children: <Widget>[
        text.isNotEmpty
            ? _title()
            : SizedBox(
                height: 20,
              ),
        SizedBox(
          height: 80,
        ),
        _label(),
        SizedBox(
          height: 80,
        ),
        text.length >= 2 ? _boxVoteMutable() : _boxVoteStatic(),
        text.length >= 2 ? _numErrorTitle() : SizedBox(),
        text.length >= 2 ? _nullVoteAnimation() : SizedBox(),
        text.length >= 2 ? _footer() : SizedBox()
      ],
    );
  }

  Padding _nullVoteAnimation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 30, 0, 0),
      child: candidatoId.isNotEmpty
          ? Padding(
              // reserva espaço da foto pra o partido não passar por baixo
              padding: EdgeInsets.only(right: IMG_TITULAR_W + 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Partido:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 78,
                  ),
                  Flexible(
                    child: Text(
                      candidatoId[2],
                      style: TextStyle(fontSize: 35),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FadeAnimatedTextKit(
                    onTap: () {
                      print("Tap Event");
                    },
                    repeatForever: true,
                    text: ["VOTO NULO", "VOTO NULO"],
                    textStyle: TextStyle(
                        fontSize: 50.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                    alignment: AlignmentDirectional.topStart),
              ],
            ),
    );
  }

  Padding _blanckVoteAnimation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 30, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FadeAnimatedTextKit(
              onTap: () {
                print("Tap Event");
              },
              repeatForever: true,
              text: ["VOTO EM BRANCO", "VOTO EM BRANCO"],
              textStyle: TextStyle(fontSize: 60.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
              alignment: AlignmentDirectional.topStart),
        ],
      ),
    );
  }

  Padding _numErrorTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 30, 0, 0),
      child: candidatoId.isNotEmpty
          ? Padding(
              // reserva espaço da foto pra o nome não passar por baixo
              padding: EdgeInsets.only(right: IMG_TITULAR_W + 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Nome:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 88,
                  ),
                  Flexible(
                    child: Text(
                      candidatoId[1],
                      style: TextStyle(fontSize: 35),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'NÚMERO ERRADO',
                  style: TextStyle(fontSize: 35),
                )
              ],
            ),
    );
  }

  Padding _boxVoteStatic() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(160, 0, 0, 0),
      child: _digitBoxes(),
    );
  }

  Padding _boxVoteMutable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Número:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 20,
          ),
          _digitBoxes(),
        ],
      ),
    );
  }

  Padding _label() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(160, 0, 0, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Text(
          cargoNome,
          style: TextStyle(fontSize: 40),
        )
      ]),
    );
  }

  Padding _title() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 30, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'SEU VOTO PARA',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Expanded _footer() {
    // se tem vice (governador), reserva espaço à direita pra não sobrepor
    final double rightPad = candidatoId.length >= 5 ? IMG_VICE_W + 10 : 0;
    return Expanded(
      child: Column(
        children: <Widget>[
          Divider(color: Colors.black),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 30, 0, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (Text(
                  'Aperte a tecla:',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(120, 0, rightPad, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    'VERDE para CONFIRMAR este voto',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(120, 0, rightPad, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    'LARANJA para REINICIAR este voto',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
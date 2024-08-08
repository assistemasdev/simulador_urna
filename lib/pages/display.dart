import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class Display extends StatelessWidget {
  final String text;
  final int bufferIndex;
  final List buffer;
  List vereadorId;
  List prefeitoId;

  Display(this.text, this.bufferIndex, this.buffer, this.vereadorId,
      this.prefeitoId);

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
            child: bufferIndex == 0 && buffer[0] == 'BRANCO'
                ? blankcolumn()
                : buffer[1] == 'BRANCO' ? blankcolumn() : normalcolumn(),
          ),
          vereadorId.isNotEmpty
              ? Positioned(
                  top: 60,
                  right: 0,
                  child: Image.asset(
                    vereadorId[3],
                    height: 350,
                    width: 300,
                    fit: BoxFit.cover,
                  ))
              : prefeitoId.isNotEmpty
                  ? Positioned(
                      top: 60,
                      right: 0,
                      child: Image.asset(
                        prefeitoId[3],
                        height: 350,
                        width: 300,
                        fit: BoxFit.cover,
                      ))
                  : SizedBox(),
          prefeitoId.isNotEmpty
              ? Positioned(
                  bottom: 30,
                  right: 0,
                  child: Image.asset(
                    prefeitoId[4],
                    height: 240,
                    width: 200,
                    fit: BoxFit.cover,
                  ))
              : SizedBox(),
        ],
      ),
    );
  }

  Column blankcolumn() {
    return Column(
      children: <Widget>[
        buffer.isNotEmpty
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
        buffer.isNotEmpty ? _blanckVoteAnimation() : SizedBox(),
        SizedBox(
          height: 130,
        ),
        buffer.isNotEmpty ? _footer() : SizedBox()
      ],
    );
  }

  Column normalcolumn() {
    return Column(
      children: <Widget>[
        text.length >= 2
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
      child: vereadorId.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Partido:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 78,
                ),
                Text(
                  vereadorId[2],
                  style: TextStyle(fontSize: 35),
                )
              ],
            )
          : prefeitoId.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Partido:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 78,
                    ),
                    Text(
                      prefeitoId[2],
                      style: TextStyle(fontSize: 35),
                    )
                  ],
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
                        alignment: AlignmentDirectional
                            .topStart // or Alignment.topLeft
                        ),
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
              alignment: AlignmentDirectional.topStart // or Alignment.topLeft
              ),
        ],
      ),
    );
  }

  Padding _numErrorTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 30, 0, 0),
      child: vereadorId.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Nome:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 88,
                ),
                Text(
                  vereadorId[1],
                  style: TextStyle(fontSize: 35),
                )
              ],
            )
          : prefeitoId.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Nome:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 88,
                    ),
                    Text(
                      prefeitoId[1],
                      style: TextStyle(fontSize: 35),
                    )
                  ],
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
      child: Stack(
        children: [
          bufferIndex == 0
              ? Image.asset(
                  'assets/images/vereador.png',
                  width: 150,
                  height: 60,
                )
              : Image.asset(
                  'assets/images/prefeito.png',
                  width: 60,
                  height: 60,
                ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            Text(
              text,
              style: TextStyle(fontSize: 50, letterSpacing: 1.2),
            )
          ])
        ],
      ),
    );
  }

  Padding _boxVoteMutable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Stack(
        children: [
          bufferIndex == 0
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(152, 0, 0, 0),
                  child: Image.asset(
                    'assets/images/vereador.png',
                    width: 150,
                    height: 60,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(152, 0, 0, 0),
                  child: Image.asset(
                    'assets/images/prefeito.png',
                    width: 60,
                    height: 60,
                  ),
                ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            Text(
              "Número:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(75, 0, 0, 0),
              child: Text(
                text,
                style: TextStyle(fontSize: 50, letterSpacing: 1.2),
              ),
            )
          ])
        ],
      ),
    );
  }

  Padding _label() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(160, 0, 0, 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        bufferIndex == 0
            ? Text(
                'Vereador',
                style: TextStyle(fontSize: 40),
              )
            : Text(
                'Prefeito',
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
    return Expanded(
      child: Column(
        children: <Widget>[
          Divider(color: Colors.black),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 30, 0, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                (Text(
                  'Aperte a tecla:',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ))
              ],
            ),
          ),
          prefeitoId.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(120, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      (Text(
                        'VERDE para CONFIRMAR este voto',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ))
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    (Text(
                      'VERDE para CONFIRMAR este voto',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ))
                  ],
                ),
          prefeitoId.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(120, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      (Text(
                        'LARANJA para REINICIAR este voto',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ))
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    (Text(
                      'LARANJA para REINICIAR este voto',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ))
                  ],
                ),
        ],
      ),
    );
  }
}

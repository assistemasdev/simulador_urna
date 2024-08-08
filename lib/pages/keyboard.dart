import 'package:flutter/material.dart';
import 'package:urna_eletronica/pages/dashboard.dart';
import 'package:urna_eletronica/util/nav.dart';
import 'package:urna_eletronica/widgets/app_buttons.dart';

class Keyboard extends StatelessWidget {
  final void Function(String) cb;

  Keyboard(this.cb);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 40,
        right: 20,
        width: 420,
        height: 695,
        child: Container(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onLongPress: () {
                  print('OnLongPRESS');
                  push(context, Dashboard(), replace: true);
                },
                child: Row(
                  children: <Widget>[
                    /* Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/images/brasao.png',
                        width: 110,
                        height: 110,
                      ),
                    ), */
                    Expanded(
                      child: Text(
                        "PESQUISA ELEITORAL",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 55,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey[850],
                height: 565,
                width: 420,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Button(
                          text: '1',
                          cb: cb,
                        ),
                        Button(
                          text: '2',
                          cb: cb,
                        ),
                        Button(
                          text: '3',
                          cb: cb,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Button(
                          text: '4',
                          cb: cb,
                        ),
                        Button(
                          text: '5',
                          cb: cb,
                        ),
                        Button(
                          text: '6',
                          cb: cb,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Button(
                          text: '7',
                          cb: cb,
                        ),
                        Button(
                          text: '8',
                          cb: cb,
                        ),
                        Button(
                          text: '9',
                          cb: cb,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Button(
                          text: '0',
                          cb: cb,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Button.white(
                          text: 'BRANCO',
                          cb: cb,
                        ),
                        Button.orange(
                          text: 'CORRIGE',
                          cb: cb,
                        ),
                        Button.green(
                          text: 'CONFIRMA',
                          cb: cb,
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:urna_eletronica/helpers/urna_helper.dart';
import 'package:urna_eletronica/pages/home_page.dart';
import 'package:urna_eletronica/util/nav.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  UrnaHelper helper = UrnaHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Compartilhar ou deletar toda a pesquisa."),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                'Compartilhar ou deletar toda a pesquisa.',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.share),
                  //FIXME: Ajuster estilos
                  // color: Colors.blue,
                  // textColor: Colors.white,
                  // disabledColor: Colors.grey,
                  // disabledTextColor: Colors.black,
                  // padding: EdgeInsets.all(8.0),
                  // splashColor: Colors.blueAccent,
                  onPressed: () {
                    print('press');
                    _shareCSV();
                    helper.query().then((list) => print(list));
                  },
                  label: Text(
                    "Compartilhar pesquisa",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                SizedBox(
                  width: 40,
                ),
                TextButton.icon(
                  icon: Icon(Icons.delete_forever),
                  //FIXME: Ajuster estilos
                  // color: Colors.red,
                  // textColor: Colors.white,
                  // disabledColor: Colors.grey,
                  // disabledTextColor: Colors.black,
                  // padding: EdgeInsets.all(8.0),
                  // splashColor: Colors.blueAccent,
                  onPressed: () => _onClickDialog(context),
                  label: Text(
                    "Deletar pesquisa",
                    style: TextStyle(fontSize: 20.0),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onClickLogout(context),
        child: Icon(Icons.close),
      ),
    );
  }

  _onClickDialog(context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Tem certeza que deseja apagar toda a pesquisa?"),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")),
              TextButton(
                  onPressed: () {
                    print('delete');
                    helper.deleteQuery();
                    helper.deleteFile();
                    _onClickLogout(context);
                  },
                  child: Text("Sim"))
            ],
          );
        });
  }

  _shareCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/votos.csv');
    return ShareExtend.share(file.path, "file");
  }

  _onClickLogout(BuildContext context) {
    push(context, HomePage(), replace: true);
  }
}

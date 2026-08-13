import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urna_eletronica/pages/dashboard.dart';
import 'package:urna_eletronica/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,   // paisagem normal
    DeviceOrientation.landscapeRight,  // paisagem invertida (180°)
  ]).then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador de Urna Eletrônica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
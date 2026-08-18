import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urna_eletronica/pages/address_screen.dart'; // <-- Importe a tela de endereço
// import 'package:urna_eletronica/pages/home_page.dart'; // <-- Pode remover ou manter, mas não use como home

void main() {
  WidgetsFlutterBinding.ensureInitialized();  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,   // paisagem normal
    DeviceOrientation.landscapeRight,  // paisagem invertida (180°)
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador de Urna Eletrônica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green, // Mudei para verde para combinar com a urna
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AddressScreen(), // <-- AQUI: Inicia na tela de endereço, não na HomePage
    );
  }
}
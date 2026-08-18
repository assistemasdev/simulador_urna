import 'package:flutter/material.dart';
import 'package:urna_eletronica/model/memory.dart';
import 'package:urna_eletronica/pages/home_page.dart';

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _enderecoController = TextEditingController();
  final Memory memory = Memory();

  void _iniciarVotacao() {
    if (_enderecoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe o endereço/local desta pesquisa.'), backgroundColor: Colors.red),
      );
      return;
    }
    memory.setEndereco(_enderecoController.text.trim());
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())).then((_) {
      _enderecoController.clear(); // Limpa ao voltar
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: 600, padding: EdgeInsets.all(40),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.how_to_vote, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text('Nova Pesquisa Eleitoral', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('Informe o endereço ou local de votação para esta pesquisa específica:', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
              SizedBox(height: 30),
              TextField(
                controller: _enderecoController,
                decoration: InputDecoration(labelText: 'Endereço / Local de Votação', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _iniciarVotacao,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('INICIAR VOTAÇÃO', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
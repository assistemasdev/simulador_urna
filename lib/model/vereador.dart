class VereadorList {
  final List<Vereador> vereador;

  VereadorList({
    required this.vereador,
  });

  factory VereadorList.fromJson(List<dynamic> parsedJson) {
    List<Vereador> vereador = parsedJson.map((i) => Vereador.fromJson(i)).toList();

    return VereadorList(vereador: vereador);
  }
}

class Vereador {
  final String numero;
  final String nome;
  final String partido;
  final String imagePath;

  Vereador({required this.numero, required this.nome, required this.partido, required this.imagePath});

  factory Vereador.fromJson(Map<String, dynamic> json) {
    return Vereador(
      numero: json['numero'] as String,
      nome: json['nome'] as String,
      partido: json['partido'] as String,
      imagePath: json['imagePath'] as String,
    );
  }
}

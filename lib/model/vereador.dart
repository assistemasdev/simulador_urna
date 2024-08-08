class VereadorList {
  final List<Vereador> vereador;

  VereadorList({
    this.vereador,
  });

  factory VereadorList.fromJson(List<dynamic> parsedJson) {
    List<Vereador> vereador = List<Vereador>();
    vereador = parsedJson.map((i) => Vereador.fromJson(i)).toList();

    return VereadorList(vereador: vereador);
  }
}

class Vereador {
  final String numero;
  final String nome;
  final String partido;
  final String imagePath;

  Vereador({this.numero, this.nome, this.partido, this.imagePath});

  factory Vereador.fromJson(Map<String, dynamic> json) {
    return Vereador(
      numero: json['numero'],
      nome: json['nome'],
      partido: json['partido'],
      imagePath: json['imagePath'],
    );
  }
}

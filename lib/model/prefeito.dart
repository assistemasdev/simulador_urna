class PrefeitoList {
  final List<Prefeito> prefeito;

  PrefeitoList({
    this.prefeito,
  });

  factory PrefeitoList.fromJson(List<dynamic> parsedJson) {
    List<Prefeito> prefeito = List<Prefeito>();
    prefeito = parsedJson.map((i) => Prefeito.fromJson(i)).toList();

    return PrefeitoList(prefeito: prefeito);
  }
}

class Prefeito {
  final String numero;
  final String nome;
  final String partido;
  final String imagePath;
  final String imagePathVice;

  Prefeito(
      {this.numero,
      this.nome,
      this.partido,
      this.imagePath,
      this.imagePathVice});

  factory Prefeito.fromJson(Map<String, dynamic> json) {
    return Prefeito(
      numero: json['numero'],
      nome: json['nome'],
      partido: json['partido'],
      imagePath: json['imagePath'],
      imagePathVice: json['imagePathVice'],
    );
  }
}

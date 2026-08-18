class PrefeitoList {
  final List<Prefeito> prefeito;

  PrefeitoList({
    required this.prefeito,
  });

  factory PrefeitoList.fromJson(List<dynamic> parsedJson) {
    List<Prefeito> prefeito = parsedJson.map((i) => Prefeito.fromJson(i)).toList();

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
      {required this.numero,
      required this.nome,
      required this.partido,
      required this.imagePath,
      required this.imagePathVice});

  factory Prefeito.fromJson(Map<String, dynamic> json) {
    return Prefeito(
      numero: json['numero'] as String,
      nome: json['nome'] as String,
      partido: json['partido'] as String,
      imagePath: json['imagePath'] as String,
      imagePathVice: json['imagePathVice'] as String,
    );
  }
}

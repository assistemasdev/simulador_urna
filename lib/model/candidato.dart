class Candidato {
  final String cargo;
  final String sqCandidato;
  final String numero;
  final String nome;
  final String partido;

  Candidato({
    required this.cargo,
    required this.sqCandidato,
    required this.numero,
    required this.nome,
    required this.partido,
  });

  String get imagePath {
    bool ehPresidencial = cargo == 'PRESIDENTE' || cargo == 'VICE-PRESIDENTE';
    String prefixo = ehPresidencial ? 'FBR' : 'FCE';
    
    // Ex: assets/images/eleicoes2026/FBR280002542548_div.jpg
    return 'assets/images/eleicoes2026/${prefixo}${sqCandidato}_div.jpg';
  }
}
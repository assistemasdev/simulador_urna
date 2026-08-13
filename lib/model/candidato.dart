class Candidato {
  final String cargo;
  final String sqCandidato;
  final String numero;
  final String nome;
  final String partido;

  Candidato({
    this.cargo,
    this.sqCandidato,
    this.numero,
    this.nome,
    this.partido,
  });

  /// FCE{SQ_CANDIDATO}_div.jpg
  String get imagePath => 'assets/images/eleicoes2026/FCE${sqCandidato}_div.jpg';

  @override
  String toString() {
    return "Candidato(cargo: $cargo, numero: $numero, nome: $nome, partido: $partido)";
  }
}
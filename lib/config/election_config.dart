enum Cargo {
  PRESIDENTE,
  DEPUTADO_FEDERAL,
  DEPUTADO_ESTADUAL,
  SENADOR,
  GOVERNADOR,
  VEREADOR,
  PREFEITO,
}

class CargoConfig {
  final Cargo cargo;
  final String nome;
  final int digitos;
  final String dsCargo;
  final String tableVotos;

  CargoConfig({this.cargo, this.nome, this.digitos, this.dsCargo, this.tableVotos});
}

class ElectionConfig {
  static const ElectionType currentElection = ElectionType.GERAL_2026;
  
  static List<CargoConfig> getCargosAtivos() {
    switch (currentElection) {
      case ElectionType.GERAL_2026:
        return [
          CargoConfig(cargo: Cargo.PRESIDENTE, nome: 'Presidente', digitos: 2, dsCargo: 'PRESIDENTE', tableVotos: 'votoPresidente'),
          CargoConfig(cargo: Cargo.DEPUTADO_FEDERAL, nome: 'Deputado Federal', digitos: 4, dsCargo: 'DEPUTADO FEDERAL', tableVotos: 'votoDeputadoFederal'),
          CargoConfig(cargo: Cargo.DEPUTADO_ESTADUAL, nome: 'Deputado Estadual', digitos: 5, dsCargo: 'DEPUTADO ESTADUAL', tableVotos: 'votoDeputadoEstadual'),
          CargoConfig(cargo: Cargo.SENADOR, nome: 'Senador', digitos: 3, dsCargo: 'SENADOR', tableVotos: 'votoSenador'),
          CargoConfig(cargo: Cargo.GOVERNADOR, nome: 'Governador', digitos: 2, dsCargo: 'GOVERNADOR', tableVotos: 'votoGovernador'),
        ];
      case ElectionType.MUNICIPAL_2028:
        return [
          CargoConfig(cargo: Cargo.VEREADOR, nome: 'Vereador', digitos: 5, dsCargo: 'assets/json/vereador.json', tableVotos: 'votoVereador'),
          CargoConfig(cargo: Cargo.PREFEITO, nome: 'Prefeito', digitos: 2, dsCargo: 'assets/json/prefeito.json', tableVotos: 'votoPrefeito'),
        ];
    }
    return [];
  }
}

      case ElectionType.MUNICIPAL_2028:
        return [
          CargoConfig(
            cargo: Cargo.VEREADOR,
            nome: 'Vereador',
            digitos: 5,
            dsCargo: 'assets/json/vereador.json',
            tableVotos: 'votoVereador',
          ),
          CargoConfig(
            cargo: Cargo.PREFEITO,
            nome: 'Prefeito',
            digitos: 2,
            dsCargo: 'assets/json/prefeito.json',
            tableVotos: 'votoPrefeito',
          ),
        ];
    }
    return [];
  }
}
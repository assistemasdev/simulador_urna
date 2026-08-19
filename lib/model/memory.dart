import 'package:audioplayers/audioplayers.dart';
import 'dart:async' show Future;
import 'package:urna_eletronica/helpers/urna_helper.dart';
import 'package:urna_eletronica/helpers/candidatos_helper.dart';
import 'package:urna_eletronica/config/election_config.dart';

class Memory {
  UrnaHelper helper = UrnaHelper();
  final CandidatosHelper _candidatosHelper = CandidatosHelper();

  final List<CargoConfig> _cargos = ElectionConfig.getCargosAtivos();
  int _currentCargoIndex = 0;

  Map<String, String> _votosMap = {};
  String _endereco = ''; // <-- NOVO

  String _value = '';
  bool _wipeValue = false;
  List _candidatoId = [];
  bool _voteFinished = false;

  CargoConfig get currentCargo => _cargos[_currentCargoIndex];
  bool get isLastCargo => _currentCargoIndex == _cargos.length - 1;
  bool get voteFinished => _voteFinished;
  String get endereco => _endereco; // <-- NOVO

  void setEndereco(String endereco) { _endereco = endereco; }
  void resetVote() { _voteFinished = false; }

  void applyCommand(String text) {
    if (text == 'CORRIGE') { _allClear(); } 
    else if (text == 'BRANCO') { _blanck(text); } 
    else if (text == 'CONFIRMA') { _confirma(); } 
    else { _addDigit(text); }
  }

  _confirma() {
    _votosMap[currentCargo.tableVotos] = _value.isEmpty ? 'BRANCO' : _value;

    if (isLastCargo) {
      _value = '';
      _candidatoId = [];
      playSoundConfirm();
      saveVote();
      _voteFinished = true;
    } else {
      _value = '';
      _candidatoId = [];
      _currentCargoIndex++;
      playSoundConfirm();
    }
  }

  _addDigit(String digit) {
    final currentValue = _wipeValue ? '' : _value;
    if (_value.length >= currentCargo.digitos) return;
    _value = currentValue + digit;
    _wipeValue = false;
  }

  _allClear() { _value = ''; _candidatoId = []; }
  _blanck(String text) { if (_value.isEmpty) _value = text; }

  String get value => _value;
  int get currentCargoIndex => _currentCargoIndex;
  List<CargoConfig> get cargos => _cargos;
  List get candidatoId => _candidatoId;

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSoundConfirm() async {
    await _player.play(AssetSource("som.mp3"));
  }

  Future loadCandidatos(String numero) async {
    try {
      final candidato = await _candidatosHelper.buscar(currentCargo.dsCargo, numero);

      if (candidato != null) {
        _candidatoId = [candidato.numero, candidato.nome, candidato.partido, candidato.imagePath];

        if (currentCargo.cargo == Cargo.PRESIDENTE || currentCargo.cargo == Cargo.GOVERNADOR) {
          final vice = await _candidatosHelper.buscarVice(numero, currentCargo.dsCargo);
          if (vice != null) {
            _candidatoId.addAll([vice.imagePath, vice.nome, vice.partido]);
          } else {
            _candidatoId.addAll(['', 'Vice não encontrado', '']);
          }
        }
      } else {
        _candidatoId = [];
      }
    } catch (e) {
      print('[MEMORIA] ❌ Erro: $e');
      _candidatoId = [];
    }
  }

  Future saveVote() async {
    _votosMap['endereco_pesquisa'] = _endereco; // <-- SALVA O ENDEREÇO
    print('Votos salvos: $_votosMap');
    try {
      await helper.saveVoto(_votosMap);
    } catch (e) {
      print('[MEMORIA] ❌ Erro ao salvar voto no banco: $e');
      rethrow;
    }
    return helper.getAllVotos().then((list) => print('Total no DB: ${list.length}'));
  }

  void resetForNewVote() {
    _votosMap = {};
    _currentCargoIndex = 0;
    _value = '';
    _candidatoId = [];
    _endereco = ''; // <-- LIMPA O ENDEREÇO PARA O PRÓXIMO
  }
}
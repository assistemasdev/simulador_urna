import 'package:audioplayers/audio_cache.dart';
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

  String _value = '';
  bool _wipeValue = false;
  List _candidatoId = [];
  bool _voteFinished = false;

  CargoConfig get currentCargo => _cargos[_currentCargoIndex];

  bool get isLastCargo => _currentCargoIndex == _cargos.length - 1;

  bool get voteFinished => _voteFinished;

  void resetVote() {
    _voteFinished = false;
  }

  void applyCommand(String text) {
    if (text == 'CORRIGE') {
      _allClear();
    } else if (text == 'BRANCO') {
      _blanck(text);
    } else if (text == 'CONFIRMA') {
      _confirma();
    } else {
      _addDigit(text);
    }
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
    if (_value.length >= currentCargo.digitos) {
      return;
    } else {
      _value = currentValue + digit;
      _wipeValue = false;
    }
  }

  _allClear() {
    _value = '';
    _candidatoId = [];
  }

  _blanck(String text) {
    if (_value.isEmpty) {
      _value = text;
    }
  }

  String get value => _value;

  int get currentCargoIndex => _currentCargoIndex;

  List<CargoConfig> get cargos => _cargos;

  Future<AudioPlayer> playSoundConfirm() async {
    AudioCache cache = new AudioCache();
    return await cache.play("som.mp3");
  }

  /// Busca candidato pelo número digitado, usando o CSV via helper
    Future loadCandidatos(String numero) async {
    try {
      final candidato =
          await _candidatosHelper.buscar(currentCargo.dsCargo, numero);

      if (candidato != null) {
        _candidatoId = [];
        _candidatoId.add(candidato.numero);
        _candidatoId.add(candidato.nome);
        _candidatoId.add(candidato.partido);
        _candidatoId.add(candidato.imagePath);

        if (currentCargo.cargo == Cargo.GOVERNADOR) {
          final vice = await _candidatosHelper.buscarVice(numero);
          if (vice != null) {
            _candidatoId.add(vice.imagePath);
            _candidatoId.add(vice.nome);
          }
        }
      } else {
        _candidatoId = [];
      }
      print('Candidato: $_candidatoId');
    } catch (e) {
      print('[MEMORIA] ❌ Erro ao carregar candidato: $e');
      _candidatoId = [];
    }
  }

  List get candidatoId => _candidatoId;

  Future saveVote() async {
    print('Votos: $_votosMap');
    await helper.saveVoto(_votosMap);
    _votosMap = {};
    _currentCargoIndex = 0;
    return helper.getAllVotos().then((list) => print(list));
  }

  void resetForNewVote() {
    _votosMap = {};
    _currentCargoIndex = 0;
    _value = '';
    _candidatoId = [];
  }
}
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:urna_eletronica/helpers/urna_helper.dart';
import 'package:urna_eletronica/model/prefeito.dart';
import 'dart:convert';
import 'package:urna_eletronica/model/vereador.dart';

class Memory {
  UrnaHelper helper = UrnaHelper();

  Votos v = Votos();

  static const operations = const ['CONFIRMA'];

  final _buffer = ['', ''];
  var _bufferTemp = [];
  int _bufferIndex = 0;
  String _operation;
  String _value = '';
  bool _wipeValue = false;
  List _vereadorId = [];
  List _prefeitoId = [];

  void applyCommand(String text) {
    if (text == 'CORRIGE') {
      _allClear();
    } else if (text == 'BRANCO') {
      _blanck(text);
    } else if (operations.contains(text)) {
      _setOperation(text);
    } else {
      _addDigit(text);
    }
  }

  _setOperation(String newOperation) {
    if (_bufferIndex == 0) {
      _bufferTemp.add(_buffer[0]);
      _operation = newOperation;
      _value = '';
      _vereadorId = [];
      _bufferIndex = 1;
    } else {
      _bufferTemp.add(_buffer[1]);
      _value = '';
      _prefeitoId = [];
      _buffer.setAll(0, ['', '']);
      _bufferIndex = 0;
      _operation = null;
      playSoundConfirm();
      saveVote(_bufferTemp);
      _bufferTemp = [];
    }
  }

  _addDigit(String digit) {
    final currentValue = _wipeValue ? '' : _value;
    if (_bufferIndex == 0 && _value.length >= 5) {
      return;
    } else if (_bufferIndex == 0 && _value.length < 5) {
      _value = currentValue + digit;
      _wipeValue = false;
      _buffer[_bufferIndex] = _value;
    } else if (_bufferIndex == 1 && _value.length >= 2) {
      return;
    } else if (_bufferIndex == 1 && _value.length < 2) {
      _value = currentValue + digit;
      _wipeValue = false;
      _buffer[_bufferIndex] = _value;
    }
  }

  _allClear() {
    if (_bufferIndex == 0) {
      _buffer[0] = '';
      _value = '';
      _vereadorId = [];
    } else if (_bufferIndex == 1) {
      _buffer[1] = '';
      _prefeitoId = [];
      _value = '';
    }
  }

  _blanck(text) {
    if (_bufferIndex == 0 && _value.isEmpty) {
      _buffer[_bufferIndex] = text;
      //print('$text no index0');
    } else if (_bufferIndex == 0 && _value.isNotEmpty) {
      //print('limpeo campo 0 com corrigir');
    } else if (_bufferIndex == 1 && _value.isEmpty) {
      _buffer[_bufferIndex] = text;
      //print('$text no index1');
    } else if (_bufferIndex == 1 && _value.isNotEmpty) {
      //print('limpeo campo 1 com corrigir');
    }
    //print(_buffer);
  }

  String get value {
    return _value;
  }

  int get bufferIndex {
    return _bufferIndex;
  }

  List get buffer {
    return _buffer;
  }

  Future<AudioPlayer> playSoundConfirm() async {
    AudioCache cache = new AudioCache();
    //At the next line, DO NOT pass the entire reference such as assets/yes.mp3. This will not work.
    //Just pass the file name only.
    return await cache.play("som.mp3");
  }

  Future<String> _loadVereadorAsset() async {
    return await rootBundle.loadString('assets/json/vereador.json');
  }

  Future<String> _loadPrefeitoAsset() async {
    return await rootBundle.loadString('assets/json/prefeito.json');
  }

  Future loadVereadores(text) async {
    String jsonVereadores = await _loadVereadorAsset();
    final jsonResponse = json.decode(jsonVereadores);
    VereadorList vereadorList = VereadorList.fromJson(jsonResponse);
    for (var vereador in vereadorList.vereador) {
      if (vereador.numero == text) {
        _vereadorId.add(vereador.numero);
        _vereadorId.add(vereador.nome);
        _vereadorId.add(vereador.partido);
        _vereadorId.add(vereador.imagePath);
      }
    }
    print(_vereadorId);
  }

  Future loadPrefeitos(text) async {
    String jsonPrefeitos = await _loadPrefeitoAsset();
    final jsonResponse = json.decode(jsonPrefeitos);
    PrefeitoList prefeitoList = PrefeitoList.fromJson(jsonResponse);
    for (var prefeito in prefeitoList.prefeito) {
      if (prefeito.numero == text) {
        _prefeitoId.add(prefeito.numero);
        _prefeitoId.add(prefeito.nome);
        _prefeitoId.add(prefeito.partido);
        _prefeitoId.add(prefeito.imagePath);
        _prefeitoId.add(prefeito.imagePathVice);
      }
    }
    print(_prefeitoId);
  }

  List get vereadorId {
    return _vereadorId;
  }

  void set vereadorId(List value) => _vereadorId = value;

  List get prefeitoId {
    return _prefeitoId;
  }

  void set prefeitoId(List value) => _vereadorId = value;

  Future saveVote(List list) async {
    v.vereador = list[0];
    v.prefeito = list[1];
    print('Vereador ${v.vereador} e prefeito ${v.prefeito}');
    helper.saveVotos(v);
    return helper.getAllVotos().then((list) => print(list));
  }
}

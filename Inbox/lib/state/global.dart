import 'dart:async';

import 'package:Inbox/models/message.dart';

class GlobalState {
  static final GlobalState _gState = GlobalState._internal();
  Map<String, StreamController> controllers;
  Map<String, dynamic> _state;

  factory GlobalState() {
    return _gState;
  }

  GlobalState._internal() {
    controllers = {};
    _state = {};
  }

  void listener(void Function(Map<String, dynamic>) callback) {
    callback(_state);
  }

  void setState(String key, dynamic value) {
    if (_state.containsKey(key)) {
      _state[key].add(value);
    } else {
      _state[key] = [value];
      controllers[key].add(value);
    }
  }

  operator [](String index) => _state[index];
  operator []=(String key, dynamic value) {
    setState(key, value);
  }

  void setMessage(String userId, dynamic value) {
    setState('${userId}_messages', value);
  }

  dynamic getLastMessage(String userId) {
    String key = '${userId}_messages';
    if (!_state.containsKey(key)) {
      return null;
    }
    return (_state[key][_state[key].length - 1]).assets;
  }

  void popMessage(String userId, dynamic bubble) {
    String key = '${userId}_messages';
    (_state[key] as List).remove(bubble);
  }

  void popAssetUsingHash(String userId, int hash, dynamic asset) {
    String key = '${userId}_messages';
    for (int index = 0; index < (_state[key] as List).length; index++) {
      if (_state[key][index].hashCode == hash) {
        _state[key][index] = (_state[key][index].assets as List<Asset>)
            .where((element) => element != asset);
        if ((_state[key][index].assets as List<Asset>).isEmpty) {
          (_state[key] as List).removeAt(index);
        }
      }
    }
  }

  Stream getUserMessages(String userId) {
    String key = '${userId}_messages';

    void start() {
      if (_state.containsKey(key) || _state[key] == null) {
        _state[key] = [];
      }
      for (var message in _state[key]) {
        controllers[userId].add(message);
      }
    }

    void stop() {
      controllers[userId].close();
    }

    controllers[userId] = StreamController(
        onListen: start, onCancel: stop, onPause: stop, onResume: start);

    return controllers[userId].stream;
  }
}

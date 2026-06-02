import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/zikr_model.dart';

class ZikrProvider extends ChangeNotifier {
  static const _storageKey = 'zikr_list';
  static const _activeZikrKey = 'active_zikr_id';

  List<ZikrModel> _zikrs = ZikrModel.defaultZikrs;
  bool _isInitialized = false;
  String? _activeId;

  List<ZikrModel> get zikrs => List.unmodifiable(_zikrs);
  bool get isInitialized => _isInitialized;
  String get activeId => _activeId ?? (_zikrs.isNotEmpty ? _zikrs.first.id : '');
  int get activeIndex => _zikrs.indexWhere((z) => z.id == activeId).clamp(0, _zikrs.isEmpty ? 0 : _zikrs.length - 1);
  ZikrModel get activeZikr => _zikrs.isNotEmpty
      ? _zikrs.firstWhere((z) => z.id == activeId, orElse: () => _zikrs.first)
      : ZikrModel.defaultZikrs.first;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadFromStorage();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setActive(String id) async {
    if (!_zikrs.any((z) => z.id == id)) return;
    _activeId = id;
    await _persistActive();
    notifyListeners();
  }

  Future<void> increment(String id) async {
    await _updateZikr(id, (zikr) => zikr.copyWith(currentCount: zikr.currentCount + 1));
  }

  Future<void> decrement(String id) async {
    await _updateZikr(
      id,
      (zikr) {
        final next = (zikr.currentCount - 1).clamp(0, zikr.targetCount).toInt();
        return zikr.copyWith(currentCount: next);
      },
    );
  }

  Future<void> reset(String id) async {
    await _updateZikr(id, (zikr) => zikr.copyWith(currentCount: 0));
  }

  Future<void> upsertCustom(ZikrModel zikr) async {
    final index = _zikrs.indexWhere((z) => z.id == zikr.id);
    if (index == -1) {
      _zikrs = [..._zikrs, zikr];
    } else {
      _zikrs = [..._zikrs]..[index] = zikr;
    }
    _ensureActiveExists();
    await _persist();
    notifyListeners();
  }

  Future<void> removeCustom(String id) async {
    _zikrs = _zikrs.where((z) => z.id != id || !z.isCustom).toList(growable: false);
    _ensureActiveExists();
    await _persist();
    notifyListeners();
  }

  Future<void> _updateZikr(String id, ZikrModel Function(ZikrModel) transformer) async {
    final index = _zikrs.indexWhere((z) => z.id == id);
    if (index == -1) return;
    _zikrs = [..._zikrs]..[index] = transformer(_zikrs[index]);
    await _persist();
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) {
      _zikrs = ZikrModel.defaultZikrs;
    } else {
      try {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        _zikrs = decoded.map((e) => ZikrModel.fromMap(Map<String, dynamic>.from(e as Map))).toList(growable: false);
      } catch (_) {
        _zikrs = ZikrModel.defaultZikrs;
      }
    }

    final storedActive = prefs.getString(_activeZikrKey);
    if (storedActive != null && _zikrs.any((z) => z.id == storedActive)) {
      _activeId = storedActive;
    }
    _ensureActiveExists();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(_zikrs.map((z) => z.toMap()).toList());
    await prefs.setString(_storageKey, payload);
    await _persistActive(prefs: prefs);
  }

  Future<void> _persistActive({SharedPreferences? prefs}) async {
    final storage = prefs ?? await SharedPreferences.getInstance();
    final idToStore = _zikrs.isNotEmpty ? activeId : null;
    if (idToStore != null && idToStore.isNotEmpty) {
      await storage.setString(_activeZikrKey, idToStore);
    }
  }

  void _ensureActiveExists() {
    if (_zikrs.isEmpty) {
      _activeId = null;
      return;
    }
    if (_activeId == null || !_zikrs.any((z) => z.id == _activeId)) {
      _activeId = _zikrs.first.id;
    }
  }
}

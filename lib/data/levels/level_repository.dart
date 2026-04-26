import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:wordarc/domain/models/level.dart';
import 'package:wordarc/domain/models/pack.dart';

class LevelRepository {
  Future<List<Pack>> loadPacks() async {
    final json = await rootBundle.loadString('assets/levels/manifest.json');
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    final list = decoded['packs'] as List<dynamic>;
    return list
        .map((e) => Pack.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Level> loadLevel(String assetPath) async {
    final json = await rootBundle.loadString(assetPath);
    return Level.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }
}

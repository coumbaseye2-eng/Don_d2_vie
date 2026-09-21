import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme_provider.dart' show kHiveBoxParametres;

const _kCleLangue = 'langue';

class LangueOption {
  final String code;
  final String libelle;
  const LangueOption(this.code, this.libelle);
}

const languesSupportees = [
  LangueOption('fr', 'Français'),
  LangueOption('en', 'English'),
  LangueOption('wo', 'Wolof'),
];

class LangueNotifier extends StateNotifier<String> {
  LangueNotifier() : super(_lireLangueInitiale());

  static String _lireLangueInitiale() {
    final box = Hive.box(kHiveBoxParametres);
    return box.get(_kCleLangue, defaultValue: 'fr') as String;
  }

  Future<void> changerLangue(String code) async {
    state = code;
    await Hive.box(kHiveBoxParametres).put(_kCleLangue, code);
  }
}

final langueProvider = StateNotifierProvider<LangueNotifier, String>((ref) {
  return LangueNotifier();
});
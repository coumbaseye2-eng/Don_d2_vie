import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme_provider.dart' show kHiveBoxParametres;

const _kCleNotifications = 'notifications_activees';
const _kCleHistorique = 'historique_conserve';

class ParametresNotifications {
  final bool notificationsActivees;
  final bool historiqueConserve;
  const ParametresNotifications({
    required this.notificationsActivees,
    required this.historiqueConserve,
  });

  ParametresNotifications copierAvec({
    bool? notificationsActivees,
    bool? historiqueConserve,
  }) {
    return ParametresNotifications(
      notificationsActivees: notificationsActivees ?? this.notificationsActivees,
      historiqueConserve: historiqueConserve ?? this.historiqueConserve,
    );
  }
}

class ParametresNotificationsNotifier extends StateNotifier<ParametresNotifications> {
  ParametresNotificationsNotifier() : super(_lireInitial());

  static ParametresNotifications _lireInitial() {
    final box = Hive.box(kHiveBoxParametres);
    return ParametresNotifications(
      notificationsActivees: box.get(_kCleNotifications, defaultValue: true) as bool,
      historiqueConserve: box.get(_kCleHistorique, defaultValue: true) as bool,
    );
  }

  Future<void> toggleNotifications(bool valeur) async {
    state = state.copierAvec(notificationsActivees: valeur);
    await Hive.box(kHiveBoxParametres).put(_kCleNotifications, valeur);

    if (valeur) {
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    } else {
      await FirebaseMessaging.instance.setAutoInitEnabled(false);
      await FirebaseMessaging.instance.deleteToken();
    }
  }

  Future<void> toggleHistorique(bool valeur) async {
    state = state.copierAvec(historiqueConserve: valeur);
    await Hive.box(kHiveBoxParametres).put(_kCleHistorique, valeur);
  }

  Future<void> effacerHistorique() async {
    const nomBoxCacheLocal = 'historique_local';
    if (await Hive.boxExists(nomBoxCacheLocal)) {
      final box = await Hive.openBox(nomBoxCacheLocal);
      await box.clear();
    }
  }
}

final parametresNotificationsProvider =
StateNotifierProvider<ParametresNotificationsNotifier, ParametresNotifications>((ref) {
  return ParametresNotificationsNotifier();
}
);
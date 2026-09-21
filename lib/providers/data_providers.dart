import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge.dart';
import '../models/centre.dart';
import '../models/don.dart';
import '../services/firestore_service.dart';
import '../models/utilisateur.dart';
import '../models/urgence.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

final urgencesProvider = StreamProvider.family<List<Urgence>, String?>((ref, groupeSanguin) {
  return ref.watch(firestoreServiceProvider).streamUrgences(groupeSanguin: groupeSanguin);
});

final profilProvider = StreamProvider.family<Utilisateur?, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).streamUtilisateur(uid);
});
final centresProvider = FutureProvider.family<List<Centre>, String?>((ref, ville) {
  return ref.watch(firestoreServiceProvider).getCentres(ville: ville);
});

final historiqueDonsProvider = StreamProvider.family<List<Don>, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).streamHistoriqueDons(uid);
});

final badgesProvider = StreamProvider<List<DonBadge>>((ref) {
  return ref.watch(firestoreServiceProvider).streamBadges();
});
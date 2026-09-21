import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/utilisateur.dart';
import '../models/urgence.dart';
import '../models/centre.dart';
import '../models/don.dart';
import '../models/badge.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Future<void> creerProfil(Utilisateur utilisateur) async {
    await _db.collection('utilisateurs').doc(utilisateur.id).set(utilisateur.toMap());
  }

  Future<Utilisateur?> getUtilisateur(String id) async {
    final doc = await _db.collection('utilisateurs').doc(id).get();
    if (!doc.exists) return null;
    return Utilisateur.fromMap(doc.data()!, doc.id);
  }

  Stream<Utilisateur?> streamUtilisateur(String id) {
    return _db.collection('utilisateurs').doc(id).snapshots().map(
          (doc) => doc.exists ? Utilisateur.fromMap(doc.data()!, doc.id) : null,
    );
  }
  Future<void> mettreAJourPhoto(String uid, String photoUrl) async {
    await _db.collection('utilisateurs').doc(uid).update({'photoUrl': photoUrl});
  }

  Stream<List<Urgence>> streamUrgences({String? groupeSanguin}) {
    Query query = _db.collection('urgences').orderBy('dateCreation', descending: true);
    if (groupeSanguin != null && groupeSanguin != 'Tous') {
      query = query.where('groupeSanguinRequis', isEqualTo: groupeSanguin);
    }
    return query.snapshots().map(
          (snap) => snap.docs
          .map((doc) => Urgence.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }

  Future<Urgence?> getUrgence(String id) async {
    final doc = await _db.collection('urgences').doc(id).get();
    if (!doc.exists) return null;
    return Urgence.fromMap(doc.data()!, doc.id);
  }

  Future<List<Centre>> getCentres({String? ville}) async {
    Query query = _db.collection('centres');
    if (ville != null && ville.trim().isNotEmpty) {
      query = query.where('ville', isEqualTo: ville);
    }

    final snap = await query.get();
    final centres = snap.docs
        .map((doc) => Centre.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    if (centres.isNotEmpty) return centres;

    final centresParDefaut = [
      Centre(
        id: 'demo-dakar-1',
        nom: 'Centre de santé de Dakar',
        adresse: 'Avenue Cheikh Anta Diop, Dakar',
        ville: 'Dakar',
        statut: 'ouvert',
        latitude: 14.7167,
        longitude: -17.4677,
        tempsAttente: 18,
        imageUrl: 'https://images.unsplash.com/photo-1584515933487-779824d29309?auto=format&fit=crop&w=400&q=80',
      ),
      Centre(
        id: 'demo-dakar-2',
        nom: 'Hôpital principal',
        adresse: 'Place de l’Indépendance, Dakar',
        ville: 'Dakar',
        statut: 'ouvert',
        latitude: 14.6994,
        longitude: -17.4569,
        tempsAttente: 24,
        imageUrl: 'https://images.unsplash.com/photo-1538108149393-fbbd81895907?auto=format&fit=crop&w=400&q=80',
      ),
      Centre(
        id: 'demo-thies-1',
        nom: 'Centre de collecte Thiès',
        adresse: 'Boulevard Hassan II, Thiès',
        ville: 'Thiès',
        statut: 'ouvert',
        latitude: 14.7881,
        longitude: -16.9250,
        tempsAttente: 20,
        imageUrl: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=400&q=80',
      ),
    ];

    if (ville == null || ville.trim().isEmpty) {
      return centresParDefaut;
    }

    final centresFiltres = centresParDefaut
        .where((centre) => centre.ville.toLowerCase() == ville.toLowerCase())
        .toList();

    return centresFiltres.isNotEmpty ? centresFiltres : centresParDefaut;
  }

  Future<void> enregistrerDon(Don don) async {
    await _db.collection('dons').doc(don.id).set(don.toMap());
  }

  Stream<List<Don>> streamHistoriqueDons(String utilisateurId) {
    return _db
        .collection('dons')
        .where('utilisateurId', isEqualTo: utilisateurId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => Don.fromMap(doc.data(), doc.id))
        .toList());
  }


  Stream<List<DonBadge>> streamBadges() {
    return _db.collection('badges').snapshots().map(
          (snap) => snap.docs.map((doc) => DonBadge.fromMap(doc.data(), doc.id)).toList(),
    );
  }

  Future<List<DonBadge>> getBadges() async {
    final snap = await _db.collection('badges').get();
    return snap.docs.map((doc) => DonBadge.fromMap(doc.data(), doc.id)).toList();
  }
}
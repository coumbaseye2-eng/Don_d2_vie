import 'package:cloud_firestore/cloud_firestore.dart';

class Utilisateur {
  final String id;
  final String nom;
  final String email;
  final String groupeSanguin;
  final String ville;
  final String statut;
  final DateTime dateCreation;
  final String? photoUrl;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.groupeSanguin,
    required this.ville,
    required this.statut,
    required this.dateCreation,
    this.photoUrl,
  });

  factory Utilisateur.fromMap(Map<String, dynamic> map, String id) {
    return Utilisateur(
      id: id,
      nom: map['nom'],
      email: map['email'],
      groupeSanguin: map['groupeSanguin'],
      ville: map['ville'],
      statut: map['statut'],
      dateCreation: map['dateCreation'].toDate(),
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'groupeSanguin': groupeSanguin,
      'ville': ville,
      'statut': statut,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'photoUrl': photoUrl,
    };
  }
}
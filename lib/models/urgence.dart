import 'package:cloud_firestore/cloud_firestore.dart';

class Urgence {
  final String id;
  final String centreId;
  final String imageUrl;
  final String groupeSanguinRequis;
  final String niveau;
  final String statut;
  final int pochesNecessaires;
  final int pochesRecoltees;
  final DateTime dateCreation;

  Urgence({
    required this.id,
    required this.centreId,
    required this.imageUrl,
    required this.groupeSanguinRequis,
    required this.niveau,
    required this.statut,
    required this.pochesNecessaires,
    required this.pochesRecoltees,
    required this.dateCreation,
  });

  factory Urgence.fromMap(Map<String, dynamic> map, String id) {
    return Urgence(
      id: id,
      imageUrl: map['Image'] ?? map['imageUrl'] ?? '',
      centreId: map['centreId'],
      groupeSanguinRequis: map['groupeSanguinRequis'],
      niveau: map['niveau'],
      statut: map['statut'],
      pochesNecessaires: map['pochesNecessaires'],
      pochesRecoltees: map['pochesRecoltees'],
      dateCreation: map['dateCreation'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Image': imageUrl,
      'imageUrl': imageUrl,
      'centreId': centreId,
      'groupeSanguinRequis': groupeSanguinRequis,
      'niveau': niveau,
      'statut': statut,
      'pochesNecessaires': pochesNecessaires,
      'pochesRecoltees': pochesRecoltees,
      'dateCreation': Timestamp.fromDate(dateCreation),
    };
  }
}
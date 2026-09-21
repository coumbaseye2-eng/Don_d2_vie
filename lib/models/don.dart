import 'package:cloud_firestore/cloud_firestore.dart';

class Don {
  final String id;
  final String utilisateurId;
  final String centreId;
  final String? urgenceId;
  final DateTime date;
  final String statut;
  final String? messageImpact;

  Don({
    required this.id,
    required this.utilisateurId,
    required this.centreId,
    this.urgenceId,
    required this.date,
    required this.statut,
    this.messageImpact, required String imageUrl,
  });

  factory Don.fromMap(Map<String, dynamic> map, String id) {
    return Don(
      id: id,
      utilisateurId: map['utilisateurId'],
      centreId: map['centreId'],
      urgenceId: map['urgenceId'],
      date: map['date'].toDate(),
      statut: map['statut'],
      messageImpact: map['messageImpact'],
      imageUrl: 'assets/image/sang_genereuse.png',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'utilisateurId': utilisateurId,
      'centreId': centreId,
      'urgenceId': urgenceId,
      'date': Timestamp.fromDate(date),
      'statut': statut,
      'messageImpact': messageImpact,
    };
  }
}
class DonBadge {
  final String id;
  final String nom;
  final String description;
  final int seuilDons;

  DonBadge({
    required this.id,
    required this.nom,
    required this.description,
    required this.seuilDons,
  });

  factory DonBadge.fromMap(Map<String, dynamic> map, String id) {
    return DonBadge(
      id: id,
      nom: map['nom'],
      description: map['description'],
      seuilDons: map['seuilDons'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'seuilDons': seuilDons,
    };
  }
}
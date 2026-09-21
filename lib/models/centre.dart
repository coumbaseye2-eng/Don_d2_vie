class Centre {
  final String id;
  final String nom;
  final String adresse;
  final String ville;
  final String statut;
  final double latitude;
  final double longitude;
  final int tempsAttente;
  final String? imageUrl;

  Centre({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.ville,
    required this.statut,
    required this.latitude,
    required this.longitude,
    required this.tempsAttente,
    this.imageUrl,
  });

  factory Centre.fromMap(Map<String, dynamic> map, String id) {
    return Centre(
      id: id,
      nom: map['nom'],
      adresse: map['adresse'],
      ville: map['ville'],
      statut: map['statut'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      tempsAttente: map['tempsAttente'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'adresse': adresse,
      'ville': ville,
      'statut': statut,
      'latitude': latitude,
      'longitude': longitude,
      'tempsAttente': tempsAttente,
      'imageUrl': imageUrl,
    };
  }
}
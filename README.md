# Don de Vie

**Don de Vie** est une application mobile Flutter dédiée au don de sang au Sénégal. Elle connecte les donneurs aux besoins urgents des centres de santé, encourage les dons réguliers et diffuse des informations fiables sur le don de sang.

## Fonctionnalités

- **Accueil** : urgences de sang en temps réel par groupe sanguin, engagement rapide, partage sur WhatsApp, tendances des stocks.
- **Urgences** : liste des demandes de sang urgentes, filtrables par groupe sanguin.
- **Conseils & Actualités** : articles sur la préparation au don, la nutrition, les idées reçues et les témoignages de donneurs.
- **Test d'éligibilité** : questionnaire rapide en 3 questions pour savoir si vous pouvez donner aujourd'hui.
- **Profil** :
    - Photo de profil (choix depuis la galerie ou l'appareil photo, avec aperçu avant validation)
    - Historique des dons, badges et récompenses
    - Carte de donneur digitale (QR code)
    - Paramètres : thème (clair/sombre/système), notifications
    - Suppression de compte et déconnexion, avec confirmation
- **Badges & Récompenses** : suivi de la progression du donneur selon le nombre de dons effectués.

## Stack technique

| Domaine | Technologie |
|---|---|
| Framework | [Flutter](https://flutter.dev) |
| Gestion d'état | [flutter_riverpod](https://riverpod.dev) |
| Authentification | Firebase Auth |
| Base de données | Cloud Firestore |
| Stockage (photos) | Firebase Storage |
| Notifications | Firebase Messaging |
| Stockage local | Hive |

## Structure du projet

```
lib/
├── main.dart
├── models/                   # Modèles de données (Utilisateur, Don, Urgence, Centre, Badge...)
├── providers/                # Providers Riverpod (auth, données, thème, paramètres)
├── services/                 # Services (AuthService, FirestoreService)
├── screens/
│   ├── accueil/               # Écran d'accueil
│   ├── auth/                  # Connexion / inscription
│   ├── conseils/               # Conseils & actualités + test d'éligibilité
│   ├── profil/                 # Profil utilisateur + badges
│   ├── urgences/                # Liste des urgences
│   └── home_screen.dart        # Navigation principale (bottom nav bar)
└── widgets/                   # Composants réutilisables
```

## Démarrage

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (voir `environment.sdk` dans `pubspec.yaml` pour la version requise)
- Un projet [Firebase](https://console.firebase.google.com/) avec Auth, Firestore, Storage et Messaging activés
- Le fichier de configuration Firebase pour votre plateforme (`google-services.json` pour Android, `GoogleService-Info.plist` pour iOS)

### Installation

```bash
# Cloner le dépôt
git clone https://github.com/coumbaseye2-eng/Don_d2_vie.git
cd Don_d2_vie

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Configuration requise après clonage

1. Ajoutez vos fichiers de configuration Firebase (non versionnés pour des raisons de sécurité).
2. Activez Firebase Storage dans la console Firebase pour la fonctionnalité de photo de profil.
3. Au premier lancement, l'application ouvre une base de données locale Hive (`parametres`) pour stocker les préférences (thème, notifications) — aucune action manuelle requise.

## Contribuer

Les contributions sont les bienvenues. Merci d'ouvrir une issue pour discuter des changements importants avant de soumettre une pull request.

## Licence

Projet non licencié publiquement pour le moment.
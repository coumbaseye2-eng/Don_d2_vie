import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/urgence.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';

const Color kBordeaux = Color(0xFF8B1E1E);
const Color kBordeauxLight = Color(0xFFFEF2F2);
const Color kBg = Color(0xFFF5F5F5);

class UrgencesCompatiblesScreen extends ConsumerWidget {
  const UrgencesCompatiblesScreen({super.key});

  List<String> _groupesCompatibles(String groupeDonneur) {
    switch (groupeDonneur.trim().toUpperCase()) {
      case 'O-':
        return ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'];

      case 'O+':
        return ['O+', 'A+', 'B+', 'AB+'];

      case 'A-':
        return ['A-', 'A+', 'AB-', 'AB+'];

      case 'A+':
        return ['A+', 'AB+'];

      case 'B-':
        return ['B-', 'B+', 'AB-', 'AB+'];

      case 'B+':
        return ['B+', 'AB+'];

      case 'AB-':
        return ['AB-', 'AB+'];

      case 'AB+':
        return ['AB+'];

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid =
        ref.watch(authServiceProvider).utilisateurActuel?.uid ?? '';

    final profilAsync = ref.watch(profilProvider(uid));
    final urgencesAsync = ref.watch(urgencesProvider(null));

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Urgences compatibles'),
        backgroundColor: kBordeaux,
        foregroundColor: Colors.white,
      ),
      body: profilAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: kBordeaux),
        ),
        error: (e, _) => Center(
          child: Text('Erreur lors du chargement du profil : $e'),
        ),
        data: (profil) {
          if (profil == null) {
            return const Center(
              child: Text('Profil introuvable.'),
            );
          }

          final groupeDonneur = profil.groupeSanguin;
          final groupesCompatibles =
          _groupesCompatibles(groupeDonneur);

          if (groupesCompatibles.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Votre groupe sanguin n’est pas renseigné correctement '
                      'dans votre profil.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _entete(groupeDonneur),

              Expanded(
                child: urgencesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: kBordeaux,
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text('Erreur de chargement : $e'),
                  ),
                  data: (urgences) {
                    final compatibles = urgences.where((urgence) {
                      final groupeRequis =
                      urgence.groupeSanguinRequis.trim().toUpperCase();

                      return groupesCompatibles.contains(groupeRequis) &&
                          urgence.statut.toLowerCase() == 'active';
                    }).toList();

                    if (compatibles.isEmpty) {
                      return _messageVide(groupeDonneur);
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: compatibles.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _carteUrgence(compatibles[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _entete(String groupeDonneur) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kBordeaux,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                groupeDonneur,
                style: const TextStyle(
                  color: kBordeaux,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre groupe sanguin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Urgences correspondant à votre profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteUrgence(Urgence urgence) {
    final ratio = urgence.pochesNecessaires > 0
        ? (urgence.pochesRecoltees / urgence.pochesNecessaires)
        .clamp(0.0, 1.0)
        : 0.0;

    final niveau = urgence.niveau.toLowerCase();
    final couleur = niveau == 'critique'
        ? kBordeaux
        : niveau == 'eleve'
        ? Colors.deepOrange
        : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  urgence.niveau.toUpperCase(),
                  style: TextStyle(
                    color: couleur,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                urgence.groupeSanguinRequis,
                style: const TextStyle(
                  color: kBordeaux,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            urgence.centreId.replaceAll('-', ' '),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${urgence.pochesRecoltees} / '
                    '${urgence.pochesNecessaires} poches collectées',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              Text(
                '${(ratio * 100).toInt()}%',
                style: TextStyle(
                  color: couleur,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(couleur),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 15,
                color: Colors.grey,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Compatibilité à confirmer par le centre de transfusion.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _messageVide(String groupeDonneur) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: kBordeauxLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bloodtype,
                color: kBordeaux,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Aucune urgence compatible pour le moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune urgence active compatible avec le groupe '
                  '$groupeDonneur n’a été trouvée.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
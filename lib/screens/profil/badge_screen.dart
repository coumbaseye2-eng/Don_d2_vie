import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/badge_widget.dart';

const _kRouge = Color(0xFF8B1E1E);

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authServiceProvider).utilisateurActuel?.uid ?? '';
    final donsAsync = ref.watch(historiqueDonsProvider(uid));
    final badgesAsync = ref.watch(badgesProvider);
    final nbDons = donsAsync.maybeWhen(data: (d) => d.length, orElse: () => 0);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F3),
      appBar: AppBar(
        title: const Text('Badges & Récompenses'),
        backgroundColor: const Color(0xFFFAF5F3),
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: badgesAsync.when(
        data: (badges) {
          if (badges.isEmpty) {
            return Center(
              child: Text('Aucun badge disponible pour le moment.', style: TextStyle(color: Colors.grey.shade600)),
            );
          }

          final debloques = badges.where((b) => nbDons >= b.seuilDons).length;

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kRouge,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Progression', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('$debloques / ${badges.length} badges débloqués',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Icon(Icons.emoji_events_outlined, color: Colors.white, size: 30),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: badges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, i) {
                    final badge = badges[i];
                    final debloque = nbDons >= badge.seuilDons;
                    return BadgeCard(badge: badge, debloque: debloque);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
    );
  }
}
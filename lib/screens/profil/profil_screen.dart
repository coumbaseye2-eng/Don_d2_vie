import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/langue_provider.dart';
import '../../providers/parametres_notifications_provider.dart';
import '../../widgets/badge_widget.dart';
import 'badge_screen.dart';

const _kRouge = Color(0xFF8B1E1E);

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  bool _uploadPhotoEnCours = false;
  bool _suppressionEnCours = false;

  Future<void> _choisirEtChangerPhoto(String uid) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: _kRouge),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: _kRouge),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1024);
    if (xfile == null || !mounted) return;

    final fichier = File(xfile.path);

    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aperçu de la photo'),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(fichier, height: 220, width: 220, fit: BoxFit.cover),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kRouge, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    if (confirme != true || !mounted) return;

    setState(() => _uploadPhotoEnCours = true);
    try {
      final storageRef = FirebaseStorage.instance.ref('photos_profil/$uid.jpg');
      await storageRef.putFile(fichier);
      final url = await storageRef.getDownloadURL();

      await ref.read(firestoreServiceProvider).mettreAJourPhoto(uid, url);

      ref.invalidate(profilProvider(uid));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo de profil mise à jour.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la mise à jour de la photo : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadPhotoEnCours = false);
    }
  }

  Future<void> _confirmerDeconnexion() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Vous devrez vous reconnecter pour accéder à votre profil.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kRouge, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (confirme == true) {
      await ref.read(authServiceProvider).deconnexion();
    }
  }

  Future<void> _confirmerSuppressionCompte() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer votre compte ?'),
        content: const Text(
          'Cette action est définitive : votre profil, votre historique de dons '
              'et vos badges seront supprimés. Voulez-vous vraiment continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    setState(() => _suppressionEnCours = true);
    try {
      await ref.read(authServiceProvider).supprimerCompte();

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la suppression : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _suppressionEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authServiceProvider).utilisateurActuel?.uid ?? '';
    final profilAsync = ref.watch(profilProvider(uid));
    final donsAsync = ref.watch(historiqueDonsProvider(uid));
    final badgesAsync = ref.watch(badgesProvider);

    final content = profilAsync.when(
      data: (utilisateur) {
        if (utilisateur == null) {
          return const Center(child: Text('Profil introuvable'));
        }

        final nbDons = donsAsync.maybeWhen(data: (d) => d.length, orElse: () => 0);
        final viesSauvees = nbDons * 3;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20, color: _kRouge),
                  ),
                ),
                const Text('Don de Vie',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _kRouge)),
                const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _uploadPhotoEnCours ? null : () => _choisirEtChangerPhoto(uid),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: _kRouge.withValues(alpha: 0.12),
                      backgroundImage: (utilisateur.photoUrl != null && utilisateur.photoUrl!.isNotEmpty)
                          ? NetworkImage(utilisateur.photoUrl!)
                          : null,
                      child: (utilisateur.photoUrl == null || utilisateur.photoUrl!.isEmpty)
                          ? Text(
                        utilisateur.nom.isNotEmpty ? utilisateur.nom[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 28, color: _kRouge, fontWeight: FontWeight.bold),
                      )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: _kRouge,
                        child: _uploadPhotoEnCours
                            ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Changer la photo',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _kRouge, borderRadius: BorderRadius.circular(99)),
                child: Text(utilisateur.groupeSanguin,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            Text(utilisateur.nom,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text('Donneur depuis ${utilisateur.dateCreation.year}',
                style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _statCard('Dons totaux', '$nbDons', Icons.water_drop, _kRouge)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Vies sauvées', '$viesSauvees', Icons.favorite, Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kRouge,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: _kRouge.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PROCHAIN DON ÉLIGIBLE',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Bientôt disponible',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Votre corps a besoin de temps pour récupérer.', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Badges & Récompenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BadgesScreen()),
                  ),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            badgesAsync.when(
              data: (badges) {
                if (badges.isEmpty) {
                  return Text('Aucun badge pour le moment.', style: TextStyle(color: Colors.grey.shade600));
                }
                return SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: badges.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => SizedBox(
                      width: 100,
                      child: BadgeCard(badge: badges[i], debloque: nbDons >= badges[i].seuilDons),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Erreur: $e'),
            ),
            const SizedBox(height: 24),
            const Text('Carte de donneur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('DON DE VIE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('Carte Digitale', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: const Icon(Icons.qr_code_2, size: 80),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ID Donneur : ${utilisateur.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('Groupe ${utilisateur.groupeSanguin}',
                          style: const TextStyle(color: _kRouge, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('Paramètres', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _sectionCard(children: [
              _ligneTheme(),
              const Divider(height: 1),
              _ligneLangue(),
            ]),
            const SizedBox(height: 16),
            _sectionCard(children: [
              _ligneNotifications(),
              const Divider(height: 1),
              _ligneHistorique(),
            ]),

            const SizedBox(height: 28),
            const Text('Compte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _confirmerDeconnexion,
              child: const Text('Se déconnecter'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _suppressionEnCours
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
              )
                  : const Icon(Icons.delete_outline),
              label: const Text('Supprimer mon compte'),
              onPressed: _suppressionEnCours ? null : _confirmerSuppressionCompte,
            ),
            const SizedBox(height: 16),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F3),
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.96, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: content,
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Column(children: children),
    );
  }

  Widget _ligneTheme() {
    final themeActuel = ref.watch(themeModeProvider);
    String libelle(ThemeMode m) => switch (m) {
      ThemeMode.light => 'Clair',
      ThemeMode.dark => 'Sombre',
      ThemeMode.system => 'Système',
    };

    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined, color: _kRouge),
      title: const Text('Thème'),
      trailing: DropdownButton<ThemeMode>(
        value: themeActuel,
        underline: const SizedBox.shrink(),
        items: ThemeMode.values
            .map((m) => DropdownMenuItem(value: m, child: Text(libelle(m))))
            .toList(),
        onChanged: (m) {
          if (m != null) ref.read(themeModeProvider.notifier).changerTheme(m);
        },
      ),
    );
  }

  Widget _ligneLangue() {
    final langueActuelle = ref.watch(langueProvider);
    return ListTile(
      leading: const Icon(Icons.language_outlined, color: _kRouge),
      title: const Text('Langue'),
      trailing: DropdownButton<String>(
        value: langueActuelle,
        underline: const SizedBox.shrink(),
        items: languesSupportees
            .map((l) => DropdownMenuItem(value: l.code, child: Text(l.libelle)))
            .toList(),
        onChanged: (code) {
          if (code != null) ref.read(langueProvider.notifier).changerLangue(code);
        },
      ),
    );
  }

  Widget _ligneNotifications() {
    final parametres = ref.watch(parametresNotificationsProvider);
    return SwitchListTile(
      secondary: const Icon(Icons.notifications_outlined, color: _kRouge),
      title: const Text('Notifications'),
      subtitle: const Text('Rappels de dons, actualités, campagnes'),
      value: parametres.notificationsActivees,
      activeColor: _kRouge,
      onChanged: (v) => ref.read(parametresNotificationsProvider.notifier).toggleNotifications(v),
    );
  }

  Widget _ligneHistorique() {
    final parametres = ref.watch(parametresNotificationsProvider);
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.history, color: _kRouge),
          title: const Text('Conserver l\'historique'),
          subtitle: const Text('Historique des dons et échanges dans l\'app'),
          value: parametres.historiqueConserve,
          activeColor: _kRouge,
          onChanged: (v) => ref.read(parametresNotificationsProvider.notifier).toggleHistorique(v),
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
          title: const Text('Effacer l\'historique'),
          onTap: () async {
            final confirme = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Effacer l\'historique ?'),
                content: const Text('Cette action est irréversible.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _kRouge, foregroundColor: Colors.white),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Confirmer'),
                  ),
                ],
              ),
            );
            if (confirme == true) {
              await ref.read(parametresNotificationsProvider.notifier).effacerHistorique();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Historique effacé.')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _statCard(String label, String valeur, IconData icone, Color couleur) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 6))],
    ),
    child: Column(
      children: [
        Icon(icone, color: couleur),
        const SizedBox(height: 6),
        Text(valeur, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    ),
  );
}
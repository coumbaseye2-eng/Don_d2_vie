import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/don.dart';
import '../../models/urgence.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/carte_centre_widget.dart';
import '../auth/connexion_screen.dart';
import '../profil/profil_screen.dart';
import 'tendance_stocks_screen.dart';

const Color kBordeaux = Color(0xFF8B1E1E);
const Color kBordeauxDark = Color(0xFF6B1616);
const Color kBordeauxLight = Color(0xFFC5B1B1);
const Color kGreen = Color(0xFF86EFAC);
const Color kGreenDark = Color(0xFF16A34A);
const Color kGreenBg = Color(0xFFF0FDF4);
const Color kGold = Color(0xFFF59E0B);
const Color kGoldBg = Color(0xFFFFFBEB);
const Color kBg = Color(0xFFE58B8B);

class AccueilScreen extends ConsumerStatefulWidget {
  final VoidCallback? onEngager;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onStocks;

  const AccueilScreen({
    super.key,
    this.onEngager,
    this.onWhatsApp,
    this.onStocks,
  });

  @override
  ConsumerState<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends ConsumerState<AccueilScreen> {
  String _groupeSelectionne = 'Tous';
  final groupes = ['Tous', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final ScrollController _groupeScrollController = ScrollController();
  Timer? _groupeAutoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _groupeAutoScrollTimer?.cancel();
    _groupeScrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _groupeAutoScrollTimer?.cancel();
    _groupeAutoScrollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_groupeScrollController.hasClients) return;
      final max = _groupeScrollController.position.maxScrollExtent;
      final current = _groupeScrollController.offset;
      final target = current >= max ? 0.0 : current + 110.0;
      _groupeScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> _engagerDon(Urgence urgence) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final uid = ref.read(authServiceProvider).utilisateurActuel?.uid;
    if (uid == null) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ConnexionScreen()),
      );
      messenger?.showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour enregistrer ton engagement.')),
      );
      return;
    }

    final don = Don(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      utilisateurId: uid,
      centreId: urgence.centreId.isEmpty ? 'centre-principal' : urgence.centreId,
      urgenceId: urgence.id,
      date: DateTime.now(),
      statut: 'confirmé',
      messageImpact: 'Engagement enregistré pour ${urgence.groupeSanguinRequis}',
      imageUrl: 'assets/images/sang_genereuse.png',
    );

    try {
      await ref.read(firestoreServiceProvider).enregistrerDon(don);
      if (!mounted) return;
      messenger?.showSnackBar(
        const SnackBar(content: Text('Votre engagement a bien été enregistré.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger?.showSnackBar(
        SnackBar(content: Text('Impossible d’enregistrer le don : $e')),
      );
    }
  }

  Future<void> _partagerMessage() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    const message = 'Je rejoins la campagne Don de Vie pour encourager les dons de sang. Chaque poche compte !';
    final whatsappUri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');
    final webUri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');

    try {
      final launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );

      if (!mounted) return;

      if (launched) {
        messenger?.showSnackBar(
          const SnackBar(content: Text('WhatsApp ouvert avec le message prêt à partager.')),
        );
        return;
      }

      final launchedWeb = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) return;

      if (launchedWeb) {
        messenger?.showSnackBar(
          const SnackBar(content: Text('WhatsApp ouvert avec le message prêt à partager.')),
        );
      } else {
        await Clipboard.setData(const ClipboardData(text: message));
        messenger?.showSnackBar(
          const SnackBar(content: Text('WhatsApp n’est pas disponible. Le message a été copié.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      await Clipboard.setData(const ClipboardData(text: message));
      messenger?.showSnackBar(
        const SnackBar(content: Text('Le message a été copié, tu peux le partager manuellement.')),
      );
    }
  }

  Urgence _urgenceParDefaut() {
    final groupe = _groupeSelectionne == 'Tous' ? 'O-' : _groupeSelectionne;
    return Urgence(
      id: 'urgence-demo',
      centreId: 'centre-principal',
      imageUrl: 'assets/images/sang_genereuse.png',
      groupeSanguinRequis: groupe,
      niveau: 'Urgence absolue',
      statut: 'active',
      pochesNecessaires: 18,
      pochesRecoltees: 11,
      dateCreation: DateTime.now(),
    );
  }

  Widget _buildGroupeChip(String groupe) {
    final selected = _groupeSelectionne == groupe;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ChoiceChip(
        key: ValueKey(groupe),
        label: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          child: Text(groupe),
        ),
        selected: selected,
        selectedColor: const Color(0xFF8B1E1E),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? const Color(0xFF8B1E1E) : Colors.transparent),
        ),
        side: BorderSide(color: Colors.transparent),
        onSelected: (_) {
          setState(() {
            _groupeSelectionne = groupe;
          });
          _startAutoScroll();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authServiceProvider).utilisateurActuel?.uid ?? '';
    final profilAsync = ref.watch(profilProvider(uid));
    final urgencesAsync = ref.watch(
      urgencesProvider(_groupeSelectionne == 'Tous' ? null : _groupeSelectionne),
    );

    final bodyContent = AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: SafeArea(
        key: ValueKey<String>(_groupeSelectionne),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFB2A3A3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 28,
                        decoration: BoxDecoration(
                          color: kBordeauxLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(4),
                          child: Image.asset(
                            'assets/images/logo_off.jpeg',
                            fit: BoxFit.contain,
                          ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Don de Vie',
                        style: TextStyle(
                          color: kBordeaux,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 350),
                          pageBuilder: (_, animation, __) {
                            return FadeTransition(
                              opacity: animation,
                              child: const ProfilScreen(),
                            );
                          },
                        ),
                      );
                    },
                    child: profilAsync.when(
                      data: (u) => Container(
                        width: 36,
                        height: 28,
                        decoration: BoxDecoration(
                          color: kBordeaux,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: kBordeaux.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (u?.nom.isNotEmpty ?? false) ? u!.nom[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      loading: () => const CircleAvatar(radius: 28, backgroundColor: Colors.grey),
                      error: (_, __) => const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 130,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1569103470612-0414542f9355?w=480&h=150&fit=crop&auto=format',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xCC7A1F1F),
                              Color(0xBB8B1E1E),
                              Color(0x668B1E1E),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SAGESSE WOLOF',
                              style: TextStyle(
                                color: Color(0xFFFCA5A5),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '"Nit, nit ay garabam"',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "(L'homme est le remède de l'homme)",
                              style: TextStyle(
                                color: Color(0xFFFCA5A5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Groupes Sanguins',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9E2E2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        final slideAnimation = Tween<Offset>(
                          begin: const Offset(0.12, 0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);

                        return SlideTransition(
                          position: slideAnimation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: ListView(
                        key: ValueKey<String>(_groupeSelectionne),
                        controller: _groupeScrollController,
                        scrollDirection: Axis.horizontal,
                        children: groupes.map(_buildGroupeChip).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: urgencesAsync.when(
                data: (urgences) {
                  final urgence = urgences.isEmpty ? _urgenceParDefaut() : urgences.first;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: kBordeaux.withValues(alpha: 0.10),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: kBordeaux,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    _PulseDot(),
                                    SizedBox(width: 6),
                                    Text(
                                      'URGENCE ABSOLUE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: kBordeauxLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kBordeaux, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    urgence.groupeSanguinRequis,
                                    style: const TextStyle(
                                      color: kBordeaux,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sang ${urgence.groupeSanguinRequis}',
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Icon(Icons.location_on, size: 13, color: Color(0xFF9CA3AF)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Hôpital Fann (Dakar) · à 4.1 km',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${urgence.pochesRecoltees} poches récoltées',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Objectif : ${urgence.pochesNecessaires}',
                                    style: const TextStyle(
                                      color: Color(0xFF374151),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: LinearProgressIndicator(
                                  value: urgence.pochesRecoltees /
                                      (urgence.pochesNecessaires == 0 ? 1 : urgence.pochesNecessaires),
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFFFE0E0),
                                  valueColor: const AlwaysStoppedAnimation<Color>(kBordeaux),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: DecoratedBox(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [kBordeaux, kBordeauxDark],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(16)),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _engagerDon(urgence);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      '🤲 Je m\'engage à donner aujourd\'hui',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await _partagerMessage();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: kGreenBg,
                                    side: const BorderSide(color: kGreen, width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Text('💬', style: TextStyle(fontSize: 15)),
                                  label: const Text(
                                    'Relayer sur WhatsApp',
                                    style: TextStyle(
                                      color: kGreenDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Erreur: $e'),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 350),
                      pageBuilder: (_, animation, __) => FadeTransition(
                        opacity: animation,
                        child: const TendanceStocksScreen(),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: kGoldBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kGold,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('📊', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tendances des stocks',
                                style: TextStyle(
                                  color: kGold,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Évolution future',
                                style: TextStyle(
                                  color: Color(0xFFB45309),
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'Voir →',
                          style: TextStyle(
                            color: kGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Centres à proximité',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  profilAsync.when(
                    data: (u) {
                      final centresAsync = ref.watch(centresProvider(u?.ville));
                      return centresAsync.when(
                        data: (centres) {
                          if (centres.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Aucun centre trouvé.',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            );
                          }
                          return Column(
                            children: centres.map((c) => CarteCentre(centre: c)).toList(),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('Erreur: $e'),
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Impossible de charger les centres.'),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE7E4E2),
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.96, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: bodyContent,
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

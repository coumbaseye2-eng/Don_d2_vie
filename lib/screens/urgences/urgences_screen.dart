import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'urgences_compatibles_screen.dart';
import '../../models/don.dart';
import '../../models/urgence.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../auth/connexion_screen.dart';
import '../profil/profil_screen.dart';


const Color kBordeaux = Color(0xFF8B1E1E);
const Color kBordeauxDark = Color(0xFF6B1616);
const Color kBordeauxLight = Color(0xFFFEF2F2);
const Color kTeal = Color(0xFF004D40);
const Color kGreenDark = Color(0xFF16A34A);
const Color kBg = Color(0xFFF5F5F5);

const List<String> kFiltresGroupes = [
  'Tous les groupes',
  'O-',
  'A-',
  'B+',
  'AB+',
];

List<Urgence> _urgencesDemo() {
  final now = DateTime.now();
  return [
    Urgence(
      id: 'urgence-demo-1',
      centreId: 'Hôpital Principal de Dakar',
    imageUrl: 'assets/images/sang_genereuse.png',
      groupeSanguinRequis: 'O-',
      niveau: 'critique',
      statut: 'active',
      pochesNecessaires: 3,
      pochesRecoltees: 1,
      dateCreation: now.subtract(const Duration(minutes: 10)),
    ),
    Urgence(
      id: 'urgence-demo-2',
      centreId: 'Hôpital de Fann',
      imageUrl: 'assets/images/sang_genereuse.png',
      groupeSanguinRequis: 'A-',
      niveau: 'eleve',
      statut: 'active',
      pochesNecessaires: 4,
      pochesRecoltees: 2,
      dateCreation: now.subtract(const Duration(minutes: 40)),
    ),
    Urgence(
      id: 'urgence-demo-3',
      centreId: 'Hôpital Aristide Le Dantec',
      imageUrl: 'assets/images/sang_genereuse.png',
      groupeSanguinRequis: 'B+',
      niveau: 'renouvellement',
      statut: 'active',
      pochesNecessaires: 2,
      pochesRecoltees: 1,
      dateCreation: now.subtract(const Duration(hours: 2)),
    ),
  ];
}

class UrgencesScreen extends ConsumerStatefulWidget {
  const UrgencesScreen({super.key});

  @override
  ConsumerState<UrgencesScreen> createState() => _UrgencesScreenState();
}

class _UrgencesScreenState extends ConsumerState<UrgencesScreen>
    with TickerProviderStateMixin {
  String _groupeSelectionne = 'Tous les groupes';

  late final AnimationController _pageController;
  late final AnimationController _headerController;
  late final AnimationController _matchingController;
  final PageController _urgencePageController = PageController(viewportFraction: 0.91);
  final PageController _bandeauController = PageController();
  int _currentUrgenceIndex = 0;
  int _currentBandeauIndex = 0;
  Timer? _bandeauTimer;

  late final Animation<Offset> _pageSlide;
  late final Animation<double> _pageFade;

  late final Animation<Offset> _headerSlide;
  late final Animation<double> _headerFade;

  late final Animation<Offset> _matchingSlide;
  late final Animation<double> _matchingFade;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _pageSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: Curves.easeOutCubic,
      ),
    );
    _pageFade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOutCubic,
      ),
    );

    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    _matchingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _matchingSlide = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _matchingController,
        curve: Curves.easeOutCubic,
      ),
    );

    _matchingFade = CurvedAnimation(
      parent: _matchingController,
      curve: Curves.easeOut,
    );

    _headerController.forward();

    Future.delayed(
      const Duration(milliseconds: 120),
          () {
        if (mounted) {
          _pageController.forward();
        }
      },
    );

    Future.delayed(
      const Duration(milliseconds: 350),
          () {
        if (mounted) {
          _matchingController.forward();
        }
      },
    );

    _bandeauTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _bandeauController.positions.isEmpty) return;
      final nextIndex = (_currentBandeauIndex + 1) % 3;
      _bandeauController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
      _currentBandeauIndex = nextIndex;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerController.dispose();
    _matchingController.dispose();
    _urgencePageController.dispose();
    _bandeauController.dispose();
    _bandeauTimer?.cancel();
    super.dispose();
  }

  Color _couleurNiveau(String niveau) {
    switch (niveau) {
      case 'critique':
        return kBordeaux;

      case 'eleve':
        return kTeal;

      default:
        return kGreenDark;
    }
  }

  String _libelleNiveau(String niveau) {
    switch (niveau) {
      case 'critique':
        return 'URGENCE CRITIQUE';

      case 'eleve':
        return 'BESOIN ÉLEVÉ';

      default:
        return 'RENOUVELLEMENT';
    }
  }

  String _texteBouton(String niveau) {
    switch (niveau) {
      case 'critique':
        return 'Je donne pour cette urgence';

      case 'eleve':
        return 'Planifier un don';

      default:
        return 'Voir les détails';
    }
  }

  String _tempsEcoule(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    }

    if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    }

    return 'Il y a ${diff.inDays}j';
  }

  Future<void> _enregistrerDon(Urgence urgence) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    final uid = ref.read(authServiceProvider).utilisateurActuel?.uid;

    if (uid == null) {
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ConnexionScreen(),
        ),
      );

      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'Connecte-toi pour enregistrer ton engagement.',
          ),
        ),
      );

      return;
    }

    final don = Don(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      utilisateurId: uid,
      centreId: urgence.centreId.isEmpty
          ? 'centre-principal'
          : urgence.centreId,
      urgenceId: urgence.id,
      imageUrl: urgence.imageUrl,
      date: DateTime.now(),
      statut: 'confirmé',
      messageImpact:
      'Don enregistré pour ${urgence.groupeSanguinRequis}',
    );

    try {
      await ref.read(firestoreServiceProvider).enregistrerDon(don);

      if (!mounted) return;

      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'Merci, votre disponibilité a bien été enregistrée.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            "Impossible d'enregistrer le don : $e",
          ),
        ),
      );
    }
  }

  void _voirDetails(Urgence urgence) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          'Détails du besoin ${urgence.groupeSanguinRequis} consultés.',
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final uid =
        ref.watch(authServiceProvider).utilisateurActuel?.uid ?? '';

    final profilAsync = ref.watch(
      profilProvider(uid),
    );

    final urgencesAsync = ref.watch(
      urgencesProvider(
        _groupeSelectionne == 'Tous les groupes'
            ? null
            : _groupeSelectionne,
      ),
    );

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: _AppHeader(
                profilAsync: profilAsync,
              ),
            ),
          ),

          Expanded(
            child: SlideTransition(
              position: _pageSlide,
              child: FadeTransition(
                opacity: _pageFade,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    bottom: 24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      _bandeauTitre(urgencesAsync.value ?? const []),
                      const SizedBox(height: 16),
                      const Text(
                        'Filtres',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _filtres(),
                      SlideTransition(
                        position: _matchingSlide,
                        child: FadeTransition(
                          opacity: _matchingFade,
                          child: _teaserMatching(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      urgencesAsync.when(
                        data: (urgences) {
                          final items = urgences.isEmpty
                              ? _urgencesDemo()
                              : urgences;
                          final filteredItems = _groupeSelectionne == 'Tous les groupes'
                              ? items
                              : items.where((u) => u.groupeSanguinRequis == _groupeSelectionne).toList();

                          if (_currentUrgenceIndex >= filteredItems.length) {
                            _currentUrgenceIndex = 0;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _urgencePageController.jumpToPage(0);
                              }
                            });
                          }

                          if (filteredItems.isEmpty) {
                            return _messageVide();
                          }
                          return _carouselUrgences(filteredItems);
                        },

                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 40,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: kBordeaux,
                            ),
                          ),
                        ),

                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Erreur : $e',
                              style: const TextStyle(
                                color: kBordeaux,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _messageFin(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _bandeauTitre(List<Urgence> urgences) {
    final premiereImage = urgences.isNotEmpty && urgences.first.imageUrl.isNotEmpty
        ? urgences.first.imageUrl
        : 'assets/images/urgence_banner_dakar.png';

    final images = [
      premiereImage,
      'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1538108149393-fbbd81895907?auto=format&fit=crop&w=1200&q=80',
    ];

    return AutoMotionBox(
      duration: const Duration(milliseconds: 2200),
      offset: const Offset(0, 8),
      scaleRange: 0.04,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            height: 138,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: kBordeaux.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: PageView.builder(
                controller: _bandeauController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentBandeauIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final image = images[index];
                  final isAsset = image.startsWith('assets/');

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      isAsset
                          ? Image.asset(image, fit: BoxFit.cover)
                          : Image.network(image, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              kBordeaux.withValues(alpha: 0.82),
                              kBordeauxDark.withValues(alpha: 0.72),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        bottom: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Urgences vitales',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Hôpitaux de Dakar et environs',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  final active = index == _currentBandeauIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? kBordeaux : Colors.white,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: kBordeaux.withValues(alpha: 0.5)),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filtres() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        0,
        0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          right: 16,
        ),
        child: Row(
          children: kFiltresGroupes.asMap().entries.map(
                (entry) {
              final index = entry.key;
              final f = entry.value;
              final actif = f == _groupeSelectionne;

              return TweenAnimationBuilder<double>(
                key: ValueKey(
                  'filtre-$f-$_groupeSelectionne',
                ),
                tween: Tween(
                  begin: 0,
                  end: 1,
                ),
                duration: Duration(
                  milliseconds: 300 + (index * 70),
                ),
                curve: Curves.easeOutCubic,
                builder: (
                    context,
                    value,
                    child,
                    ) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(
                        18 * (1 - value),
                        0,
                      ),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (_groupeSelectionne == f) {
                        return;
                      }

                      setState(() {
                        _groupeSelectionne = f;
                      });
                    },
                    child: AnimatedScale(
                      scale: actif ? 1.04 : 1,
                      duration: const Duration(
                        milliseconds: 180,
                      ),
                      curve: Curves.easeOutBack,
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 220,
                        ),
                        curve: Curves.easeOutCubic,
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: actif
                              ? kBordeaux
                              : Colors.white,
                          borderRadius:
                          BorderRadius.circular(50),
                          border: Border.all(
                            color: actif
                                ? kBordeaux
                                : const Color(
                              0xFFE0E0E0,
                            ),
                            width: 1.5,
                          ),
                          boxShadow: actif
                              ? [
                            BoxShadow(
                              color:
                              kBordeaux.withValues(
                                alpha: 0.18,
                              ),
                              blurRadius: 8,
                              offset:
                              const Offset(
                                0,
                                3,
                              ),
                            ),
                          ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            if (f ==
                                'Tous les groupes') ...[
                              Icon(
                                Icons.tune,
                                size: 13,
                                color: actif
                                    ? Colors.white
                                    : const Color(
                                  0xFF555555,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                            ],
                            Text(
                              f,
                              style: TextStyle(
                                color: actif
                                    ? Colors.white
                                    : const Color(
                                  0xFF555555,
                                ),
                                fontWeight:
                                FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget _teaserMatching() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const UrgencesCompatiblesScreen(),
            ),
          );
        },
        child: AutoMotionBox(
          duration: const Duration(milliseconds: 1700),
          offset: const Offset(6, 0),
          scaleRange: 0.05,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius:
              BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFBFDBFE),
              ),
            ),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0.7,
                    end: 1,
                  ),
                  duration: const Duration(
                    milliseconds: 900,
                  ),
                  curve: Curves.easeOutBack,
                  builder: (
                      context,
                      scale,
                      child,
                      ) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.bolt,
                    color: Colors.blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Trouver les urgences compatibles avec votre sang',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E40AF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF1E40AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _carouselUrgences(
      List<Urgence> urgences,
      ) {
    return Column(
      children: [
        SizedBox(
          height: 365,
          child: PageView.builder(
            controller: _urgencePageController,
            physics: const BouncingScrollPhysics(),
            itemCount: urgences.length,
            onPageChanged: (index) {
              setState(() {
                _currentUrgenceIndex = index;
              });
            },
            itemBuilder: (
                context,
                index,
                ) {
              final urgence = urgences[index];

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16 : 4,
                  right: index == urgences.length - 1
                      ? 16
                      : 4,
                ),
                child: _carteUrgenceAnimee(
                  urgence,
                  index,
                ),
              );
            },
          ),
        ),

        if (urgences.length > 1)
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: List.generate(
                urgences.length,
                    (index) {
                  final isActive = index == _currentUrgenceIndex;
                  return AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 250,
                    ),
                    margin:
                    const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    width: isActive ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? kBordeaux
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _carteUrgenceAnimee(
      Urgence urgence,
      int index,
      ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration: Duration(
        milliseconds: 500 + (index * 100),
      ),
      curve: Curves.easeOutCubic,
      builder: (
          context,
          value,
          child,
          ) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              30 * (1 - value),
              18 * (1 - value),
            ),
            child: Transform.scale(
              scale: 0.96 + (0.04 * value),
              child: child,
            ),
          ),
        );
      },
      child: _carteUrgence(urgence),
    );
  }

  Widget _carteUrgence(
      Urgence urgence,
      ) {
    final couleur = _couleurNiveau(
      urgence.niveau,
    );

    final double ratio = urgence.pochesNecessaires > 0
        ? (urgence.pochesRecoltees /
        urgence.pochesNecessaires)
        .clamp(0.0, 1.0)
        : 0.0;

    return AutoMotionBox(
      duration: Duration(
        milliseconds: 1800 + (urgence.pochesNecessaires * 180),
      ),
      offset: const Offset(0, 14),
      scaleRange: 0.03,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.06,
              ),
              blurRadius: 14,
              offset: const Offset(
                0,
                6,
              ),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 300,
                ),
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: couleur.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius:
                  BorderRadius.circular(6),
                ),
                child: Text(
                  _libelleNiveau(
                    urgence.niveau,
                  ),
                  style: TextStyle(
                    color: couleur,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              Text(
                _tempsEcoule(
                  urgence.dateCreation,
                ),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0.7,
                  end: 1,
                ),
                duration: const Duration(
                  milliseconds: 600,
                ),
                curve: Curves.easeOutBack,
                builder: (
                    context,
                    scale,
                    child,
                    ) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration:
                  const BoxDecoration(
                    color: kBordeauxLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      urgence.groupeSanguinRequis,
                      style:
                      const TextStyle(
                        color: kBordeaux,
                        fontWeight:
                        FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      urgence.centreId
                          .replaceAll(
                        '-',
                        ' ',
                      )
                          .toUpperCase(),
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color:
                          Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Région de Dakar',
                          style:
                          TextStyle(
                            color:
                            Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collecte : '
                    '${urgence.pochesRecoltees} / '
                    '${urgence.pochesNecessaires} poches',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Colors.black54,
                ),
              ),
              Text(
                '${(ratio * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.bold,
                  color: couleur,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: ratio,
            ),
            duration: const Duration(
              milliseconds: 1100,
            ),
            curve: Curves.easeOutCubic,
            builder: (
                context,
                value,
                child,
                ) {
              return ClipRRect(
                borderRadius:
                BorderRadius.circular(4),
                child:
                LinearProgressIndicator(
                  value: value,
                  backgroundColor:
                  Colors.grey.shade100,
                  valueColor:
                  AlwaysStoppedAnimation<
                      Color>(
                    couleur,
                  ),
                  minHeight: 7,
                ),
              );
            },
          ),

          const Spacer(),

          const SizedBox(height: 14),
          _AnimatedActionButton(
            couleur: couleur,
            texte: _texteBouton(
              urgence.niveau,
            ),
            onPressed: () {
              if (urgence.niveau ==
                  'critique' ||
                  urgence.niveau ==
                      'eleve') {
                _enregistrerDon(
                  urgence,
                );
              } else {
                _voirDetails(
                  urgence,
                );
              }
            }, image: 'assets/images/sang_genereuse.png',
          ),
        ],
        ),
      ),
    );
  }

  Widget _messageVide() {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration: const Duration(
        milliseconds: 500,
      ),
      curve: Curves.easeOut,
      builder: (
          context,
          value,
          child,
          ) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              15 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 24,
        ),
        child: Center(
          child: Text(
            'Aucune urgence signalée pour ce groupe sanguin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
  Widget _messageFin() {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration: const Duration(
        milliseconds: 900,
      ),
      curve: Curves.easeOut,
      builder: (
          context,
          value,
          child,
          ) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              12 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 24,
        ),
        child: Center(
          child: Text(
            'Chaque don compte. Merci pour votre engagement 😊.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}

class AutoMotionBox extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;
  final double scaleRange;

  const AutoMotionBox({
    super.key,
    required this.child,
    required this.duration,
    required this.offset,
    this.scaleRange = 0.04,
  });

  @override
  State<AutoMotionBox> createState() => _AutoMotionBoxState();
}

class _AutoMotionBoxState extends State<AutoMotionBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = _controller.value * 2 * math.pi;
    final offsetX = math.sin(phase) * widget.offset.dx;
    final offsetY = math.cos(phase) * widget.offset.dy;
    final scale = 1 + (math.sin(phase + 1.2) * widget.scaleRange);

    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Transform.scale(
        scale: scale,
        child: widget.child,
      ),
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final Color couleur;
  final String texte;
  final String image;
  final VoidCallback onPressed;

  const _AnimatedActionButton({
    required this.couleur,
    required this.texte,
    required this.image,
    required this.onPressed,
  });

  @override
  State<_AnimatedActionButton> createState() =>
      _AnimatedActionButtonState();
}

class _AnimatedActionButtonState
    extends State<_AnimatedActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });

        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(
          milliseconds: 100,
        ),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          width: double.infinity,
          height: 42,
          decoration: BoxDecoration(
            color: widget.couleur,
            borderRadius:
            BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.couleur.withValues(
                  alpha: _pressed ? 0.05 : 0.18,
                ),
                blurRadius:
                _pressed ? 4 : 8,
                offset: Offset(
                  0,
                  _pressed ? 2 : 4,
                ),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.texte,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight:
                FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  final AsyncValue profilAsync;

  const _AppHeader({
    required this.profilAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top:
        MediaQuery.of(context).padding.top +
            8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD0C2C2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0,
                  end: 1,
                ),
                duration: const Duration(
                  milliseconds: 700,
                ),
                curve: Curves.easeOutBack,
                builder: (
                    context,
                    scale,
                    child,
                    ) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration:
                  BoxDecoration(
                    color: kBordeauxLight,
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '🩸',
                      style:
                      TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              const Text(
                'Don de Vie',
                style: TextStyle(
                  color: kBordeaux,
                  fontWeight:
                  FontWeight.w900,
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
                  transitionDuration:
                  const Duration(
                    milliseconds: 350,
                  ),
                  pageBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      ) {
                    return FadeTransition(
                      opacity: animation,
                      child:
                      const ProfilScreen(),
                    );
                  },
                ),
              );
            },
            child: profilAsync.when(
              data: (u) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0.6,
                    end: 1,
                  ),
                  duration:
                  const Duration(
                    milliseconds: 700,
                  ),
                  curve:
                  Curves.easeOutBack,
                  builder: (
                      context,
                      scale,
                      child,
                      ) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration:
                    BoxDecoration(
                      color: kBordeaux,
                      borderRadius:
                      BorderRadius
                          .circular(
                        12,
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                          kBordeaux
                              .withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 10,
                          offset:
                          const Offset(
                            0,
                            4,
                          ),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        color:
                        Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                );
              },
              error: (_, __) {
                return const Icon(
                  Icons.error,
                  color: kBordeaux,
                );
              },
              loading: () {
                return const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kBordeaux,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
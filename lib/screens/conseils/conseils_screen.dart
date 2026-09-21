import 'dart:async';
import 'package:flutter/material.dart';
import 'test_don_screen.dart';

class Article {
  final String titre;
  final String image;
  final String categorie;
  final String? extrait;
  final String? contenu;
  final bool vedette;
  const Article({
    required this.titre,
    required this.image,
    required this.categorie,
    this.extrait,
    this.contenu,
    this.vedette = false});
}

Widget buildArticleImage(String image) {
  if (image.startsWith('assets/')) {
    return Image.asset(image, fit: BoxFit.cover);
  }
  return Image.network(
    image,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    },
    errorBuilder: (context, _, __) => Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    ),
  );
}

class ConseilsScreen extends StatefulWidget {
  const ConseilsScreen({super.key});
  @override
  State<ConseilsScreen> createState() => _ConseilsScreenState();
}

class _ConseilsScreenState extends State<ConseilsScreen> {
  String _filtre = 'Tout voir';
  final filtres = ['Tout voir', 'Santé', 'Mythes', 'Témoignage'];
  final PageController _featuredController = PageController(viewportFraction: 0.92);
  int _currentFeaturedIndex = 0;
  Timer? _featuredTimer;

  final articles = const [
    Article(
      titre: 'Que faire avant et après un don de sang ?',
      categorie: 'Santé',
      extrait: 'Préparez-vous de manière optimale pour que votre don se passe dans les meilleures conditions...',
      contenu: 'Avant votre don : dormez suffisamment la veille, mangez normalement (évitez le jeûne) et buvez beaucoup d\'eau dans les heures qui précèdent. Évitez les repas trop gras juste avant le prélèvement.\n\n'
          'Après votre don : restez assis quelques minutes sous surveillance, hydratez-vous et prenez la collation proposée sur place. Évitez les efforts physiques intenses et l\'alcool pendant le reste de la journée. Si vous ressentez un malaise, allongez-vous et surélevez les jambes.',
      vedette: true,
      image: 'assets/images/urgence_banner_dakar.png',
    ),
    Article(
      titre: 'Les 5 idées reçues sur le don',
      categorie: 'Mythes',
      contenu: '1. « Donner son sang affaiblit durablement » : faux, l\'organisme reconstitue le volume prélevé en quelques jours.\n\n'
          '2. « Il faut être à jeun » : faux, il est au contraire recommandé de manger avant.\n\n'
          '3. « On peut attraper une maladie en donnant » : faux, le matériel utilisé est à usage unique et stérile.\n\n'
          '4. « Les personnes âgées ne peuvent pas donner » : faux dans la plupart des cas, sous réserve d\'être en bonne santé.\n\n'
          '5. « Un seul don ne sert à rien » : faux, chaque poche de sang peut sauver jusqu\'à trois vies.',
      image: 'assets/images/sang_genereuse.png',
    ),
    Article(
      titre: 'Campagne nationale : rejoignez-nous',
      categorie: 'Événement',
      contenu: 'Une nouvelle campagne nationale de collecte se déploie dans plusieurs régions du Sénégal ce mois-ci, en partenariat avec les centres de transfusion sanguine locaux.\n\n'
          'Des points de collecte mobiles seront installés dans les principales villes. Consultez le calendrier dans l\'application pour trouver le site le plus proche de chez vous et prendre rendez-vous.',
      image: 'assets/images/img_1.jpg',
    ),
    Article(
      titre: "Mon premier don m'a changé",
      categorie: 'Témoignage',
      contenu: '« J\'avais toujours repoussé le moment de donner mon sang, par appréhension de l\'aiguille. Le jour où je me suis enfin lancé, tout s\'est passé bien plus simplement que je ne l\'imaginais.\n\n'
          'L\'équipe soignante a été rassurante du début à la fin, et savoir que mon don pouvait sauver jusqu\'à trois personnes m\'a donné envie de devenir donneur régulier. »',
      image: 'assets/images/img_3.jpg',
    ),
    Article(
      titre: 'Nutrition avant et après le don',
      categorie: 'Santé',
      contenu: 'Avant le don, privilégiez des aliments riches en fer (viande rouge, légumineuses, légumes verts) dans les jours précédents, ainsi qu\'un repas complet quelques heures avant le prélèvement.\n\n'
          'Après le don, continuez à bien vous hydrater et à manger équilibré pendant 24 à 48 heures pour aider votre corps à se régénérer plus rapidement.',
      image: 'assets/images/img_2.jpg',
    ),
    Article(
      titre: 'Pourquoi les banques de sang ont besoin de vous ?',
      categorie: 'Santé',
      contenu: 'Les besoins en sang sont constants : accidents, interventions chirurgicales, accouchements difficiles, maladies chroniques comme la drépanocytose... Le sang ne se fabrique pas en laboratoire, seul le don humain permet d\'y répondre.\n\n'
          'Au Sénégal comme ailleurs, les stocks sont souvent insuffisants, en particulier durant certaines périodes de l\'année. Chaque donneur régulier compte.',
      image: 'assets/images/img_4.jpg',
    ),
    Article(
      titre: 'Les mythes sur les groupes sanguins',
      categorie: 'Mythes',
      contenu: 'Contrairement à une idée reçue, il n\'existe pas de « meilleur » groupe sanguin : tous sont nécessaires. Le groupe O négatif est toutefois particulièrement recherché car il peut être transfusé à presque tout le monde en urgence.\n\n'
          'Votre groupe sanguin n\'a par ailleurs aucun lien avec votre caractère ou votre personnalité, malgré certaines croyances populaires.',
      image: 'assets/images/img_5.jpg',
    ),
    Article(
      titre: 'Témoignage : donner, c’est aussi se mobiliser',
      categorie: 'Témoignage',
      contenu: '« Au-delà du geste individuel, j\'ai découvert une vraie communauté de donneurs engagés. On s\'encourage mutuellement, on se rappelle les dates de collecte, on en parle autour de nous.\n\n'
          'Donner son sang, c\'est aussi une façon de se mobiliser pour sa communauté, discrètement mais concrètement. »',
      image: 'assets/images/img_6.jpg',
    ),
    Article(
      titre: 'Nos prochains rendez-vous de collecte',
      categorie: 'Événement',
      contenu: 'Retrouvez le calendrier des prochaines collectes près de chez vous : dates, lieux et horaires sont mis à jour régulièrement.\n\n'
          'Pensez à prendre rendez-vous à l\'avance lorsque c\'est possible, cela permet aux équipes de mieux organiser l\'accueil des donneurs.',
      image: 'assets/images/img_7.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _featuredTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_featuredController.hasClients) return;
      final next = (_currentFeaturedIndex + 1) % articles.length;
      _featuredController.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
      _currentFeaturedIndex = next;
    });
  }

  @override
  void dispose() {
    _featuredTimer?.cancel();
    _featuredController.dispose();
    super.dispose();
  }

  Color _couleurCategorie(String cat) {
    switch (cat) {
      case 'Mythes':
        return Colors.orange;
      case 'Événement':
        return Colors.blue;
      case 'Témoignage':
        return Colors.purple;
      default:
        return const Color(0xFF8B1E1E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vedette = articles.firstWhere((a) => a.vedette, orElse: () => articles.first);
    final liste = _filtre == 'Tout voir'
        ? articles.where((a) => a != vedette).toList()
        : articles.where((a) => a.categorie == _filtre && a != vedette).toList();

    final bodyContent = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF8B1E1E),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TEST RAPIDE',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("Puis-je donner aujourd'hui ?",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Vérifiez votre éligibilité en 3 questions simples.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, foregroundColor: const Color(0xFF8B1E1E)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TestDonScreen(),
                      ),
                    );
                  },
                  child: const Text('Faire le test →'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
              final offset = Tween<Offset>(
                begin: const Offset(0.12, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);

              return SlideTransition(
                position: offset,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: ListView(
              key: ValueKey<String>(_filtre),
              scrollDirection: Axis.horizontal,
              children: filtres
                  .map((f) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TextStyle(
                      color: _filtre == f ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text(f),
                  ),
                  selected: _filtre == f,
                  selectedColor: const Color(0xFF8B1E1E),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: _filtre == f ? const Color(0xFF8B1E1E) : Colors.transparent),
                  ),
                  side: const BorderSide(color: Colors.transparent),
                  onSelected: (_) => setState(() => _filtre = f),
                ),
              ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_filtre == 'Tout voir') ...[
          SizedBox(
            height: 188,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _featuredController,
                    itemCount: articles.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentFeaturedIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArticleDetailScreen(article: article),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      buildArticleImage(article.image),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withValues(alpha: 0.35),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          color: Colors.red,
                                          child: const Text('NOUVEAU', style: TextStyle(color: Colors.white, fontSize: 10)),
                                        ),
                                      ),
                                      Positioned(
                                        left: 12,
                                        right: 12,
                                        bottom: 12,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              article.categorie,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              article.titre,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    article.extrait ?? '',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(articles.length, (index) {
                    final active = index == _currentFeaturedIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF8B1E1E) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: liste.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, i) {
            final a = liste[i];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.88, end: 1),
              duration: Duration(milliseconds: 260 + i * 70),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value, child: child!),
                );
              },
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(article: a),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 80,
                        width: double.infinity,
                        child: buildArticleImage(a.image),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.categorie,
                                style: TextStyle(color: _couleurCategorie(a.categorie), fontWeight: FontWeight.bold, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(a.titre, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
          title: const Text('Conseils & Actualités')
      ),
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
        child: bodyContent,
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final texte = article.contenu?.trim().isNotEmpty == true
        ? article.contenu!
        : (article.extrait?.trim().isNotEmpty == true
        ? article.extrait!
        : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(article.titre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: buildArticleImage(article.image),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              article.categorie,
              style: const TextStyle(
                color: Color(0xFF8B1E1E),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              article.titre,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            if (texte != null)
              Text(
                texte,
                style: const TextStyle(fontSize: 16, height: 1.5),
              )
            else
              Text(
                'Contenu à venir pour cet article.',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
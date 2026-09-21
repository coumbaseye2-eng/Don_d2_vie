import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../models/utilisateur.dart';
import '../home_screen.dart';

class CreationProfilScreen extends ConsumerStatefulWidget {
  const CreationProfilScreen({super.key});
  @override
  ConsumerState<CreationProfilScreen> createState() => _CreationProfilScreenState();
}

class _CreationProfilScreenState extends ConsumerState<CreationProfilScreen> {
  final PageController _pageController = PageController();
  int _etape = 0;
  bool _chargement = false;
  final _nomController = TextEditingController();
  String? _groupeSanguin;
  String? _ville;

  final groupes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final villes = ['Dakar', 'Thiès', 'Saint-Louis', 'Ziguinchor', 'Touba', 'Kaolack', 'Mbour', 'Rufisque'];

  bool get _peutContinuer {
    if (_etape == 0) return _nomController.text.trim().isNotEmpty;
    if (_etape == 1) return _groupeSanguin != null;
    return _ville != null;
  }

  void _precedent() {
    if (_etape > 0) {
      setState(() => _etape--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _suivant() async {
    if (_etape < 2) {
      setState(() => _etape++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }
    setState(() => _chargement = true);
    final auth = ref.read(authServiceProvider);
    final uid = auth.utilisateurActuel!.uid;
    final utilisateur = Utilisateur(
      id: uid,
      nom: _nomController.text.trim(),
      email: auth.utilisateurActuel!.email ?? '',
      groupeSanguin: _groupeSanguin!,
      ville: _ville!,
      statut: 'actif',
      dateCreation: DateTime.now(),
    );
    await ref.read(firestoreServiceProvider).creerProfil(utilisateur);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF8B1E1E),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Créer mon profil',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Étape ${_etape + 1} sur 3', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _etape ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_etapeNom(), _etapeGroupeSanguin(), _etapeVille()],
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_etape > 0)
                  IconButton(
                    onPressed: _precedent,
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      shape: const CircleBorder(),
                    ),
                  ),
                if (_etape > 0) const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1E1E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: (_peutContinuer && !_chargement) ? _suivant : null,
                      child: _chargement
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        _etape == 2 ? '🩸 Rejoindre la communauté' : 'Continuer →',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
  }

  Widget _etapeNom() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comment vous appelez-vous ?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('Votre prénom et nom de famille', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 20),
        TextField(
          controller: _nomController,
          decoration: InputDecoration(
            hintText: 'Ex : Coumba Seye',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text('Ce nom apparaîtra sur votre carte de donneur.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ],
    ),
  );

  Widget _etapeGroupeSanguin() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Votre groupe sanguin ?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('Cette info est essentielle pour le matching', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: groupes.map((g) {
            final selectionne = _groupeSanguin == g;
            return GestureDetector(
              onTap: () => setState(() => _groupeSanguin = g),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectionne ? const Color(0xFF8B1E1E) : Colors.white,
                  border: Border.all(color: selectionne ? const Color(0xFF8B1E1E) : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(g,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selectionne ? Colors.white : Colors.black87,
                    )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF8B1E1E), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vérifiez sur une carte de groupe sanguin ou demandez à votre médecin si vous ne savez pas.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _etapeVille() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Votre ville ?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('Pour trouver les urgences près de vous', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: villes.length,
            itemBuilder: (context, index) {
              final v = villes[index];
              final selectionne = _ville == v;
              return GestureDetector(
                onTap: () => setState(() => _ville = v),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: selectionne ? const Color(0xFFFFF0F0) : Colors.white,
                    border: Border.all(color: selectionne ? const Color(0xFF8B1E1E) : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(v,
                          style: TextStyle(
                            color: selectionne ? const Color(0xFF8B1E1E) : Colors.black87,
                            fontWeight: FontWeight.w600,
                          )),
                      if (selectionne) const Icon(Icons.check, color: Color(0xFF8B1E1E), size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
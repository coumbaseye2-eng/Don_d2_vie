import 'package:flutter/material.dart';

class _EligibiliteQuestion {
  final String question;
  final String sousTitre;
  final IconData icone;
  final String raisonSiNonEligible;
  const _EligibiliteQuestion({
    required this.question,
    required this.sousTitre,
    required this.icone,
    required this.raisonSiNonEligible,
  });
}

const _kRouge = Color(0xFF3F8A27);
const _kFond = Color(0xFFFAF5F3);

class TestDonScreen extends StatefulWidget {
  const TestDonScreen({super.key});

  @override
  State<TestDonScreen> createState() => _TestDonScreenState();
}

class _TestDonScreenState extends State<TestDonScreen> {
  static const _questions = [
    _EligibiliteQuestion(
      question: 'Avez-vous entre 18 et 65 ans ?',
      sousTitre: 'Condition d\'âge requise pour donner son sang.',
      icone: Icons.cake_outlined,
      raisonSiNonEligible:
      'Le don de sang est réservé aux personnes âgées de 18 à 65 ans, afin de garantir la sécurité du donneur comme du receveur.',
    ),
    _EligibiliteQuestion(
      question: 'Pesez-vous plus de 50 kg ?',
      sousTitre: 'Un poids minimum est nécessaire pour donner sans risque.',
      icone: Icons.monitor_weight_outlined,
      raisonSiNonEligible:
      'Un poids d\'au moins 50 kg est requis afin que le prélèvement ne représente pas un volume trop important par rapport à votre masse sanguine totale.',
    ),
    _EligibiliteQuestion(
      question: 'Vous sentez-vous en bonne santé aujourd\'hui ?',
      sousTitre: 'Pas de fièvre, rhume, grippe ou maladie récente.',
      icone: Icons.favorite_border,
      raisonSiNonEligible:
      'Pour votre sécurité et celle du receveur, il est nécessaire d\'être en bonne forme le jour du don, sans fièvre ni infection en cours.',
    ),
  ];

  int _step = 0;
  final List<bool?> _reponses = List.filled(_TestDonScreenState._questions.length, null);
  bool _termine = false;

  void _repondre(bool oui) {
    setState(() {
      _reponses[_step] = oui;
      if (_step < _questions.length - 1) {
        _step++;
      } else {
        _termine = true;
      }
    });
  }

  void _recommencer() {
    setState(() {
      _step = 0;
      _termine = false;
      for (var i = 0; i < _reponses.length; i++) {
        _reponses[i] = null;
      }
    });
  }

  bool get _estEligible => _reponses.every((r) => r == true);

  List<_EligibiliteQuestion> get _raisonsNonEligibilite {
    final raisons = <_EligibiliteQuestion>[];
    for (var i = 0; i < _questions.length; i++) {
      if (_reponses[i] == false) raisons.add(_questions[i]);
    }
    return raisons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kFond,
      appBar: AppBar(
        title: const Text('Test d\'éligibilité'),
        backgroundColor: _kFond,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
                  .animate(animation),
              child: child,
            ),
          ),
          child: _termine ? _buildResultat() : _buildQuestion(),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_step];
    return Padding(
      key: ValueKey('question_$_step'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(_questions.length, (i) {
              final actif = i <= _step;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i == _questions.length - 1 ? 0 : 6),
                  height: 6,
                  decoration: BoxDecoration(
                    color: actif ? _kRouge : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${_step + 1} sur ${_questions.length}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _kRouge.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(q.icone, size: 44, color: _kRouge),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            q.question,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.3),
          ),
          const SizedBox(height: 10),
          Text(
            q.sousTitre,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: _kRouge, width: 1.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _repondre(false),
                  child: const Text('Non', style: TextStyle(color: _kRouge,
                      fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kRouge,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () => _repondre(true),
                  child: const Text('Oui', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ),
              ),
            ],
          ),
          if (_step > 0) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _step--),
              child: Text('Question précédente', style: TextStyle(color: Colors.grey.shade600)
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildResultat() {
    final eligible = _estEligible;
    final raisons = _raisonsNonEligibilite;

    return SingleChildScrollView(
      key: const ValueKey('resultat'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: (eligible ? Colors.green : _kRouge).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                eligible ? Icons.check_circle_outline : Icons.info_outline,
                size: 56,
                color: eligible ? Colors.green.shade700 : _kRouge,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            eligible ? 'Vous semblez éligible !' : 'Pas éligible pour le moment',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            eligible
                ? 'D\'après vos réponses, vous remplissez les conditions de base pour donner '
                'votre sang. Un professionnel de santé confirmera votre éligibilité définitive'
                ' sur place.'
                : 'D\'après vos réponses, un ou plusieurs critères ne sont pas remplis aujourd\'hui.'
                ' Voici pourquoi :',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
          ),
          if (!eligible) ...[
            const SizedBox(height: 20),
            ...raisons.map((q) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(q.icone, color: _kRouge, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.question, style: const TextStyle(fontWeight: FontWeight.w700,
                            fontSize: 14)
                        ),
                        const SizedBox(height: 8),
                        Text(
                          q.raisonSiNonEligible,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 12),
          Text(
            'Ce test ne remplace pas un avis médical : seule une équipe de collecte peut confirmer '
                'votre éligibilité définitive.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: _kRouge),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _recommencer,
                  child: const Text('Refaire le test', style: TextStyle
                    (color: _kRouge, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kRouge,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Retour', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
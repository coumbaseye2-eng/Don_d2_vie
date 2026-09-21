import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import 'creation_profil_screen.dart';
import '../home_screen.dart';

class ConnexionScreen extends ConsumerStatefulWidget {
  const ConnexionScreen({super.key});
  @override
  ConsumerState<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends ConsumerState<ConnexionScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _chargement = false;
  bool _modeInscription = false;
  bool _obscureText = true;
  String? _erreur;

  String _messageErreur(Object e) {
    final message = e.toString().replaceFirst('Exception: ', '');
    return message.isEmpty ? 'Une erreur est survenue.' : message;
  }

  void _valider() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _erreur = 'Veuillez remplir tous les champs.');
      return;
    }

    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      if (_modeInscription) {
        await ref.read(authServiceProvider).inscrireAvecEmail(
          email: email,
          motDePasse: password,
        );
      } else {
        await ref.read(authServiceProvider).connecterAvecEmail(
          email: email,
          motDePasse: password,
        );
      }

      final uid = ref.read(authServiceProvider).utilisateurActuel!.uid;
      final profil = await ref.read(firestoreServiceProvider).getUtilisateur(uid);
      if (!mounted) return;

      if (profil == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CreationProfilScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() => _erreur = _messageErreur(e));
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B1E1E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.water_drop, color: Color(0xFF8B1E1E), size: 42),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Don de Vie',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF8B1E1E)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _modeInscription ? 'Créer un compte' : 'Bienvenue sur Don de Vie',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _modeInscription = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_modeInscription ? const Color(0xFF8B1E1E) : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                'Connexion',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !_modeInscription ? Colors.white : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _modeInscription = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _modeInscription ? const Color(0xFF8B1E1E) : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                'Inscription',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _modeInscription ? Colors.white : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Adresse e-mail',
                            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF8B1E1E)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8B1E1E)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _obscureText = !_obscureText),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_erreur != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF8B1E1E).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline, color: Color(0xFF8B1E1E), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _erreur!,
                                    style: const TextStyle(color: Color(0xFF8B1E1E), fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B1E1E),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: _chargement ? null : _valider,
                            child: _chargement
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                                  )
                                : Text(
                                    _modeInscription ? "S'inscrire →" : 'Se connecter →',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _modeInscription = !_modeInscription),
                    child: Text(
                      _modeInscription
                          ? 'Déjà un compte ? Se connecter'
                          : "Pas de compte ? S'inscrire",
                      style: const TextStyle(color: Color(0xFF8B1E1E), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> connecterAvecEmail({
    required String email,
    required String motDePasse,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
    } on FirebaseAuthException catch (e) {
      throw _messageErreur(e.code);
    }
  }

  Future<void> inscrireAvecEmail({
    required String email,
    required String motDePasse,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
    } on FirebaseAuthException catch (e) {
      throw _messageErreur(e.code);
    }
  }
  Future<void> supprimerCompte() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    try {
      await FirebaseFirestore.instance.collection('utilisateurs').doc(uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Pour des raisons de sécurité, veuillez vous reconnecter puis réessayer de supprimer votre compte.';
      }
      throw _messageErreur(e.code);
    }
  }

  String _messageErreur(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet e-mail est déjà utilisé.';
      case 'weak-password':
        return 'Le mot de passe est trop faible (6 caractères min.).';
      case 'invalid-email':
        return 'Adresse e-mail invalide.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Identifiants incorrects.';
      default:
        return 'Erreur : $code';
    }
  }

  User? get utilisateurActuel => _auth.currentUser;
  bool get estConnecte => _auth.currentUser != null;

  Future<void> deconnexion() async {
    await _auth.signOut();
  }
}
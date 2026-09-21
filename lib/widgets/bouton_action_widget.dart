import 'package:flutter/material.dart';

class BoutonAction extends StatelessWidget {
  final String texte;
  final VoidCallback? onPressed;
  final bool chargement;
  final Color couleur;
  final Color couleurTexte;

  const BoutonAction({
    super.key,
    required this.texte,
    required this.onPressed,
    this.chargement = false,
    this.couleur = const Color(0xFF8B1E1E),
    this.couleurTexte = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: couleur,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: chargement ? null : onPressed,
        child: chargement
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(texte, style: TextStyle(color: couleurTexte, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/urgence.dart';

class CarteUrgence extends StatelessWidget {
  final Urgence urgence;
  final VoidCallback onDonner;

  const CarteUrgence({super.key, required this.urgence, required this.onDonner});

  Color get _couleurNiveau {
    switch (urgence.niveau) {
      case 'critique':
        return const Color(0xFF8B1E1E);
      case 'eleve':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: _couleurNiveau, width: 4)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _couleurNiveau, borderRadius: BorderRadius.circular(20)),
                child: Text(urgence.niveau.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade100,
                child: Text(urgence.groupeSanguinRequis, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Besoin de ${urgence.pochesNecessaires} poches', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: urgence.pochesRecoltees / (urgence.pochesNecessaires == 0 ? 1 : urgence.pochesNecessaires),
            color: _couleurNiveau,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B1E1E)),
              onPressed: onDonner,
              child: const Text('Je donne pour cette urgence', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
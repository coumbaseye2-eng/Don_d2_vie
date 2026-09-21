import 'package:flutter/material.dart';
import '../models/badge.dart';

class BadgeCard extends StatelessWidget {
  final DonBadge badge;
  final bool debloque;

  const BadgeCard({super.key, required this.badge, required this.debloque});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: debloque ? Colors.amber.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            debloque ? Icons.emoji_events : Icons.lock,
            color: debloque ? Colors.amber.shade700 : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(badge.nom, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(badge.description, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
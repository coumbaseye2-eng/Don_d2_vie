import 'package:flutter/material.dart';
import '../models/centre.dart';

class CarteCentre extends StatelessWidget {
  final Centre centre;

  const CarteCentre({super.key, required this.centre});

  @override
  Widget build(BuildContext context) {
    final hasImage = centre.imageUrl != null && centre.imageUrl!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      centre.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.local_hospital, color: Colors.blueGrey),
                    ),
                  )
                : const Icon(Icons.local_hospital, color: Colors.blueGrey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(centre.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(centre.adresse, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text(
                  centre.statut == 'ouvert' ? 'Ouvert · ${centre.tempsAttente} min d\'attente' : 'Fermé',
                  style: TextStyle(
                    color: centre.statut == 'ouvert' ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }
}
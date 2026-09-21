import 'package:flutter/material.dart';

class TendanceStocksScreen extends StatelessWidget {
  const TendanceStocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [68, 74, 70, 82, 78, 88, 94];
    final labels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1E1E),
        foregroundColor: Colors.white,
        title: const Text('Tendances des stocks'),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFAF5F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B1E1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.bar_chart, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Stock global : +18% cette semaine',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Évolution des poches disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(data.length, (index) {
                      final value = data[index];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$value%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF8B1E1E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: (value / 100) * 180,
                                decoration: BoxDecoration(
                                  color: index == data.length - 1
                                      ? const Color(0xFF8B1E1E)
                                      : const Color(0xFFC76C6C),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                labels[index],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _miniCard('O-', '92%', Colors.red.shade50, const Color(0xFF8B1E1E)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _miniCard('A+', '76%', Colors.orange.shade50, Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _miniCard('B+', '61%', Colors.green.shade50, Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _miniCard(String label, String value, Color bgColor, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

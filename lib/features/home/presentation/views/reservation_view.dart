import 'package:flutter/material.dart';

class ReservationView extends StatelessWidget {
  const ReservationView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Menú del Día',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Almuerzo Base
        ListTile(
          shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          leading: const Icon(Icons.lunch_dining, size: 40, color: Colors.orange),
          title: const Text('Almuerzo Completo'),
          subtitle: const Text('Sopa, seco y jugo natural'),
          trailing: const Text('50 T', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 24),

        const Text('Adicionales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Extras (Mockups)
        CheckboxListTile(
          title: const Text('Postre extra (15 T)'),
          value: false, // Luego lo haremos dinámico
          onChanged: (bool? value) {},
        ),
        CheckboxListTile(
          title: const Text('Porción de carne extra (30 T)'),
          value: false,
          onChanged: (bool? value) {},
        ),
        
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            // Aquí conectaremos tu API /order
          },
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('RESERVAR CUPO', style: TextStyle(fontSize: 18)),
        )
      ],
    );
  }
}
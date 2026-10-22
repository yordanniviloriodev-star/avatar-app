// ============================================================================
// acerca_screen.dart  —  VISTA 5: ACERCA DE
// ----------------------------------------------------------------------------
// Información de la obra: temporadas, creadores, episodios, años, etc.
// Es una pantalla estática (sin estado): solo muestra información.
// ============================================================================

import 'package:flutter/material.dart';

import '../data/avatar_data.dart';

class AcercaScreen extends StatelessWidget {
  const AcercaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de la serie')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Encabezado con los 4 íconos de elementos
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Elemento.agua, Elemento.tierra, Elemento.fuego, Elemento.aire]
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: CircleAvatar(
                      backgroundColor: e.color,
                      child: Icon(e.icono, color: Colors.white),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Avatar: La Leyenda de Aang',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const Text(
            'Avatar: The Last Airbender',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 24),

          // Datos clave en una cuadrícula de 2 columnas
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true, // la cuadrícula ocupa solo lo necesario
            physics: const NeverScrollableScrollPhysics(), // el scroll lo hace el ListView
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: const [
              _Dato(icono: Icons.layers, valor: '3', etiqueta: 'Temporadas (Libros)'),
              _Dato(icono: Icons.play_circle, valor: '61', etiqueta: 'Episodios'),
              _Dato(icono: Icons.calendar_month, valor: '2005 – 2008', etiqueta: 'Años de emisión'),
              _Dato(icono: Icons.tv, valor: 'Nickelodeon', etiqueta: 'Cadena original'),
            ],
          ),
          const SizedBox(height: 24),

          _seccion(
            Icons.person,
            'Creadores',
            'Michael Dante DiMartino y Bryan Konietzko, quienes crearon la serie para Nickelodeon.',
          ),
          _seccion(
            Icons.public,
            'De qué trata',
            'En un mundo dividido en cuatro naciones (Agua, Tierra, Fuego y Aire), algunas personas '
                'pueden controlar su elemento. Solo el Avatar puede dominar los cuatro y mantener el '
                'equilibrio. Tras 100 años desaparecido, el nuevo Avatar, un niño llamado Aang, despierta '
                'en un mundo en guerra y debe detener a la Nación del Fuego.',
          ),
          _seccion(
            Icons.menu_book,
            'Las 3 temporadas',
            'Libro 1: Agua — Aang viaja al Polo Norte para aprender agua control.\n'
                'Libro 2: Tierra — El grupo busca un maestro tierra y conoce a Toph.\n'
                'Libro 3: Fuego — La misión final: vencer al Señor del Fuego Ozai antes del Cometa de Sozin.',
          ),
          _seccion(
            Icons.category,
            'Género',
            'Animación, aventura, fantasía y acción, con fuerte inspiración en las culturas asiáticas.',
          ),
          _seccion(
            Icons.auto_stories,
            'Universo',
            'Tiene una secuela, La Leyenda de Korra (2012–2014), y una adaptación live action de Netflix estrenada en 2024.',
          ),
        ],
      ),
    );
  }

  Widget _seccion(IconData icono, String titulo, String texto) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: const Color(0xFFF3A93B)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(texto, style: const TextStyle(fontSize: 15, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Cuadrito de dato clave (número grande + etiqueta).
class _Dato extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  const _Dato({required this.icono, required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2338),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3A93B).withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: const Color(0xFFF3A93B)),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

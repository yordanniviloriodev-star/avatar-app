// ============================================================================
// personajes_screen.dart  —  VISTA 2: PERSONAJES
// ----------------------------------------------------------------------------
// Lista con el NOMBRE de cada personaje (lo que pide la tarea). Al tocar uno,
// navegamos a PersonajeDetalleScreen, que muestra su foto y sus detalles.
// ============================================================================

import 'package:flutter/material.dart';

import '../data/avatar_data.dart';
import '../widgets/foto_red.dart';

class PersonajesScreen extends StatelessWidget {
  const PersonajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personajes')),
      // ListView.separated = lista con un separador entre cada elemento.
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: personajes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _TarjetaNombre(personaje: personajes[i]),
      ),
    );
  }
}

/// Tarjeta que solo muestra el nombre, el título y el elemento.
class _TarjetaNombre extends StatelessWidget {
  final Personaje personaje;
  const _TarjetaNombre({required this.personaje});

  @override
  Widget build(BuildContext context) {
    final color = personaje.elemento.color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        // Navigator.push = abrir una pantalla nueva ENCIMA de la actual.
        // El botón "atrás" del teléfono la cierra (Navigator.pop).
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => PersonajeDetalleScreen(personaje: personaje))),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(colors: [color.withValues(alpha: 0.35), const Color(0xFF1A2338)]),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Icon(personaje.elemento.icono, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(personaje.nombre, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(personaje.titulo, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DETALLE DEL PERSONAJE: foto + datos.
// ============================================================================
class PersonajeDetalleScreen extends StatelessWidget {
  final Personaje personaje;
  const PersonajeDetalleScreen({super.key, required this.personaje});

  @override
  Widget build(BuildContext context) {
    final color = personaje.elemento.color;
    return Scaffold(
      // CustomScrollView + SliverAppBar = cabecera grande con la foto que se
      // encoge al hacer scroll hacia arriba.
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: Color.lerp(color, Colors.black, 0.5),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(personaje.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [color.withValues(alpha: 0.7), const Color(0xFF0F1626)]),
                ),
                padding: const EdgeInsets.fromLTRB(24, 70, 24, 50),
                child: FotoRed(url: personaje.fotoUrl, respaldo: personaje.elemento.icono, color: color),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  personaje.titulo,
                  style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                // Fichas rápidas: elemento, nación, edad.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ficha(personaje.elemento.icono, personaje.elemento.nombre, color),
                    _ficha(Icons.flag, personaje.nacion, color),
                    _ficha(Icons.cake, personaje.edad, color),
                  ],
                ),
                const SizedBox(height: 20),
                _titulo('Historia'),
                Text(personaje.descripcion, style: const TextStyle(fontSize: 16, height: 1.5)),
                const SizedBox(height: 20),
                _titulo('Habilidades'),
                ...personaje.habilidades.map(
                  (h) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.bolt, color: color, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(h, style: const TextStyle(fontSize: 16))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border(left: BorderSide(color: color, width: 4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.amberAccent),
                      const SizedBox(width: 12),
                      Expanded(child: Text(personaje.dato, style: const TextStyle(fontSize: 15, height: 1.4))),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titulo(String texto) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _ficha(IconData icono, String texto, Color color) => Chip(
    avatar: Icon(icono, size: 18, color: color),
    label: Text(texto),
    side: BorderSide(color: color.withValues(alpha: 0.5)),
  );
}

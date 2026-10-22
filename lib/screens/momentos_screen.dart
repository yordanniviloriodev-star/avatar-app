// ============================================================================
// momentos_screen.dart  —  VISTA 3: MOMENTOS FAVORITOS
// ----------------------------------------------------------------------------
// Lista de 3 momentos (foto + título). Al tocar uno se abre el detalle, que
// tiene más texto y el VIDEO reproduciéndose DENTRO de la app.
//
// ¿Cómo se reproduce un video de YouTube sin salir de la app?
// El paquete youtube_player_iframe crea un WebView (un mini navegador
// invisible) incrustado en nuestra pantalla y carga ahí el reproductor oficial
// de YouTube (el mismo "iframe" que usan las páginas web para incrustar
// videos). Para el usuario es un reproductor más dentro de la app.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../data/avatar_data.dart';
import '../widgets/foto_red.dart';

class MomentosScreen extends StatelessWidget {
  const MomentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis momentos favoritos')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: momentos.length,
        itemBuilder: (context, i) => _TarjetaMomento(momento: momentos[i], numero: i + 1),
      ),
    );
  }
}

/// Tarjeta con la FOTO (miniatura del video) y el TÍTULO del momento.
class _TarjetaMomento extends StatelessWidget {
  final Momento momento;
  final int numero;
  const _TarjetaMomento({required this.momento, required this.numero});

  @override
  Widget build(BuildContext context) {
    final color = momento.elemento.color;
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      clipBehavior: Clip.antiAlias, // recorta la imagen con las esquinas redondas
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MomentoDetalleScreen(momento: momento))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: FotoRed(url: momento.miniaturaUrl, respaldo: Icons.movie, color: color, fit: BoxFit.cover),
                ),
                // Número del momento en una esquina
                Positioned(
                  top: 10,
                  left: 10,
                  child: CircleAvatar(
                    backgroundColor: color,
                    child: Text(
                      '#$numero',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Botón de "play" decorativo en el centro
                const Positioned.fill(
                  child: Center(child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white70)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(momento.titulo, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(momento.resumen, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DETALLE DEL MOMENTO: video incrustado + detalles.
// Es Stateful porque tiene un "controlador" del reproductor que hay que crear
// al abrir la pantalla (initState) y cerrar al salir (dispose).
// ============================================================================
class MomentoDetalleScreen extends StatefulWidget {
  final Momento momento;
  const MomentoDetalleScreen({super.key, required this.momento});

  @override
  State<MomentoDetalleScreen> createState() => _MomentoDetalleScreenState();
}

class _MomentoDetalleScreenState extends State<MomentoDetalleScreen> {
  late final YoutubePlayerController _controlador;

  @override
  void initState() {
    super.initState();
    // Creamos el reproductor con el id del video y lo ponemos a sonar solo.
    _controlador = YoutubePlayerController.fromVideoId(
      videoId: widget.momento.youtubeId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true, // botones de play/pausa/barra de tiempo
        showFullscreenButton: true, // permite verlo en pantalla completa
      ),
    );
  }

  @override
  void dispose() {
    _controlador.close(); // detiene el video y libera el WebView
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.momento;
    final color = m.elemento.color;

    // "player" = el reproductor de YouTube incrustado. En la versión 6 del
    // paquete, YoutubePlayer maneja solo la pantalla completa (botón, girar
    // el teléfono o deslizar hacia arriba) y el botón "atrás".
    final player = YoutubePlayer(controller: _controlador, aspectRatio: 16 / 9);

    return Scaffold(
      appBar: AppBar(title: Text(m.titulo, overflow: TextOverflow.ellipsis)),
      // SingleChildScrollView + Column (y no ListView) para que el
      // reproductor no se destruya al hacer scroll.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            player, // <-- el video, dentro de la app
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.tv, size: 18, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(m.episodio, style: TextStyle(color: color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('¿Qué pasa?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(m.detalle, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: color),
                            const SizedBox(width: 8),
                            const Text(
                              'Por qué es de mis favoritos',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(m.porQueMeGusta, style: const TextStyle(fontSize: 15, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Video: canal oficial "Avatar: The Last Airbender" en YouTube.',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

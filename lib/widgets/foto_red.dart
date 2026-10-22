// ============================================================================
// foto_red.dart  —  Widget reutilizable para fotos que vienen de internet.
// ----------------------------------------------------------------------------
// Image.network descarga la imagen. Le agregamos:
//  - loadingBuilder: un círculo de carga mientras descarga.
//  - errorBuilder: si no hay internet o la imagen falla, mostramos el ícono del
//    elemento en vez de una pantalla de error (la app nunca se "rompe").
// ============================================================================

import 'package:flutter/material.dart';

class FotoRed extends StatelessWidget {
  final String url;
  final IconData respaldo; // ícono a mostrar si la foto falla
  final Color color;
  final BoxFit fit;

  const FotoRed({super.key, required this.url, required this.respaldo, required this.color, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      // loadingProgress es null cuando ya terminó de cargar.
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(child: CircularProgressIndicator(color: color));
      },
      errorBuilder: (context, error, stack) =>
          Center(child: Icon(respaldo, size: 120, color: color.withValues(alpha: 0.8))),
    );
  }
}

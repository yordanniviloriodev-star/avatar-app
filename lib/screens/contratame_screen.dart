// ============================================================================
// contratame_screen.dart  —  VISTA 6: CONTRÁTAME
// ----------------------------------------------------------------------------
// Foto del desarrollador + datos de contacto. Los botones abren WhatsApp, el
// correo o GitHub usando el paquete url_launcher.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/avatar_data.dart';

class ContratameScreen extends StatelessWidget {
  const ContratameScreen({super.key});

  /// Abre un enlace fuera de la app (WhatsApp, Gmail, navegador).
  /// "async" porque abrir la otra app toma un momento y esperamos (await)
  /// la respuesta. Si falla, mostramos un mensaje abajo (SnackBar).
  Future<void> _abrir(BuildContext context, String enlace) async {
    final ok = await launchUrl(Uri.parse(enlace), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir: $enlace')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const naranja = Color(0xFFF3A93B);
    return Scaffold(
      appBar: AppBar(title: const Text('Contrátame')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Foto con un aro degradado alrededor
          Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xFF2E9BDA),
                    Color(0xFF5DA94A),
                    Color(0xFFE2512C),
                    Color(0xFFF3A93B),
                    Color(0xFF2E9BDA),
                  ],
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  Desarrollador.foto,
                  width: 170,
                  height: 170,
                  fit: BoxFit.cover,
                  // Si falta la foto, muestra un ícono en vez de fallar.
                  errorBuilder: (_, __, ___) => Container(
                    width: 170,
                    height: 170,
                    color: const Color(0xFF1A2338),
                    child: const Icon(Icons.person, size: 100, color: Colors.white54),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            Desarrollador.nombre,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            Desarrollador.rol,
            textAlign: TextAlign.center,
            style: TextStyle(color: naranja),
          ),
          const SizedBox(height: 2),
          const Text(
            'Matrícula ${Desarrollador.matricula}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 18),
          const Text(
            '¿Te gustó esta app? Diseño y desarrollo aplicaciones móviles y web con atención al detalle. '
            'Escríbeme para tu próximo proyecto.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 18),
          // Chips con tecnologías
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: Desarrollador.habilidades.map((h) => Chip(label: Text(h))).toList(),
          ),
          const SizedBox(height: 24),
          _BotonContacto(
            icono: Icons.chat,
            color: const Color(0xFF25D366),
            titulo: 'WhatsApp',
            valor: Desarrollador.whatsappVisible,
            alTocar: () => _abrir(context, Desarrollador.whatsappLink),
          ),
          _BotonContacto(
            icono: Icons.email,
            color: const Color(0xFFE2512C),
            titulo: 'Correo',
            valor: Desarrollador.correo,
            alTocar: () => _abrir(context, 'mailto:${Desarrollador.correo}?subject=Proyecto%20desde%20Avatar%20App'),
          ),
          _BotonContacto(
            icono: Icons.code,
            color: Colors.white,
            titulo: 'GitHub',
            valor: Desarrollador.github,
            alTocar: () => _abrir(context, Desarrollador.githubLink),
          ),
        ],
      ),
    );
  }
}

/// Fila tocable con ícono, título y valor del contacto.
class _BotonContacto extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String valor;
  final VoidCallback alTocar;

  const _BotonContacto({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.valor,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: alTocar,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icono, color: color),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(valor),
        trailing: const Icon(Icons.open_in_new, size: 18),
      ),
    );
  }
}

// ============================================================================
// portada_screen.dart  —  VISTA 1: PORTADA
// ----------------------------------------------------------------------------
// Un slider (carrusel) automático con los 4 elementos. Cada 3.5 segundos pasa
// solo a la siguiente diapositiva, y también se puede deslizar con el dedo.
// Al fondo flotan partículas animadas del color del elemento actual.
// ============================================================================

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/avatar_data.dart';

class PortadaScreen extends StatefulWidget {
  /// Función que se ejecuta al tocar "Comenzar" (la recibe desde main.dart).
  final VoidCallback alComenzar;
  const PortadaScreen({super.key, required this.alComenzar});

  @override
  State<PortadaScreen> createState() => _PortadaScreenState();
}

/// Datos de cada diapositiva del slider.
class _Diapositiva {
  final Elemento elemento;
  final String nacion;
  final String frase;
  const _Diapositiva(this.elemento, this.nacion, this.frase);
}

const _diapositivas = [
  _Diapositiva(Elemento.agua, 'Tribus Agua', 'El agua fluye y se adapta: es el elemento del cambio.'),
  _Diapositiva(Elemento.tierra, 'Reino Tierra', 'La tierra resiste y persevera: es el elemento de la fuerza.'),
  _Diapositiva(Elemento.fuego, 'Nación del Fuego', 'El fuego es energía y voluntad: es el elemento del poder.'),
  _Diapositiva(Elemento.aire, 'Nómadas del Aire', 'El aire es libertad: es el elemento del desapego.'),
];

// "with TickerProviderStateMixin" nos da un reloj para las animaciones.
class _PortadaScreenState extends State<PortadaScreen> with TickerProviderStateMixin {
  final _paginas = PageController();
  late final AnimationController _particulas; // reloj de las partículas
  late final AnimationController _pulso; // reloj del brillo del ícono
  Timer? _temporizador;
  int _actual = 0;

  @override
  void initState() {
    super.initState();
    // repeat() = la animación se repite para siempre (0.0 → 1.0 → 0.0 ...)
    _particulas = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _pulso = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

    // Cada 3.5 s avanza a la siguiente diapositiva (el % hace que vuelva a 0).
    _temporizador = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!_paginas.hasClients) return;
      final siguiente = (_actual + 1) % _diapositivas.length;
      _paginas.animateToPage(siguiente, duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
    });
  }

  // dispose() se ejecuta al salir de la pantalla: liberamos relojes y timers
  // para no gastar memoria ni batería.
  @override
  void dispose() {
    _temporizador?.cancel();
    _paginas.dispose();
    _particulas.dispose();
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _diapositivas[_actual].elemento.color;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1) Fondo degradado que cambia de color según el elemento actual.
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(color, Colors.black, 0.55)!, const Color(0xFF0F1626)],
            ),
          ),
        ),
        // 2) Partículas flotando (dibujadas a mano con CustomPainter).
        AnimatedBuilder(
          animation: _particulas,
          builder: (_, __) => CustomPaint(painter: _ParticulasPainter(_particulas.value, color)),
        ),
        // 3) Contenido: título, slider, indicadores y botón.
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                'AVATAR',
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                  color: const Color(0xFFF4E4C1),
                  shadows: [Shadow(color: color, blurRadius: 24)],
                ),
              ),
              const Text(
                'LA LEYENDA DE AANG',
                style: TextStyle(fontSize: 15, letterSpacing: 5, color: Colors.white70, fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _paginas,
                  itemCount: _diapositivas.length,
                  onPageChanged: (i) => setState(() => _actual = i),
                  itemBuilder: (_, i) => _vistaDiapositiva(_diapositivas[i]),
                ),
              ),
              // Puntitos indicadores: el activo es más ancho.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_diapositivas.length, (i) {
                  final activo = i == _actual;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: activo ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: activo ? color : Colors.white30,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FilledButton.icon(
                  onPressed: widget.alComenzar,
                  icon: const Icon(Icons.explore),
                  label: const Text('Comenzar la aventura'),
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye UNA diapositiva del slider.
  Widget _vistaDiapositiva(_Diapositiva d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // El ícono "respira": su brillo crece y baja con _pulso.
          AnimatedBuilder(
            animation: _pulso,
            builder: (_, child) => Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: d.elemento.color.withValues(alpha: 0.15),
                border: Border.all(color: d.elemento.color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: d.elemento.color.withValues(alpha: 0.6),
                    blurRadius: 20 + 30 * _pulso.value,
                    spreadRadius: 2 + 6 * _pulso.value,
                  ),
                ],
              ),
              child: child,
            ),
            child: Icon(d.elemento.icono, size: 90, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Text(
            d.elemento.nombre.toUpperCase(),
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 6, color: d.elemento.color),
          ),
          const SizedBox(height: 4),
          Text(d.nacion, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 16),
          Text(
            d.frase,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

/// Dibuja 40 partículas que suben lentamente y ondulan.
/// "t" va de 0 a 1 una y otra vez; con él calculamos la posición de cada una.
class _ParticulasPainter extends CustomPainter {
  final double t;
  final Color color;
  _ParticulasPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(7); // misma semilla = mismas partículas en cada cuadro
    final pintura = Paint();
    for (var i = 0; i < 40; i++) {
      final xBase = rnd.nextDouble() * size.width;
      final velocidad = 0.3 + rnd.nextDouble();
      final fase = rnd.nextDouble();
      final radio = 1.5 + rnd.nextDouble() * 3;
      // y avanza hacia arriba; el % 1 la regresa abajo al salir por arriba.
      final progreso = (fase + t * velocidad) % 1.0;
      final y = size.height * (1 - progreso);
      final x = xBase + sin((progreso + fase) * pi * 4) * 18;
      pintura.color = color.withValues(alpha: 0.15 + 0.5 * (1 - progreso));
      canvas.drawCircle(Offset(x, y), radio, pintura);
    }
  }

  // Repintar cada vez que cambia t o el color.
  @override
  bool shouldRepaint(_ParticulasPainter old) => old.t != t || old.color != color;
}

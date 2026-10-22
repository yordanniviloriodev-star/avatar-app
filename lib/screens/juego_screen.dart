// ============================================================================
// juego_screen.dart  —  VISTA 4: JUEGA CONMIGO  ·  "El Vuelo del Planeador"
// ----------------------------------------------------------------------------
// CÓMO SE JUEGA
//  - Toca la pantalla para que el planeador de aire suba; si no tocas, cae.
//  - Pasa entre los pilares de roca del Reino Tierra (+1 punto por pilar).
//  - Recoge espirales de aire (+2 puntos). Con 3 espirales se carga el
//    ESTADO AVATAR: 5 segundos invencible, atraviesas todo y los puntos x2.
//  - Desde los 5 puntos aparecen bolas de fuego de la Nación del Fuego.
//  - Mientras más puntos, más rápido va el juego y más estrechos los huecos.
//  - Tu récord se guarda en el teléfono.
//
// CÓMO ESTÁ HECHO (3 piezas, igual que un motor de juegos)
//  1) _Mundo      = LA LÓGICA. Posiciones, física (gravedad), colisiones,
//                   puntaje. No dibuja nada, solo hace cálculos.
//  2) _Pintor     = EL DIBUJO. Un CustomPainter que lee el _Mundo y dibuja
//                   cielo, nubes, pilares, planeador, etc. en un Canvas.
//  3) Ticker      = EL RELOJ. Llama una función ~60 veces por segundo
//                   (un "frame"). En cada frame: actualizar mundo → redibujar.
// ============================================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Objetos del juego (cada uno guarda solo su posición y su estado)
// ---------------------------------------------------------------------------
class _Pilar {
  double x; // borde izquierdo
  final double centroHueco; // centro vertical del espacio por donde se pasa
  final double hueco; // alto del espacio
  bool pasado = false; // ¿ya sumó su punto?
  _Pilar(this.x, this.centroHueco, this.hueco);
}

class _Espiral {
  double x, y;
  bool tomada = false;
  _Espiral(this.x, this.y);
}

class _BolaFuego {
  double x, y;
  final double yBase;
  double t = 0; // tiempo de vida (para la ondulación)
  bool viva = true;
  _BolaFuego(this.x, this.yBase) : y = yBase;
}

class _Particula {
  double x, y, vx, vy, vida; // vida: 1 = recién nacida, 0 = desaparece
  final Color color;
  final double radio;
  _Particula(this.x, this.y, this.vx, this.vy, this.color, this.radio) : vida = 1;
}

class _Nube {
  double x;
  final double y, escala, velocidad;
  _Nube(this.x, this.y, this.escala, this.velocidad);
}

enum Fase { inicio, jugando, fin }

// ===========================================================================
// 1) LA LÓGICA DEL JUEGO
// ===========================================================================
class _Mundo {
  final _rnd = Random();
  Size tam = Size.zero; // tamaño de la pantalla de juego

  Fase fase = Fase.inicio;
  double tiempo = 0; // segundos totales (para animaciones)

  // Planeador
  double y = 0; // posición vertical
  double vy = 0; // velocidad vertical (+ = baja, - = sube)
  double get x => tam.width * 0.28; // posición horizontal fija
  static const radio = 16.0;

  // Puntaje y Estado Avatar
  int puntos = 0;
  int espiralesCargadas = 0; // 0..3
  double estadoAvatar = 0; // segundos restantes de invencibilidad
  bool get enEstadoAvatar => estadoAvatar > 0;
  bool get avatarListo => espiralesCargadas >= 3 && !enEstadoAvatar;

  final pilares = <_Pilar>[];
  final espirales = <_Espiral>[];
  final bolas = <_BolaFuego>[];
  final particulas = <_Particula>[];
  final nubes = <_Nube>[];

  double _distanciaDesdePilar = 0;
  double _relojFuego = 3;
  double tiempoEnFin = 0; // para no reiniciar por accidente

  // "Constantes" que dependen del alto de la pantalla, para que el juego se
  // sienta igual en un teléfono pequeño o grande.
  double get gravedad => tam.height * 2.2;
  double get impulso => -tam.height * 0.62;
  double get velocidad => min(170.0 + puntos * 3.5, 330.0); // px por segundo
  double get hueco => max(tam.height * 0.30 - puntos * 2.0, tam.height * 0.22);
  static const anchoPilar = 64.0;
  static const separacion = 240.0;

  /// Deja todo listo para una partida nueva.
  void reiniciar() {
    y = tam.height * 0.45;
    vy = 0;
    puntos = 0;
    espiralesCargadas = 0;
    estadoAvatar = 0;
    pilares.clear();
    espirales.clear();
    bolas.clear();
    _distanciaDesdePilar = separacion; // así aparece un pilar enseguida
    _relojFuego = 3;
    fase = Fase.jugando;
  }

  /// Tocar la pantalla = impulso hacia arriba.
  void aletear() {
    vy = impulso;
    // Una ráfaga de partículas blancas detrás del planeador
    for (var i = 0; i < 6; i++) {
      particulas.add(
        _Particula(
          x - 10,
          y + 6,
          -60 - _rnd.nextDouble() * 80,
          40 + _rnd.nextDouble() * 60,
          Colors.white,
          2 + _rnd.nextDouble() * 2,
        ),
      );
    }
  }

  void activarAvatar() {
    if (!avatarListo) return;
    espiralesCargadas = 0;
    estadoAvatar = 5;
    _explosion(x, y, const Color(0xFF7FE7FF), 30);
  }

  /// SE LLAMA EN CADA FRAME. dt = segundos desde el frame anterior (~0.016).
  void actualizar(double dt) {
    tiempo += dt;
    _moverNubes(dt);
    _moverParticulas(dt);
    if (fase == Fase.fin) tiempoEnFin += dt;
    if (fase != Fase.jugando) return;

    // --- Física del planeador: la gravedad cambia la velocidad,
    //     y la velocidad cambia la posición. (Física básica: v += a·t ; y += v·t)
    vy += gravedad * dt;
    y += vy * dt;

    if (enEstadoAvatar) {
      estadoAvatar -= dt;
      y = y.clamp(radio, tam.height - radio); // invencible: no choca con bordes
      if (_rnd.nextDouble() < 0.6) {
        particulas.add(_Particula(x, y, -120, (_rnd.nextDouble() - 0.5) * 80, const Color(0xFF7FE7FF), 3));
      }
    } else if (y < -radio || y > tam.height + radio) {
      _perder();
      return;
    }

    final avance = velocidad * dt; // cuánto se mueve el mundo a la izquierda
    _moverPilares(avance);
    _moverEspirales(avance);
    _moverBolas(dt, avance);
  }

  void _moverPilares(double avance) {
    _distanciaDesdePilar += avance;
    if (_distanciaDesdePilar >= separacion) {
      _distanciaDesdePilar = 0;
      final h = hueco;
      final margen = 60 + h / 2;
      final centro = margen + _rnd.nextDouble() * (tam.height - 2 * margen);
      pilares.add(_Pilar(tam.width + 10, centro, h));
      // 55% de probabilidad de una espiral a mitad de camino al siguiente pilar
      if (_rnd.nextDouble() < 0.55) {
        final ey = 70 + _rnd.nextDouble() * (tam.height - 140);
        espirales.add(_Espiral(tam.width + 10 + anchoPilar + separacion / 2, ey));
      }
    }

    for (final p in pilares) {
      p.x -= avance;
      // ¿Ya lo pasamos? +1 punto (x2 en Estado Avatar)
      if (!p.pasado && p.x + anchoPilar < x - radio) {
        p.pasado = true;
        puntos += enEstadoAvatar ? 2 : 1;
      }
      // ¿Chocamos? Revisamos el rectángulo de arriba y el de abajo.
      if (!enEstadoAvatar) {
        final arriba = Rect.fromLTRB(p.x, -1000, p.x + anchoPilar, p.centroHueco - p.hueco / 2);
        final abajo = Rect.fromLTRB(p.x, p.centroHueco + p.hueco / 2, p.x + anchoPilar, tam.height + 1000);
        if (_circuloTocaRect(arriba) || _circuloTocaRect(abajo)) {
          _perder();
          return;
        }
      }
    }
    pilares.removeWhere((p) => p.x < -anchoPilar - 10); // borrar los que salieron
  }

  void _moverEspirales(double avance) {
    for (final e in espirales) {
      e.x -= avance;
      if (!e.tomada && _distancia(e.x, e.y, x, y) < radio + 18) {
        e.tomada = true;
        puntos += enEstadoAvatar ? 4 : 2;
        if (!enEstadoAvatar) espiralesCargadas = min(espiralesCargadas + 1, 3);
        _explosion(e.x, e.y, Colors.white, 14);
        HapticFeedback.selectionClick();
      }
    }
    espirales.removeWhere((e) => e.tomada || e.x < -40);
  }

  void _moverBolas(double dt, double avance) {
    if (puntos >= 5) {
      _relojFuego -= dt;
      if (_relojFuego <= 0) {
        _relojFuego = 2.5 + _rnd.nextDouble() * 2.0 - min(puntos * 0.02, 1.0);
        bolas.add(_BolaFuego(tam.width + 30, 60 + _rnd.nextDouble() * (tam.height - 120)));
      }
    }
    for (final b in bolas) {
      b.t += dt;
      b.x -= avance + 150 * dt; // las bolas van más rápido que el mundo
      b.y = b.yBase + sin(b.t * 3) * 30; // ondulan
      if (_rnd.nextDouble() < 0.7) {
        particulas.add(_Particula(b.x + 10, b.y, 40, (_rnd.nextDouble() - 0.5) * 40, const Color(0xFFFF8A3D), 3));
      }
      if (b.viva && _distancia(b.x, b.y, x, y) < radio + 14) {
        if (enEstadoAvatar) {
          b.viva = false; // en Estado Avatar las apagas
          puntos += 1;
          _explosion(b.x, b.y, const Color(0xFFFF8A3D), 20);
        } else {
          _perder();
          return;
        }
      }
    }
    bolas.removeWhere((b) => !b.viva || b.x < -40);
  }

  void _moverNubes(double dt) {
    if (nubes.isEmpty && tam != Size.zero) {
      for (var i = 0; i < 6; i++) {
        nubes.add(
          _Nube(
            _rnd.nextDouble() * tam.width,
            40 + _rnd.nextDouble() * tam.height * 0.5,
            0.6 + _rnd.nextDouble() * 0.8,
            15 + _rnd.nextDouble() * 25,
          ),
        );
      }
    }
    final factor = fase == Fase.jugando ? 1.0 + velocidad / 200 : 1.0;
    for (final n in nubes) {
      n.x -= n.velocidad * factor * dt;
      if (n.x < -120) n.x = tam.width + 120;
    }
  }

  void _moverParticulas(double dt) {
    for (final p in particulas) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vida -= dt * 1.6;
    }
    particulas.removeWhere((p) => p.vida <= 0);
    if (particulas.length > 300) particulas.removeRange(0, particulas.length - 300);
  }

  void _perder() {
    fase = Fase.fin;
    tiempoEnFin = 0;
    _explosion(x, y, const Color(0xFFF3A93B), 40);
    HapticFeedback.heavyImpact();
  }

  void _explosion(double ex, double ey, Color color, int cantidad) {
    for (var i = 0; i < cantidad; i++) {
      final ang = _rnd.nextDouble() * 2 * pi;
      final vel = 60 + _rnd.nextDouble() * 220;
      particulas.add(_Particula(ex, ey, cos(ang) * vel, sin(ang) * vel, color, 2 + _rnd.nextDouble() * 3));
    }
  }

  // --- Geometría ---
  double _distancia(double x1, double y1, double x2, double y2) => sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));

  /// ¿El círculo del planeador toca este rectángulo?
  /// Truco clásico: buscar el punto del rectángulo más cercano al centro del
  /// círculo; si ese punto está a menos de un radio, hay choque.
  bool _circuloTocaRect(Rect r) {
    final cx = x.clamp(r.left, r.right);
    final cy = y.clamp(r.top, r.bottom);
    return _distancia(cx, cy, x, y) < radio - 2; // -2 = un poquito de perdón
  }
}

// ===========================================================================
// PANTALLA (une lógica + dibujo + toques del usuario)
// ===========================================================================
class JuegoScreen extends StatefulWidget {
  const JuegoScreen({super.key});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> with SingleTickerProviderStateMixin {
  final _mundo = _Mundo();
  late final Ticker _ticker;
  Duration _ultimo = Duration.zero;
  int _record = 0;

  @override
  void initState() {
    super.initState();
    // 3) EL RELOJ: createTicker llama _alTic en cada frame de la pantalla.
    _ticker = createTicker(_alTic)..start();
    _cargarRecord();
  }

  Future<void> _cargarRecord() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _record = prefs.getInt('record') ?? 0);
  }

  Future<void> _guardarRecord() async {
    if (_mundo.puntos <= _record) return;
    _record = _mundo.puntos;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('record', _record);
  }

  void _alTic(Duration transcurrido) {
    // dt = tiempo real entre frames, limitado a 1/30 s para evitar saltos
    // grandes si el teléfono se traba un momento.
    final dt = ((transcurrido - _ultimo).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _ultimo = transcurrido;
    final antes = _mundo.fase;
    _mundo.actualizar(dt);
    if (antes == Fase.jugando && _mundo.fase == Fase.fin) _guardarRecord();
    setState(() {}); // redibujar
  }

  void _tocar() {
    switch (_mundo.fase) {
      case Fase.inicio:
        _mundo.reiniciar();
        _mundo.aletear();
      case Fase.jugando:
        _mundo.aletear();
        HapticFeedback.lightImpact();
      case Fase.fin:
        if (_mundo.tiempoEnFin > 0.7) {
          _mundo.reiniciar();
          _mundo.aletear();
        }
    }
  }

  @override
  void dispose() {
    _ticker.dispose(); // detener el reloj al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, restricciones) {
          // LayoutBuilder nos dice cuánto espacio hay → tamaño del mundo
          final tam = Size(restricciones.maxWidth, restricciones.maxHeight);
          if (_mundo.tam != tam) {
            _mundo.tam = tam;
            if (_mundo.fase == Fase.inicio) _mundo.y = tam.height * 0.45;
          }
          return Stack(
            children: [
              // El área de juego: cualquier toque = aletear
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => _tocar(),
                  child: CustomPaint(painter: _Pintor(_mundo)),
                ),
              ),
              if (_mundo.fase == Fase.jugando) _hud(),
              if (_mundo.fase == Fase.inicio) _pantallaInicio(),
              if (_mundo.fase == Fase.fin) _pantallaFin(),
            ],
          );
        },
      ),
    );
  }

  // --- Marcador durante el juego ---
  Widget _hud() {
    return SafeArea(
      child: Stack(
        children: [
          // IgnorePointer: los textos del marcador no bloquean los toques
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        '${_mundo.puntos}',
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                        ),
                      ),
                    ),
                  ),
                  // Medidor de espirales (3 círculos)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Row(
                      children: List.generate(3, (i) {
                        final lleno = _mundo.enEstadoAvatar || i < _mundo.espiralesCargadas;
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: lleno ? const Color(0xFF7FE7FF) : Colors.black26,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.air, size: 13, color: Colors.white),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    right: 16,
                    child: Text(
                      'Récord $_record',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botón del Estado Avatar (solo cuando está cargado)
          if (_mundo.avatarListo || _mundo.enEstadoAvatar)
            Positioned(
              bottom: 24,
              right: 20,
              child: _mundo.enEstadoAvatar
                  ? Chip(
                      backgroundColor: const Color(0xFF7FE7FF),
                      label: Text(
                        'ESTADO AVATAR ${_mundo.estadoAvatar.toStringAsFixed(1)}s',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: () => setState(_mundo.activarAvatar),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('¡Estado Avatar!'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7FE7FF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _panel({required List<Widget> hijos}) {
    // IgnorePointer: el panel no "roba" el toque; el toque llega al juego.
    return IgnorePointer(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xE60F1626),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF3A93B), width: 2),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: hijos),
        ),
      ),
    );
  }

  Widget _pantallaInicio() {
    const estiloRegla = TextStyle(fontSize: 15, height: 1.5, color: Colors.white);
    return _panel(
      hijos: const [
        Icon(Icons.air, size: 56, color: Color(0xFFF3A93B)),
        SizedBox(height: 8),
        Text(
          'El Vuelo del Planeador',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        SizedBox(height: 14),
        Text('👆 Toca para elevar el planeador', style: estiloRegla),
        Text('⛰️ Esquiva los pilares de roca', style: estiloRegla),
        Text('🌀 Recoge 3 espirales de aire', style: estiloRegla),
        Text('✨ ...y activa el Estado Avatar', style: estiloRegla),
        Text('🔥 ¡Cuidado con las bolas de fuego!', style: estiloRegla),
        SizedBox(height: 18),
        Text(
          'TOCA PARA EMPEZAR',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF3A93B), letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _pantallaFin() {
    final nuevoRecord = _mundo.puntos >= _record && _mundo.puntos > 0;
    return _panel(
      hijos: [
        Text(
          nuevoRecord ? '¡NUEVO RÉCORD!' : 'Has caído',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: nuevoRecord ? const Color(0xFF7FE7FF) : const Color(0xFFE2512C),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${_mundo.puntos}',
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        Text('Récord: $_record', style: const TextStyle(fontSize: 16, color: Colors.white70)),
        const SizedBox(height: 10),
        Text(
          _frase(_mundo.puntos),
          textAlign: TextAlign.center,
          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'TOCA PARA VOLVER A VOLAR',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF3A93B), letterSpacing: 1.5),
        ),
      ],
    );
  }

  /// Rango según los puntos (como subir de nivel en la serie).
  String _frase(int p) {
    if (p < 5) return 'Rango: Aprendiz del Templo del Aire';
    if (p < 15) return 'Rango: Monje Nómada';
    if (p < 30) return 'Rango: Maestro Aire';
    if (p < 50) return 'Rango: Guardián de los Cuatro Elementos';
    return 'Rango: ¡Eres el Avatar!';
  }
}

// ===========================================================================
// 2) EL DIBUJO
// ===========================================================================
class _Pintor extends CustomPainter {
  final _Mundo m;
  _Pintor(this.m);

  @override
  void paint(Canvas canvas, Size size) {
    _cielo(canvas, size);
    _montanas(canvas, size);
    for (final n in m.nubes) {
      _nube(canvas, n);
    }
    for (final p in m.pilares) {
      _pilar(canvas, size, p);
    }
    for (final e in m.espirales) {
      _espiral(canvas, e);
    }
    for (final b in m.bolas) {
      _bola(canvas, b);
    }
    for (final p in m.particulas) {
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radio * p.vida,
        Paint()..color = p.color.withValues(alpha: p.vida.clamp(0.0, 1.0)),
      );
    }
    if (m.fase != Fase.fin) _planeador(canvas);
  }

  /// Cielo que cambia de día → atardecer → noche según los puntos.
  void _cielo(Canvas canvas, Size size) {
    final t = (m.puntos / 40).clamp(0.0, 1.0);
    final arriba = t < 0.5
        ? Color.lerp(const Color(0xFF4FA3E0), const Color(0xFFE07A4F), t * 2)!
        : Color.lerp(const Color(0xFFE07A4F), const Color(0xFF1B1F4A), (t - 0.5) * 2)!;
    final abajo = t < 0.5
        ? Color.lerp(const Color(0xFFBFE6FF), const Color(0xFFFFC98B), t * 2)!
        : Color.lerp(const Color(0xFFFFC98B), const Color(0xFF4B3B7A), (t - 0.5) * 2)!;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [arriba, abajo],
        ).createShader(rect),
    );
    // Sol (o luna) que baja con el tiempo
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * (0.15 + t * 0.4)),
      34,
      Paint()..color = Color.lerp(const Color(0xFFFFF3B0), const Color(0xFFE8E8FF), t)!.withValues(alpha: 0.9),
    );
  }

  /// Montañas lejanas que se desplazan muy lento (efecto "parallax").
  void _montanas(Canvas canvas, Size size) {
    final desplazamiento = (m.tiempo * 12) % size.width;
    final pintura = Paint()..color = const Color(0xFF2B3A55).withValues(alpha: 0.45);
    for (var k = 0; k < 2; k++) {
      final base = -desplazamiento + k * size.width;
      final path = Path()..moveTo(base, size.height);
      for (var i = 0; i <= 6; i++) {
        final px = base + i * size.width / 6;
        final py = size.height * (i.isEven ? 0.78 : 0.62);
        path.lineTo(px, py);
      }
      path
        ..lineTo(base + size.width, size.height)
        ..close();
      canvas.drawPath(path, pintura);
    }
  }

  void _nube(Canvas canvas, _Nube n) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.75);
    final s = n.escala;
    canvas.drawCircle(Offset(n.x, n.y), 22 * s, p);
    canvas.drawCircle(Offset(n.x + 24 * s, n.y - 8 * s), 26 * s, p);
    canvas.drawCircle(Offset(n.x + 50 * s, n.y), 20 * s, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(n.x - 10 * s, n.y, 72 * s, 18 * s), Radius.circular(9 * s)),
      p,
    );
  }

  /// Pilar de roca con franjas y musgo en la punta.
  void _pilar(Canvas canvas, Size size, _Pilar p) {
    const ancho = _Mundo.anchoPilar;
    final finArriba = p.centroHueco - p.hueco / 2;
    final inicioAbajo = p.centroHueco + p.hueco / 2;
    final roca = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF6B4F35), Color(0xFF9C7650), Color(0xFF5A4030)])
          .createShader(Rect.fromLTWH(p.x, 0, ancho, size.height));
    final lineas = Paint()
      ..color = const Color(0x55000000)
      ..strokeWidth = 2;
    final musgo = Paint()..color = const Color(0xFF5DA94A);

    void bloque(double top, double bottom, bool puntaAbajo) {
      if (bottom <= top) return;
      canvas.drawRect(Rect.fromLTRB(p.x, top, p.x + ancho, bottom), roca);
      for (var yy = top + 28; yy < bottom; yy += 28) {
        canvas.drawLine(Offset(p.x + 6, yy), Offset(p.x + ancho - 6, yy), lineas);
      }
      // borde con musgo del lado del hueco
      final yMusgo = puntaAbajo ? bottom - 10 : top;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(p.x - 5, yMusgo, ancho + 10, 10), const Radius.circular(5)),
        musgo,
      );
    }

    bloque(0, finArriba, true);
    bloque(inicioAbajo, size.height, false);
  }

  /// Espiral de aire: 3 arcos que giran.
  void _espiral(Canvas canvas, _Espiral e) {
    final centro = Offset(e.x, e.y);
    canvas.drawCircle(centro, 20, Paint()..color = const Color(0x557FE7FF));
    final trazo = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final r = 6.0 + i * 5;
      canvas.drawArc(Rect.fromCircle(center: centro, radius: r), m.tiempo * 5 + i * 2.1, pi * 1.2, false, trazo);
    }
  }

  void _bola(Canvas canvas, _BolaFuego b) {
    final c = Offset(b.x, b.y);
    canvas.drawCircle(
      c,
      16,
      Paint()
        ..shader = const RadialGradient(colors: [Color(0xFFFFF3B0), Color(0xFFFF8A3D), Color(0xFFE2512C)])
            .createShader(Rect.fromCircle(center: c, radius: 16)),
    );
  }

  /// El planeador: un bastón de madera con alas naranjas, inclinado según
  /// la velocidad vertical (sube → nariz arriba, cae → nariz abajo).
  void _planeador(Canvas canvas) {
    final angulo = (m.vy / 700).clamp(-0.5, 0.8);
    canvas.save();
    canvas.translate(m.x, m.y);
    canvas.rotate(angulo);

    if (m.enEstadoAvatar) {
      final brillo = 26 + sin(m.tiempo * 12) * 4;
      canvas.drawCircle(Offset.zero, brillo, Paint()..color = const Color(0x887FE7FF));
    }
    // bastón
    canvas.drawLine(
      const Offset(-26, 4),
      const Offset(24, 4),
      Paint()
        ..color = const Color(0xFF8B5A2B)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    // alas (dos triángulos)
    final alaColor = m.enEstadoAvatar ? const Color(0xFFBFF6FF) : const Color(0xFFE2512C);
    final ala = Path()
      ..moveTo(-14, 2)
      ..lineTo(10, -16)
      ..lineTo(18, 2)
      ..close();
    canvas.drawPath(ala, Paint()..color = alaColor);
    final ala2 = Path()
      ..moveTo(-20, 2)
      ..lineTo(-4, -10)
      ..lineTo(4, 2)
      ..close();
    canvas.drawPath(ala2, Paint()..color = const Color(0xFFF3A93B));
    // punta
    canvas.drawCircle(const Offset(25, 4), 3.5, Paint()..color = const Color(0xFFF3D36B));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Pintor oldDelegate) => true; // el mundo cambia en cada frame
}

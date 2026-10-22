// ============================================================================
// main.dart  —  PUNTO DE ENTRADA de la app
// ----------------------------------------------------------------------------
// Toda app de Flutter empieza en la función main(). Aquí:
//   1) arrancamos la app (runApp),
//   2) definimos el tema visual (colores, tipografía),
//   3) armamos el "esqueleto" con la barra de navegación inferior que
//      permite moverse entre las 6 vistas que pide la tarea.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/acerca_screen.dart';
import 'screens/contratame_screen.dart';
import 'screens/juego_screen.dart';
import 'screens/momentos_screen.dart';
import 'screens/personajes_screen.dart';
import 'screens/portada_screen.dart';

void main() {
  // Pone la barra de estado del teléfono transparente para que el diseño
  // ocupe toda la pantalla.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
  );
  runApp(const AvatarApp());
}

/// Colores base de la app (paleta inspirada en pergamino + cielo nocturno).
class AppColors {
  static const fondo = Color(0xFF0F1626); // azul noche
  static const superficie = Color(0xFF1A2338);
  static const pergamino = Color(0xFFF4E4C1);
  static const acento = Color(0xFFF3A93B); // naranja aire
}

/// Widget raíz. Es "Stateless" (sin estado) porque solo configura la app.
class AvatarApp extends StatelessWidget {
  const AvatarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avatar: La Leyenda de Aang',
      debugShowCheckedModeBanner: false, // quita la etiqueta "DEBUG"
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.acento,
          brightness: Brightness.dark,
          surface: AppColors.superficie,
        ),
        scaffoldBackgroundColor: AppColors.fondo,
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.fondo, centerTitle: true, elevation: 0),
      ),
      home: const MenuPrincipal(),
    );
  }
}

/// Esqueleto con barra de navegación inferior.
/// Es "Stateful" porque RECUERDA qué pestaña está seleccionada (_indice).
class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  int _indice = 0; // 0 = Portada

  /// Cambia de pestaña. setState() le avisa a Flutter que redibuje.
  void _irA(int i) => setState(() => _indice = i);

  @override
  Widget build(BuildContext context) {
    // Lista de pantallas. La posición en la lista = posición en la barra.
    // Solo se construye la pantalla visible: así el juego y los videos se
    // detienen al cambiar de pestaña (no gastan batería en segundo plano).
    final pantallas = <Widget>[
      PortadaScreen(alComenzar: () => _irA(1)),
      const PersonajesScreen(),
      const MomentosScreen(),
      const JuegoScreen(),
      const AcercaScreen(),
      const ContratameScreen(),
    ];

    return Scaffold(
      // AnimatedSwitcher hace una transición suave (fundido) al cambiar.
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(key: ValueKey(_indice), child: pantallas[_indice]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: _irA,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        backgroundColor: AppColors.superficie,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Portada',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Personajes',
          ),
          NavigationDestination(icon: Icon(Icons.movie_outlined), selectedIcon: Icon(Icons.movie), label: 'Momentos'),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Juega',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Acerca',
          ),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Contrátame'),
        ],
      ),
    );
  }
}

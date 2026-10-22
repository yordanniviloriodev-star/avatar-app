// ============================================================================
// avatar_data.dart
// ----------------------------------------------------------------------------
// Aquí viven los DATOS de la app (modelo + información), separados de las
// pantallas. Así, si quieres cambiar un texto o agregar un personaje, solo
// tocas este archivo y las pantallas se actualizan solas.
// ============================================================================

import 'package:flutter/material.dart';

/// Los cuatro elementos del mundo de Avatar.
/// Un "enum" es una lista cerrada de valores posibles.
enum Elemento { agua, tierra, fuego, aire, ninguno }

/// "extension" agrega propiedades a un tipo que ya existe.
/// Así podemos escribir `Elemento.fuego.color` o `Elemento.fuego.icono`.
extension ElementoInfo on Elemento {
  String get nombre => switch (this) {
    Elemento.agua => 'Agua',
    Elemento.tierra => 'Tierra',
    Elemento.fuego => 'Fuego',
    Elemento.aire => 'Aire',
    Elemento.ninguno => 'No maestro',
  };

  Color get color => switch (this) {
    Elemento.agua => const Color(0xFF2E9BDA),
    Elemento.tierra => const Color(0xFF5DA94A),
    Elemento.fuego => const Color(0xFFE2512C),
    Elemento.aire => const Color(0xFFF3A93B),
    Elemento.ninguno => const Color(0xFF8C7BB5),
  };

  IconData get icono => switch (this) {
    Elemento.agua => Icons.water_drop,
    Elemento.tierra => Icons.landscape,
    Elemento.fuego => Icons.local_fire_department,
    Elemento.aire => Icons.air,
    Elemento.ninguno => Icons.lightbulb,
  };
}

/// MODELO de un personaje: describe qué datos tiene cada personaje.
/// Es como el "molde"; cada personaje real es un objeto creado con este molde.
class Personaje {
  final String nombre;
  final String titulo; // apodo o rol corto
  final Elemento elemento;
  final String nacion;
  final String edad;
  final String fotoUrl; // foto cargada desde internet
  final String descripcion;
  final List<String> habilidades;
  final String dato; // dato curioso

  const Personaje({
    required this.nombre,
    required this.titulo,
    required this.elemento,
    required this.nacion,
    required this.edad,
    required this.fotoUrl,
    required this.descripcion,
    required this.habilidades,
    required this.dato,
  });
}

/// MODELO de un momento favorito.
class Momento {
  final String titulo;
  final String episodio;
  final String youtubeId; // id del video oficial en YouTube
  final String resumen; // texto corto para la tarjeta
  final String detalle; // texto largo para la pantalla de detalle
  final String porQueMeGusta;
  final Elemento elemento;

  const Momento({
    required this.titulo,
    required this.episodio,
    required this.youtubeId,
    required this.resumen,
    required this.detalle,
    required this.porQueMeGusta,
    required this.elemento,
  });

  /// Miniatura oficial del video: YouTube la genera para cada id.
  String get miniaturaUrl => 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
}

// ---------------------------------------------------------------------------
// LISTA DE PERSONAJES (la tarea pide mínimo 3; aquí hay 6)
// Las fotos vienen de la wiki de Avatar, tal como las entrega la API pública
// "The Last Airbender API" (last-airbender-api.fly.dev).
// ---------------------------------------------------------------------------
const List<Personaje> personajes = [
  Personaje(
    nombre: 'Aang',
    titulo: 'El último maestro aire',
    elemento: Elemento.aire,
    nacion: 'Nómadas del Aire',
    edad: '12 años (¡112 si cuentas los 100 que pasó congelado!)',
    fotoUrl: 'https://vignette.wikia.nocookie.net/avatar/images/a/ae/Aang_at_Jasmine_Dragon.png/revision/latest?cb=20130612174003',
    descripcion:
        'Aang es el Avatar, la única persona capaz de dominar los cuatro elementos. '
        'Huyó de su hogar, quedó atrapado en un iceberg durante 100 años y al despertar '
        'descubrió que la Nación del Fuego había iniciado una guerra contra el mundo. '
        'Alegre, bromista y pacifista, debe aprender agua, tierra y fuego antes de que '
        'llegue el Cometa de Sozin.',
    habilidades: ['Aire control', 'Agua, tierra y fuego control', 'Estado Avatar', 'Energía control'],
    dato: 'Viaja en Appa, un bisonte volador, y lo acompaña Momo, un lémur alado.',
  ),
  Personaje(
    nombre: 'Katara',
    titulo: 'Maestra agua del Polo Sur',
    elemento: Elemento.agua,
    nacion: 'Tribu Agua del Sur',
    edad: '14 años',
    fotoUrl: 'https://vignette.wikia.nocookie.net/avatar/images/7/7a/Katara_smiles_at_coronation.png/revision/latest?cb=20150104171449',
    descripcion:
        'Katara fue quien encontró a Aang dentro del iceberg. Era la última maestra agua '
        'de su tribu y aprendió casi sola hasta convertirse en una maestra poderosa. '
        'Es el corazón del grupo: protectora, valiente y con un gran sentido de la justicia.',
    habilidades: ['Agua control', 'Sanación', 'Sangre control', 'Combate con hielo'],
    dato: 'Fue la maestra de agua control de Aang durante el viaje.',
  ),
  Personaje(
    nombre: 'Sokka',
    titulo: 'El estratega del equipo',
    elemento: Elemento.ninguno,
    nacion: 'Tribu Agua del Sur',
    edad: '15 años',
    fotoUrl: 'https://vignette.wikia.nocookie.net/avatar/images/c/cc/Sokka.png/revision/latest?cb=20140905085428',
    descripcion:
        'Hermano mayor de Katara. No controla ningún elemento, pero compensa con ingenio, '
        'planes, inventos y mucho humor. Es quien organiza al grupo y diseña la estrategia '
        'de la invasión a la Nación del Fuego.',
    habilidades: ['Estrategia', 'Bumerán', 'Espada de meteorito', 'Inventos'],
    dato: 'Forjó su espada con un meteorito, bajo la guía del maestro Piandao.',
  ),
  Personaje(
    nombre: 'Toph Beifong',
    titulo: 'La mejor maestra tierra del mundo',
    elemento: Elemento.tierra,
    nacion: 'Reino Tierra',
    edad: '12 años',
    fotoUrl:
        'https://vignette.wikia.nocookie.net/avatar/images/4/46/Toph_Beifong.png/revision/latest?cb=20131230122047',
    descripcion:
        'Toph es ciega de nacimiento, pero "ve" sintiendo las vibraciones del suelo con sus pies. '
        'Hija de una familia rica que la sobreprotegía, escapó para enseñarle tierra control a Aang. '
        'Directa, ruda y muy segura de sí misma.',
    habilidades: ['Tierra control', 'Metal control (lo inventó)', 'Percepción sísmica'],
    dato: 'Fue la primera persona en la historia en controlar el metal.',
  ),
  Personaje(
    nombre: 'Zuko',
    titulo: 'El príncipe desterrado',
    elemento: Elemento.fuego,
    nacion: 'Nación del Fuego',
    edad: '16 años',
    fotoUrl: 'https://vignette.wikia.nocookie.net/avatar/images/4/4b/Zuko.png/revision/latest?cb=20180630112142',
    descripcion:
        'Hijo del Señor del Fuego Ozai, fue desterrado y marcado con una cicatriz. Su misión: '
        'capturar al Avatar para recuperar su honor. Su historia es una de las mejores '
        'redenciones de la televisión: termina uniéndose al equipo y enseñándole fuego control a Aang.',
    habilidades: ['Fuego control', 'Espadas dao dobles', 'Redirección del rayo'],
    dato: 'Al final de la serie se convierte en el nuevo Señor del Fuego.',
  ),
  Personaje(
    nombre: 'Iroh',
    titulo: 'El Dragón del Oeste',
    elemento: Elemento.fuego,
    nacion: 'Nación del Fuego',
    edad: 'Alrededor de 60 años',
    fotoUrl:
        'https://vignette.wikia.nocookie.net/avatar/images/c/c1/Iroh_smiling.png/revision/latest?cb=20130626131914',
    descripcion:
        'Tío de Zuko y antiguo gran general de la Nación del Fuego. Tras perder a su hijo, '
        'eligió un camino de sabiduría, paz y té. Acompaña a Zuko en su destierro y es su '
        'verdadera figura paterna.',
    habilidades: ['Fuego control', 'Redirección del rayo', 'Aliento de fuego', 'Sabiduría'],
    dato: 'Es miembro de la Orden del Loto Blanco y ama el té de jazmín.',
  ),
];

// ---------------------------------------------------------------------------
// MIS 3 MOMENTOS FAVORITOS (videos oficiales del canal "Avatar: The Last
// Airbender", en español, que permiten reproducirse dentro de otras apps).
// ---------------------------------------------------------------------------
const List<Momento> momentos = [
  Momento(
    titulo: 'Aang contra el Señor del Fuego Ozai',
    episodio: 'Libro 3: Fuego · Episodio 21 "Avatar Aang"',
    youtubeId: 'Lw68Ntocp-Y',
    resumen: 'La batalla final bajo el Cometa de Sozin.',
    detalle:
        'Con el poder del Cometa de Sozin, Ozai intenta destruir el Reino Tierra. Aang lo enfrenta, '
        'entra al Estado Avatar y controla los cuatro elementos a la vez. Al final, en lugar de quitarle '
        'la vida, le quita su fuego control usando la energía control, fiel a sus creencias.',
    porQueMeGusta:
        'Es la culminación de tres temporadas: Aang gana sin traicionar quién es. '
        'Demuestra que la fuerza más grande es mantener tus principios.',
    elemento: Elemento.aire,
  ),
  Momento(
    titulo: 'Zuko se disculpa con Iroh',
    episodio: 'Libro 3: Fuego · Episodio 19 "Los Viejos Maestros"',
    youtubeId: 'JSUr-zmW7N8',
    resumen: 'El reencuentro más emotivo de la serie.',
    detalle:
        'Después de traicionarlo en Ba Sing Se, Zuko busca a su tío Iroh en el campamento de la Orden '
        'del Loto Blanco. Llega con miedo y vergüenza, preparado para pedir perdón… y la reacción de Iroh '
        'cierra el arco de redención de Zuko.',
    porQueMeGusta:
        'Muestra que equivocarse no te define: lo que importa es reconocerlo y cambiar. '
        'Iroh es el mejor mentor de la animación.',
    elemento: Elemento.fuego,
  ),
  Momento(
    titulo: 'Toph inventa el metal control',
    episodio: 'Libro 2: Tierra · Episodio 19 "El Gurú"',
    youtubeId: 'dEnlopsh5is',
    resumen: 'Encerrada en una caja de metal, Toph hace lo imposible.',
    detalle:
        'Unos cazarrecompensas atrapan a Toph en una caja de metal porque "nadie puede controlar el metal". '
        'Concentrándose en las pequeñas partículas de tierra dentro del metal, Toph logra doblarlo y escapa, '
        'creando una disciplina completamente nueva.',
    porQueMeGusta:
        'Es la prueba de que los límites que te ponen los demás no son reales. '
        'Toph convierte su supuesta debilidad en su mayor fortaleza.',
    elemento: Elemento.tierra,
  ),
];

// ---------------------------------------------------------------------------
// DATOS DEL DESARROLLADOR (vista Contrátame)
// ---------------------------------------------------------------------------
class Desarrollador {
  static const nombre = 'Yordanni Vilorio Jiminian';
  static const rol = 'Desarrollador de Software · Estudiante del ITLA';
  static const matricula = '2019-7711';
  static const correo = 'yordanni.vilorio.dev@gmail.com';
  static const whatsappVisible = '829-264-2947';
  static const whatsappLink = 'https://wa.me/18292642947'; // 1 = código de país de RD
  static const github = 'yordanniviloriodev-star';
  static const githubLink = 'https://github.com/yordanniviloriodev-star';
  static const foto = 'assets/images/yo.jpg';
  static const habilidades = ['Flutter', 'Dart', 'C#', 'ASP.NET Core', 'SQL Server', 'React', 'Git / GitHub', 'CI/CD'];
}

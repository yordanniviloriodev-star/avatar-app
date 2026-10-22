# Avatar: La Leyenda de Aang — App móvil (Tarea 5)

App en **Flutter** dedicada a *Avatar: La Leyenda de Aang*, hecha para la Tarea 5 de
Introducción al Desarrollo de Aplicaciones Móviles (ITLA).

**Autor:** Yordanni Vilorio Jiminian · Matrícula 2019-7711

## Vistas
| Vista | Qué hace |
|---|---|
| Portada | Slider automático de los 4 elementos con partículas animadas |
| Personajes | 6 personajes; al tocar uno se ve su foto y detalles |
| Momentos | 3 momentos favoritos; al tocar uno se ve el detalle y el video **dentro de la app** |
| Juega | "El Vuelo del Planeador": juego tipo arcade con Estado Avatar |
| Acerca | Temporadas, episodios, creadores y más |
| Contrátame | Foto y contacto (WhatsApp, correo, GitHub) |

## Descargar el APK
https://github.com/yordanniviloriodev-star/avatar-app/releases/latest/download/avatar-app.apk

## Compilar en tu PC
```bash
flutter create --platforms=android --org com.yordanni --project-name avatar_app .
python tool/patch_android.py      # agrega permiso de internet y nombre de la app
flutter pub get
flutter run                       # probar en emulador / teléfono
flutter build apk --release       # genera build/app/outputs/flutter-apk/app-release.apk
```

## Estructura
```
lib/
  main.dart                  # arranque, tema y barra de navegación
  data/avatar_data.dart      # modelos y datos (personajes, momentos, contacto)
  widgets/foto_red.dart      # imagen de internet con carga y respaldo
  screens/                   # una pantalla por vista
assets/images/yo.jpg         # foto del desarrollador
tool/patch_android.py        # ajusta el AndroidManifest
.github/workflows/build-apk.yml  # compila y publica el APK automáticamente
```

Videos: canal oficial "Avatar: The Last Airbender" en YouTube. Fotos de personajes: wiki de Avatar
vía The Last Airbender API. Avatar: The Last Airbender © Nickelodeon / Paramount. Proyecto educativo sin fines de lucro.

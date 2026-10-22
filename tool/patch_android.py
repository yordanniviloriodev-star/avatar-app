"""
patch_android.py
----------------
Ajusta el AndroidManifest.xml que genera `flutter create` para esta app:

  1. Permiso de INTERNET: sin él, en el APK de release no cargan las fotos
     de los personajes ni los videos.
  2. <queries> para abrir enlaces https y mailto (Android 11+ exige declarar
     a qué tipo de apps externas vamos a llamar; lo usa la vista Contrátame).
  3. Nombre visible de la app en el teléfono: "Avatar Aang".

Se usa en GitHub Actions (y también puedes correrlo tú: python tool/patch_android.py).
"""
import re
from pathlib import Path

ruta = Path("android/app/src/main/AndroidManifest.xml")
xml = ruta.read_text(encoding="utf-8")

# 1) Permiso de internet justo después de la etiqueta <manifest ...>
if "android.permission.INTERNET" not in xml:
    xml = re.sub(
        r"(<manifest[^>]*>)",
        r'\1\n    <uses-permission android:name="android.permission.INTERNET"/>',
        xml,
        count=1,
    )

# 2) Intents para abrir enlaces web y correo
intents = """
        <intent>
            <action android:name="android.intent.action.VIEW"/>
            <data android:scheme="https"/>
        </intent>
        <intent>
            <action android:name="android.intent.action.SENDTO"/>
            <data android:scheme="mailto"/>
        </intent>"""
if 'android:scheme="https"' not in xml:
    if "<queries>" in xml:
        xml = xml.replace("<queries>", "<queries>" + intents, 1)
    else:
        xml = xml.replace("</manifest>", "    <queries>" + intents + "\n    </queries>\n</manifest>", 1)

# 3) Nombre visible de la app
xml = re.sub(r'android:label="[^"]*"', 'android:label="Avatar Aang"', xml, count=1)

ruta.write_text(xml, encoding="utf-8")
print("AndroidManifest.xml actualizado:\n")
print(xml)

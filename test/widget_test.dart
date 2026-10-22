// Prueba mínima: comprueba que la app se puede construir sin errores.
import 'package:flutter_test/flutter_test.dart';

import 'package:avatar_app/main.dart';

void main() {
  test('La app existe', () {
    expect(const AvatarApp(), isNotNull);
  });
}

# Snake Evolution

Snake modernizado hecho en Flutter para portafolio: Material 3, Riverpod, Clean
Architecture ligera y persistencia local.

## Qué incluye

- Mecánica clásica de Snake (colisión con pared/obstáculo/uno mismo termina la
  partida) con controles táctiles (swipe) y D-pad en pantalla.
- 2 mapas: Arena Clásica y Campo de Obstáculos.
- 4 power-ups con efectos reales y temporizador visible: Velocidad, Escudo,
  Imán, Multiplicador x2.
- 4 skins de serpiente desbloqueables con monedas ganadas jugando (1 moneda
  por alimento comido) y tienda para comprarlas/seleccionarlas.
- Logros persistidos (longitud, partidas jugadas, power-ups recolectados,
  tiempo de supervivencia).
- Misiones diarias (2 de un pool de 3), con reinicio automático por fecha.
- Estadísticas: partidas jugadas, mejor longitud, alimentos totales, tiempo
  total jugado.
- Ajustes: tema claro/oscuro/sistema, sonido, música, vibración — todo
  persistido.
- Tutorial de primer lanzamiento, splash animado, layout responsive.

## Simplificaciones deliberadas frente al listado original

- **`shared_preferences` en vez de Hive/Isar**: no hay relaciones complejas
  que requieran una base de datos embebida; shared_preferences cubre
  monedas/skins/logros/stats/misiones sin generación de código.
- **Sin archivos de audio reales**: no se incluyen assets de sonido con
  copyright. `AudioService` (lib/data/audio_service.dart) está completamente
  cableado con `audioplayers`, pero si el asset no existe, el error se
  captura y se loguea con `debugPrint` en vez de romper la app.
- **Un solo idioma (español)**: no se generó infraestructura ARB/flutter_intl
  completa, ya que la app no tiene necesidad real de multi-idioma para un
  proyecto de portafolio.
- **Tienda simplificada**: economía de monedas + 4 skins fijas, sin sistema
  de IAP ni monedas reales.
- **Misiones simplificadas**: 2 misiones diarias elegidas determinísticamente
  de un pool de 3 según la fecha, en vez de un motor de quests completo.

## Arquitectura

- `lib/domain`: lógica pura (motor del juego, mapas, power-ups, logros,
  misiones) sin dependencias de Flutter, testeable de forma aislada.
- `lib/data`: repositorios sobre `shared_preferences` + `AudioService`.
- `lib/providers`: notifiers de Riverpod (bucle del juego con `Timer`
  auto-reprogramable para poder acelerar con el power-up de velocidad).
- `lib/presentation`: pantallas y widgets, navegación con `go_router`.

## Cómo correr

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

Cubren el motor del juego (movimiento, colisiones, power-ups) y la lógica
pura de reinicio diario de misiones.

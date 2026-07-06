# 🧭 Playbook: migración a null safety (Dart 3 / Flutter moderno)

> **Estado actual:** la app compila y es publicable con **Flutter 3.7.x
> (Dart 2.19)** sin null safety. Esta migración es **opcional y para el futuro**
> (necesaria para Flutter 3.16+/Dart 3 y para `targetSdk 35` cuando Google lo
> exija). **No hagas esto sin un entorno donde puedas compilar e iterar** — es un
> cambio todo-o-nada que toca toda la capa de plugins.

## Por qué es todo-o-nada

- Dart 3 **elimina** el modo "unsound null safety": **todos** los archivos `.dart`
  deben estar migrados.
- Las dependencias que hoy están fijadas a versiones viejas **topan en
  `<3.0.0`**, así que en Dart 3 **ninguna resuelve**. Hay que subirlas y, en
  varias, **ajustar el código** por cambios de API.

## Paso 0 — Preparar el entorno

```bash
flutter --version          # usa una versión estable reciente (p.ej. 3.24+)
flutter channel stable
flutter upgrade
```
Requisitos de la cadena Android para Flutter moderno:
- **JDK 17**, **AGP 8.1+**, **Gradle 8.x**, **Kotlin 1.9+**.
- AGP 8 exige `namespace` en `android/app/build.gradle`:
  ```gradle
  android {
      namespace "com.xamarindo.wpstatusaver"
      compileSdkVersion 34
      ...
  }
  ```
- `android/build.gradle`: `com.android.tools.build:gradle:8.1.4`, kotlin `1.9.22`.
- `gradle-wrapper.properties`: `gradle-8.5-bin.zip`.

## Paso 1 — Subir dependencias (pubspec.yaml)

Matriz de versiones y **qué código cambia** cada una:

| Paquete | Ahora | Dart 3 | ¿Cambio de código? |
|---------|-------|--------|--------------------|
| `environment sdk` | `>=2.1.0 <3.0.0` | `>=3.0.0 <4.0.0` | — |
| `google_mobile_ads` | `^0.13.6` | `^5.1.0` | Bajo. La API de carga estática (`InterstitialAd.load`, `BannerAd`, `RewardedAd.load`, `MobileAds.instance.initialize`) es la misma. |
| `in_app_purchase` | `^1.0.9` | `^3.1.11` | Bajo. Mismo `InAppPurchase.instance`, `queryProductDetails`, `buyNonConsumable`, `purchaseStream`. |
| `in_app_purchase_android` | `^0.1.6` | `^0.3.0` | Bajo. `enablePendingPurchases()` sigue igual. |
| `image` | `^3.3.0` | `^4.1.0` | **Medio.** v4 cambia el acceso a píxeles. Ver Paso 3. |
| `http` | `^0.13.6` | `^1.2.0` | Bajo. |
| `share_plus` | `^4.5.3` | `^7.2.2` | **Medio.** `shareFiles` → `shareXFiles([XFile(path)])`. Ver Paso 3. |
| `receive_sharing_intent` | `1.4.5` | `^1.8.0` | **Medio.** API nueva basada en `SharedMediaFile`. Ver Paso 3. |
| `permission_handler` | `^8.1.1` | `^11.3.1` | Bajo (mismos `Permission.storage`, etc.). |
| `path_provider` | `^2.0.2` | `^2.1.2` | — |
| `shared_preferences` | `^2.0.6` | `^2.2.2` | — |
| `url_launcher` | `^6.0.7` | `^6.2.5` | — |
| `video_thumbnail` | `^0.3.3` | `^0.5.3` | Bajo. |
| `chewie` | `^1.2.2` | `^1.7.5` | Bajo. |
| `scoped_model` | `^1.1.0` | `^2.0.0` | Bajo. |
| `fluttertoast` | `^8.0.7` | `^8.2.4` | — |
| `file_picker` | `^3.0.3` | `^6.1.1` | Bajo. |
| `font_awesome_flutter` | `^9.1.0` | `^10.7.0` | Bajo (revisar nombres de íconos; `FaIcon` igual). |
| `version` | `^2.0.0` | `^3.0.2` | — |

## Paso 2 — Migrar el código Dart a null safety

Usa la herramienta oficial (analiza y propone los `?`/`required`/`late`):

```bash
cd src/status_saver
dart pub get
dart migrate
```
`dart migrate` levanta una web local para revisar/ajustar cada archivo. Patrones
que verás en este proyecto (~28 archivos en `lib/`):

- `@required` (anotación) → palabra clave `required`.
- Campos asignados en `initState`/`build` (`AppLocalizations _i18n;`,
  `List _imageList;`, `Future _thumbnail;`) → hacerlos anulables (`?`) o `late`.
- `Timer _timer;` → `Timer? _timer;` (ya se checa `!= null`).
- `StreamSubscription _sub;` → `StreamSubscription? _sub;`.
- Parámetros opcionales de widgets (`Key key`, callbacks `VoidCallback onSave`)
  → `Key? key`, `VoidCallback? onSave` (ya hay checks de null que ayudan).
- Getters que pueden devolver null (`getString`, `getBool`) ya usan `??`, quedan
  bien.

> Si `dart migrate` falla por un paquete aún no migrado, primero completa el
> Paso 1 (todas las deps deben ser null-safe).

## Paso 3 — Ajustes de API por paquete

### `share_plus` 7.x (`lib/app/app.dart`, `status_card.dart`, `view_status_screen.dart`)
```dart
// Antes:
Share.shareFiles([path]);
// Ahora:
Share.shareXFiles([XFile(path)]);
// (Share.share(String) para texto no cambia)
```

### `image` 4.x (`lib/app/app.dart`, `_fadeImage`)
v4 usa la API de píxeles nueva. Reemplaza `_fadeImage`:
```dart
img.Image _fadeImage(img.Image src, double opacity) {
  for (final p in src) {            // itera Pixel en v4
    p.a = (p.a * opacity).round();  // canal alfa directo
  }
  return src;
}
```
`decodeImage`, `decodePng`, `copyResize`, `copyInto` (con `dstX/dstY/blend`),
`encodePng`, `encodeJpg` siguen existiendo en v4 (revisa firmas menores).

### `receive_sharing_intent` 1.8.x (`lib/screens/start_screen.dart`)
API nueva basada en `SharedMediaFile`:
```dart
// Cold start:
ReceiveSharingIntent.instance.getInitialMedia().then((list) {
  for (final f in list) {
    if (f.type == SharedMediaType.text || f.type == SharedMediaType.url) {
      _openSharedLink(f.path);
    }
  }
  ReceiveSharingIntent.instance.reset();
});
// App abierta:
_intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((list) {
  for (final f in list) {
    if (f.type == SharedMediaType.text || f.type == SharedMediaType.url) {
      _openSharedLink(f.path);
    }
  }
});
```
(El intent-filter `SEND text/*` del manifest no cambia.)

## Paso 4 — Verificar (imprescindible)

```bash
flutter clean
flutter pub get
flutter analyze          # 0 errores antes de seguir
flutter run              # probar en dispositivo/emulador
flutter build appbundle --release
```
Prueba manualmente: guardar foto/video, compartir, descargar por enlace,
compartir un link hacia la app, banner/intersticial, y el flujo de compra con
una cuenta *license tester*.

## Recomendación

Hazlo en una **rama dedicada** con PR (no directo a `master`), porque necesita el
ciclo de `flutter analyze`/`flutter run` para validarse. Cuando tengas un entorno
con Flutter, puedo ejecutar esta migración e ir corrigiendo los errores del
analizador uno por uno hasta dejar `flutter analyze` en verde.

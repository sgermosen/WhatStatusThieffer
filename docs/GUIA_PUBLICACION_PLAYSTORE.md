# 📱 Guía completa de publicación en Google Play — Social Status Saver

> Documento maestro para publicar la app en Google Play Store, con las
> **compras dentro de la app (suscripciones)** y la **publicidad (AdMob)**.
> Incluye textos de la ficha, especificaciones de las imágenes, capturas de uso,
> y lo que hay que configurar en Play Console y AdMob. **El código de anuncios
> y compras ya está implementado**; lo que falta es configuración en la web.

**Datos técnicos del proyecto (reales, tomados del código):**

| Dato | Valor |
|------|-------|
| Nombre visible actual | `Social Status Saver` (constante `APP_NAME`) |
| Application ID (package) | `com.xamarindo.wpstatusaver` |
| versionCode / versionName | `8` / `1.0.8` — se toman de `version:` en `pubspec.yaml` |
| minSdk / targetSdk / compileSdk | `24` / `36` / `37` (Play exige targetSdk 35+) |
| Flutter / Dart | **3.47.x** (stable) / Dart 3.13 — código con null safety |
| Toolchain Android | AGP 9.1 · Gradle 9.3 · Kotlin 2.4 · **JDK 17+** (plantilla oficial de Flutter) |
| AdMob App ID | `ca-app-pub-8521044456540023~3652646925` |
| Firma release | vía `android/key.properties` + `signingConfigs.release` |

---

## Índice

1. [Checklist previo](#1-checklist-previo)
2. [Ficha de Play Store — textos](#2-ficha-de-play-store--textos)
3. [Recursos gráficos e imágenes de uso](#3-recursos-gráficos-e-imágenes-de-uso)
4. [Clasificación, público y seguridad de datos](#4-clasificación-público-y-seguridad-de-datos)
5. [Compras dentro de la app (suscripciones)](#5-compras-dentro-de-la-app-suscripciones)
6. [Publicidad con AdMob](#6-publicidad-con-admob)
7. [Firma, compilación y subida (paso a paso)](#7-firma-compilación-y-subida-paso-a-paso)
8. [Cumplimiento legal — LEER ANTES DE PUBLICAR](#8-cumplimiento-legal--leer-antes-de-publicar)
9. [Post-lanzamiento](#9-post-lanzamiento)

---

## 1. Checklist previo

- [ ] Cuenta de **Google Play Console** (pago único de USD 25).
- [ ] Cuenta de **AdMob** (gratis) vinculada a la misma cuenta de Google.
- [ ] **Keystore** de firma creado y guardado en un lugar seguro (§7).
- [ ] `applicationId` definitivo. ⚠️ **No se puede cambiar** una vez publicado.
      El actual es `com.xamarindo.wpstatusaver`.
- [x] `targetSdk` **36** (Play exige 35+ desde ago-2025). Ya configurado.
- [ ] Política de privacidad publicada en una URL pública (ya existe
      `privacy_policy.html` en el repo; súbela a un hosting y usa esa URL).
- [ ] Decidir el modelo de monetización (ver §5 y §6): suscripciones para quitar
      anuncios + anuncios AdMob para usuarios gratuitos.
- [ ] Leer la §8 (cumplimiento) — es lo que más rechazos causa en este tipo de app.

---

## 2. Ficha de Play Store — textos

Copia y pega. Hay versión **español** e **inglés** (crea ambos idiomas en la
ficha para más alcance).

### 2.1 Nombre de la app (máx. 30 caracteres)

```
Social Status Saver
```
Alternativas ASO (elige una): `Status Saver & Descargas`, `Guardar Estados y Reels`.

> ⚠️ Evita usar marcas ("WhatsApp", "Instagram", "TikTok") en el **nombre** de la
> app: Google lo rechaza por infracción de marca. Puedes mencionarlas en la
> descripción como "compatible con…".

### 2.2 Descripción corta (máx. 80 caracteres)

**ES:**
```
Guarda y descarga fotos y videos que ves o que compartes por enlace.
```
**EN:**
```
Save & download the photos and videos you view or share by link.
```

### 2.3 Descripción completa (máx. 4000 caracteres)

**ES:**
```
Social Status Saver es la forma más fácil de guardar en tu teléfono las fotos y
videos que ya viste, sin tener que pedir que te los reenvíen.

⭐ ¿QUÉ HACE?
• Guarda los estados que ves en tus apps de mensajería (imágenes y videos).
• Explora el contenido que descargas o guardas desde tus redes sociales
  favoritas y vuelve a guardarlo en tu galería con un toque.
• Descarga desde un enlace: pega o comparte un link público y la app guarda su
  foto o video directamente en tu dispositivo.
• Compatible con WhatsApp, WhatsApp Business y con las carpetas públicas de
  Instagram, Facebook y TikTok.

📥 FÁCIL DE USAR
1. Abre tu app y mira el estado o guarda el contenido que te interesa.
2. Abre Social Status Saver y verás las fotos y videos disponibles.
3. Toca "Guardar" y listo: queda para siempre en tu galería.

🔗 DESCARGAR POR ENLACE
¿Viste un video que te encantó? Compártelo hacia Social Status Saver (o pega el
link) y lo descargamos por ti. Funciona con enlaces públicos.

✨ CARACTERÍSTICAS
• Interfaz simple y rápida.
• Pestañas separadas de imágenes, videos y descargas guardadas.
• Modo oscuro.
• Comparte cualquier archivo guardado con tus amigos.
• Sin marca de agua.

🔒 PRIVACIDAD
La app solo lee las carpetas públicas de medios de tu dispositivo. No pedimos tu
usuario ni contraseña de ninguna red social.

⚠️ IMPORTANTE
Descarga únicamente contenido que sea tuyo o para el que tengas permiso. Respeta
los derechos de autor y los términos de servicio de cada plataforma. Esta app no
está afiliada, patrocinada ni respaldada por WhatsApp, Meta, Instagram, Facebook
ni TikTok. Todas las marcas pertenecen a sus respectivos dueños.
```

**EN:**
```
Social Status Saver is the easiest way to save to your phone the photos and
videos you already watched, without asking anyone to resend them.

⭐ WHAT IT DOES
• Save the statuses you view in your messaging apps (images and videos).
• Browse the content you download or save from your favorite social apps and
  re-save it to your gallery with one tap.
• Download from a link: paste or share a public link and the app saves its photo
  or video straight to your device.
• Works with WhatsApp, WhatsApp Business and the public folders of Instagram,
  Facebook and TikTok.

📥 EASY TO USE
1. Open your app and watch the status / save the content you like.
2. Open Social Status Saver and see the available photos and videos.
3. Tap "Save" — it's kept in your gallery forever.

🔗 DOWNLOAD BY LINK
Share a link into Social Status Saver (or paste it) and we download it for you.
Works with public links.

✨ FEATURES
• Simple, fast interface.
• Separate tabs for images, videos and saved downloads.
• Dark mode.
• Share any saved file with your friends.
• No watermark.

🔒 PRIVACY
The app only reads the public media folders on your device. We never ask for your
social media username or password.

⚠️ IMPORTANT
Only download content you own or have permission to use. Respect copyright and
each platform's Terms of Service. This app is not affiliated with, sponsored or
endorsed by WhatsApp, Meta, Instagram, Facebook or TikTok. All trademarks belong
to their respective owners.
```

### 2.4 Otros campos

| Campo | Valor sugerido |
|-------|----------------|
| Categoría | `Herramientas` (Tools) |
| Etiquetas | status saver, downloader, video downloader |
| Correo de contacto | sgrysoft@gmail.com |
| Sitio web | (opcional) tu página o el repo |
| Política de privacidad | URL pública de `privacy_policy.html` |

---

## 3. Recursos gráficos e imágenes de uso

Todos los recursos **obligatorios** de la ficha, con medidas exactas de Google.
En `docs/store_assets/` de este repo dejé **mockups en SVG** de cada pantalla que
puedes usar como base o guía de diseño. Google exige PNG/JPG, así que expórtalos
a PNG en la resolución indicada (con Inkscape, Figma, o cualquier editor).

### 3.1 Requisitos oficiales

| Recurso | Medida | Formato | Obligatorio |
|---------|--------|---------|-------------|
| **Ícono de la app** | 512 × 512 px | PNG 32-bit | ✅ Sí |
| **Gráfico de funciones** (feature graphic) | 1024 × 500 px | PNG/JPG | ✅ Sí |
| **Capturas de teléfono** | mín. 320 px lado corto; recom. **1080 × 1920** | PNG/JPG | ✅ Sí (mín. 2, máx. 8) |
| Capturas de tablet 7" | recom. 1200 × 1920 | PNG/JPG | Opcional |
| Capturas de tablet 10" | recom. 1600 × 2560 | PNG/JPG | Opcional |
| Video promocional | enlace de YouTube | — | Opcional |

### 3.2 Ícono

Ya tienes el logo base en el repo: `logoBase.png`, `logoBase-croped.png`,
`src/status_saver/assets/images/app_logo.png`. Genera el ícono 512×512 a partir
de `app_logo.png` (fondo teal o transparente sobre teal). Recomendado: usar
`flutter_launcher_icons` (ya está en el `pubspec.yaml`) para los íconos internos,
y exportar aparte el 512×512 para la ficha.

### 3.3 Plan de capturas de uso (las "imágenes del uso del app")

Diseñé **5 mockups** en `docs/store_assets/` que representan las pantallas reales
del app. Cada uno lleva un **texto de marketing** (overlay) recomendado. Para las
capturas definitivas, lo ideal es tomar **capturas reales en el dispositivo**
(`flutter run` → botón de captura del emulador o del teléfono) y superponer esos
textos con Figma/Canva. Orden sugerido en la ficha:

| # | Pantalla real | Archivo mockup | Texto overlay (ES) |
|---|---------------|----------------|--------------------|
| 1 | Pantalla de inicio / selector de plataformas | `screenshot_01_home.svg` | "Todas tus redes en un solo lugar" |
| 2 | Pestaña de Imágenes/Videos (grid) | `screenshot_02_grid.svg` | "Guarda fotos y videos con un toque" |
| 3 | Pestaña Guardados | `screenshot_03_saved.svg` | "Tus descargas siempre a la mano" |
| 4 | Descargar desde un enlace | `screenshot_04_download_link.svg` | "Pega un link y descárgalo al instante" |
| 5 | Compartir hacia la app | `screenshot_05_share.svg` | "Comparte y guarda sin salir de tus apps" |

Feature graphic: `feature_graphic.svg` (1024×500).

**Cómo capturar en dispositivo real:**
```bash
# Con el teléfono conectado por USB (depuración activada) o un emulador:
flutter run --release
# Navega a la pantalla y toma la captura:
adb exec-out screencap -p > screenshot_01.png
```

---

## 4. Clasificación, público y seguridad de datos

En Play Console deberás completar tres formularios:

### 4.1 Cuestionario de clasificación de contenido (IARC)
- Categoría de la app: **Utilidad / Productividad / Herramientas**.
- Responde honestamente: la app no tiene violencia, sexo, etc. → normalmente
  queda como **Para todos / PEGI 3**, salvo que muestres contenido generado por
  usuarios sin moderar (ojo con esto por el contenido descargado).

### 4.2 Público objetivo
- Selecciona rango de edad **18+** o **13+** (recomendado 18+ para downloaders,
  evita la sección "Diseñado para familias").

### 4.3 Seguridad de los datos (Data safety) — **obligatorio**
Declara con precisión. Para esta app:
- **¿Recopilas o compartes datos?** Si solo usas AdMob → sí, se comparte un
  identificador de publicidad. Declara:
  - **Tipo:** ID del dispositivo o de otro tipo → "Identificador de publicidad".
  - **Propósito:** Publicidad o marketing; Analítica.
  - **¿Se puede solicitar la eliminación?** Según configures.
- **Permisos sensibles:** almacenamiento / fotos y videos → explica que es para
  leer y guardar los medios que el usuario elige.
- Marca **cifrado en tránsito** (las descargas van por HTTPS).
- **ID de publicidad:** el SDK de AdMob agrega el permiso
  `com.google.android.gms.permission.AD_ID`. En Play Console →
  *Contenido de la app → ID de publicidad* responde **Sí, la app usa el ID de
  publicidad** con propósito *Publicidad o marketing*. Si respondes que no,
  Play rechaza la versión.
- **Compras:** declara *Información financiera → Historial de compras* solo si
  aplica; las compras las procesa Google Play, la app no guarda datos de pago.

---

## 5. Compras dentro de la app (suscripciones)

El **código de compras ya está implementado** (ver §5.4). Lo que "nunca
funcionó" antes casi siempre se debe a que **los productos no estaban
creados/activos en Play Console**, la app **no estaba subida a un track**
(interno como mínimo), o se probaba con una cuenta que no es **tester de
licencia**. Esta sección cubre esa parte, que es 100% en la web.

### 5.1 IDs que debes crear en Play Console (exactos)

Quitar anuncios (`REMOVE_ADS_SUB_IDS`):
```
ads_1_week, ads_1_month, ads_3_months, ads_6_months, ads_1_year
```
> La función de marca de agua se eliminó, así que **ya no existen** las
> suscripciones `watermark_*`. Puedes crear solo algunas de las `ads_*`
> (por ejemplo `ads_1_month` y `ads_1_year`): la app muestra las que encuentre.

### 5.2 Crear las suscripciones (Play Console)
1. Play Console → tu app → **Monetizar → Productos → Suscripciones**.
2. **Crear suscripción** → *ID del producto* = exactamente uno de los de arriba
   (ej. `ads_1_month`). ⚠️ El ID **no se puede cambiar** después.
3. Añade un **plan base** (base plan) con:
   - Periodo de facturación (semanal, mensual, etc. según el ID).
   - Renovación automática.
   - Precio por país.
4. **Activa** el plan base (estado *Activo*, no borrador).
5. Repite para cada ID que vayas a ofrecer.

### 5.3 Requisitos para que las compras funcionen en pruebas
- La app **firmada** debe estar subida al menos a **Testing interno** con el
  **mismo `applicationId`** y un **versionCode** ≥ al de Console.
- En **Configuración → Testing de licencias**, agrega tu correo de Gmail como
  **License tester** (así compras en modo prueba sin cobro real).
- Instala la app **desde el enlace de Play** (no un APK lateral) con esa cuenta.
- Las suscripciones tardan unos minutos/horas en propagarse tras crearlas.

### 5.4 Cómo está implementado (referencia)

- `lib/services/purchases.dart`: al arrancar la app consulta a Google Play las
  suscripciones **activas** del usuario (`queryPastPurchases`). Si tiene alguna
  `ads_*`, se ocultan los anuncios. Como Play no devuelve suscripciones
  vencidas, **los anuncios vuelven solos cuando la suscripción expira**.
- Escucha el flujo de compras y **confirma (acknowledge)** cada compra. Esto es
  obligatorio: si no se confirma, Google reembolsa la compra a los 3 días.
- `lib/widgets/store_products.dart` + `screens/remove_ads_screen.dart`: lista
  las suscripciones con su precio local y botón *Suscribirse*. Menú lateral →
  *Remover Ads*.
- Si un ID no aparece en la app, revisa el log: imprime
  `Products not found in Play Console: {...}` con los IDs que Play no encontró.

---

## 6. Publicidad con AdMob

El **código de anuncios ya está implementado** con `google_mobile_ads`
(ver §6.2). Los IDs están en `app_constants.dart` y el App ID en el
`AndroidManifest.xml`. Lo que falta es configuración en AdMob:

### 6.1 En AdMob (web)
1. Crea la app en **AdMob → Apps → Add app** (o vincúlala si ya existe con el
   App ID `ca-app-pub-8521044456540023~3652646925`).
2. Crea las **unidades de anuncio** (o usa las que ya tienes en constantes):
   - Banner → `ca-app-pub-8521044456540023/1533750040`
   - Intersticial → `ca-app-pub-8521044456540023/5391914639`
   - Recompensado → `ca-app-pub-8521044456540023/4302612443`
3. **Vincula AdMob con Play** (AdMob → Settings → Linked apps) para métricas.
4. Configura **app-ads.txt** en tu dominio (si tienes web) para validar el
   inventario.
5. Configura el **mensaje de consentimiento (UMP/GDPR)** en AdMob → Privacy &
   messaging (obligatorio para tráfico de la UE).

> ✅ **IDs de prueba automáticos:** los builds *debug* usan siempre los
> anuncios de prueba de Google, así que puedes probar sin riesgo de que AdMob
> suspenda tu cuenta por clics inválidos. Solo los builds *release* usan tus
> IDs reales.

### 6.2 Cómo está implementado (referencia)

- `lib/app/ads.dart`:
  - **Consentimiento GDPR/UMP**: al arrancar pide el consentimiento cuando hace
    falta (usuarios de la UE/Reino Unido) usando el mensaje que configures en
    AdMob → *Privacy & messaging*. Sin ese mensaje creado, en la UE no se
    servirán anuncios.
  - **Banner adaptativo** abajo en la pantalla principal (`BannerAdWidget`).
  - **Intersticial** al guardar un estado, con un mínimo de **2 minutos** entre
    uno y otro para no molestar (`_interstitialCooldown`).
- `screens/rewarded_videos_screen.dart`: **video recompensado** → 15 minutos
  sin anuncios (`REWARDED_MINUTES`). Menú lateral → *Videos Recompensados*.
- Ningún anuncio se muestra si el usuario compró *quitar anuncios* o está en su
  periodo recompensado.

---

## 7. Firma, compilación y subida (paso a paso)

### 7.1 Entorno y nivel de API (✅ ya configurado)

- `targetSdk 36` (Play exige 35+), `compileSdk 37` (lo requieren
  `permission_handler` y `receive_sharing_intent`), `minSdk 24` (Android 7).
- El proyecto Android usa la **plantilla oficial de Flutter 3.47**
  (`android/*.gradle.kts`). Necesitas **Flutter stable reciente y JDK 17+**.
- **Acceso a los estados de WhatsApp (Android 11+):** Android ya no deja leer
  la carpeta `.Statuses` directamente. La app muestra una pantalla
  *"Permitir acceso"* que abre el selector de carpetas del sistema; el usuario
  toca **"Usar esta carpeta" → "Permitir"** una sola vez. No se usa
  `MANAGE_EXTERNAL_STORAGE`, así que **no hace falta la declaración especial de
  permisos** de Play que suele rechazar este tipo de apps.
- Los estados guardados van a `Pictures/Social Status Saver` (visibles en la
  galería).

### 7.2 Crear el keystore (una sola vez)
```bash
keytool -genkey -v -keystore ~/social-status-saver.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Guarda el `.jks` y las contraseñas en un lugar seguro (¡y con respaldo!). Si lo
pierdes, no podrás actualizar la app.

### 7.3 `android/key.properties`
```properties
storePassword=TU_PASSWORD
keyPassword=TU_PASSWORD
keyAlias=upload
storeFile=/ruta/absoluta/social-status-saver.jks
```
> 🔒 **Seguridad:** `key.properties`, `*.jks` y `*.keystore` ya están en
> `android/.gitignore` y `key.properties` se sacó del control de versiones
> (sigue en tu disco). Plantilla: `android/key.properties.example`.
> **Ojo:** sus contraseñas siguieron en el historial de Git desde 2021. Si el
> repo es o fue público, trátalas como comprometidas: usa **Play App Signing**
> (Google guarda la clave de firma real) y una *upload key* nueva.
>
> Si no existe `key.properties`, el build release firma con la clave debug
> (sirve para probar, **no** para subir a Play).

### 7.4 Compilar el App Bundle (formato que exige Play)
```bash
cd src/status_saver
flutter clean
flutter pub get
flutter test            # 9 pruebas: arranque de la app, traducciones, enlaces
flutter build appbundle --release
# Resultado: build/app/outputs/bundle/release/app-release.aab
```
> Si `key.properties` apunta a un keystore que no existe, el build falla en
> `validateSigningRelease`: corrige la ruta `storeFile`.
Para subir versiones nuevas, incrementa `version:` en `pubspec.yaml` (p.ej. `1.0.9+9`).

### 7.5 Subir a Play Console
1. **Crear app** en Play Console (nombre, idioma, tipo *App*, gratis).
2. Completa **Ficha principal** (§2 y §3), **Clasificación** y **Seguridad de
   datos** (§4).
3. Ve a **Producción → Crear versión** (o empieza por **Testing interno**, muy
   recomendado).
4. Sube el `.aab`. Play activará **firma de apps de Google Play** (App Signing).
5. Redacta las **notas de la versión**.
6. Envía a **revisión**. La primera revisión puede tardar de horas a varios días.

### 7.6 Orden recomendado de tracks
`Testing interno` → prueba compras y anuncios con tu cuenta tester → `Testing
cerrado` (amigos) → `Producción`.

---

## 8. Cumplimiento legal — LEER ANTES DE PUBLICAR

Esta es la sección más importante para una app de este tipo. Los rechazos y
suspensiones más comunes:

1. **Marcas de terceros.** No uses "WhatsApp/Instagram/TikTok/Facebook" en el
   nombre ni en el ícono. En la descripción, inclúyelo solo como compatibilidad y
   agrega el descargo: *"No afiliada a … Todas las marcas pertenecen a sus
   dueños"* (ya está en el texto de §2.3).

2. **Descarga de contenido de terceros.** Las políticas de Google y los **Términos
   de Servicio** de Instagram/Facebook/TikTok **prohíben** descargar/redistribuir
   contenido sin permiso. Posiciona la app para **contenido propio o con permiso**
   y así lo dice el texto. Aun así, las funciones de "downloader por enlace" tienen
   riesgo de rechazo; ten un plan B (por ejemplo, dejar activas solo las carpetas
   públicas y el descargo de responsabilidad).

3. **`MANAGE_EXTERNAL_STORAGE`.** Si lo usas para acceso amplio, Google exige una
   **declaración de permisos** justificando por qué una app "de gestión de
   archivos" lo necesita. Un status saver a veces es aceptado, a veces no. Intenta
   funcionar solo con `READ_MEDIA_*` y el *scoped storage* si puedes.

4. **Permiso de almacenamiento.** Declara su uso en el formulario de permisos.

5. **Publicidad y menores.** Si el público es 18+, marca el tráfico de anuncios en
   consecuencia y configura el consentimiento (UMP) para GDPR.

6. **Política de privacidad** válida y accesible (obligatoria porque usas AdMob y
   permisos sensibles).

> Recomendación honesta: la parte de **carpetas públicas + guardar tus propios
> estados** es de bajo riesgo. La parte de **descargar por enlace de redes
> sociales** es la de mayor riesgo de política. Si tu prioridad es que la app
> **no sea rechazada**, considera lanzar primero sin promocionar el downloader y
> evaluar.

---

## 9. Post-lanzamiento

- **Monitorea** en Play Console: instalaciones, ANRs/crashes, valoraciones.
- **Responde reseñas** (mejora el ranking ASO).
- **Actualiza los resolvers** de descarga cuando alguna plataforma cambie su HTML
  (`lib/services/link_downloader.dart`) — es mantenimiento esperable.
- **Sube `targetSdk`** cada año según el calendario de Google.
- **Revisa AdMob** por advertencias de políticas o clics inválidos.
- Incrementa `versionCode`/`versionName` en cada publicación.

---

### Resumen de archivos del proyecto relevantes

| Función | Archivo |
|---------|---------|
| Constantes (IDs, nombre, AdMob, suscripciones) | `src/status_saver/lib/constants/app_constants.dart` |
| Anuncios | `src/status_saver/lib/app/ads.dart`, `screens/rewarded_videos_screen.dart` |
| Compras | `src/status_saver/lib/services/purchases.dart`, `widgets/store_products.dart`, `screens/remove_ads_screen.dart` |
| Descarga por enlace | `src/status_saver/lib/services/link_downloader.dart` |
| Permisos | `src/status_saver/android/app/src/main/AndroidManifest.xml` |
| Firma / build | `src/status_saver/android/app/build.gradle.kts`, `android/key.properties` |
| Acceso a estados (Android 11+) | `android/app/src/main/kotlin/.../MainActivity.kt`, `lib/services/saf_statuses.dart` |
| Pruebas | `src/status_saver/test/` |
| Ícono / logo | `logoBase.png`, `src/status_saver/assets/images/app_logo.png` |
| Política de privacidad | `privacy_policy.html` |
| Mockups de la ficha | `docs/store_assets/*.svg` |

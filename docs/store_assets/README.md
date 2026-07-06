# Recursos gráficos para la ficha de Play Store

Mockups en **SVG** de las pantallas del app, pensados como base/guía de diseño
para las imágenes de la ficha. Google Play exige **PNG o JPG**, así que exporta
estos SVG a PNG en la resolución indicada (Inkscape, Figma, Canva, o
`rsvg-convert`/`inkscape` por línea de comandos).

| Archivo | Uso en la ficha | Tamaño de exportación |
|---------|-----------------|------------------------|
| `feature_graphic.svg` | Gráfico de funciones (obligatorio) | 1024 × 500 |
| `screenshot_01_home.svg` | Captura 1 — selector de plataformas | 1080 × 1920 |
| `screenshot_02_grid.svg` | Captura 2 — grid de imágenes/videos | 1080 × 1920 |
| `screenshot_03_saved.svg` | Captura 3 — pestaña Guardados | 1080 × 1920 |
| `screenshot_04_download_link.svg` | Captura 4 — descargar por enlace | 1080 × 1920 |
| `screenshot_05_share.svg` | Captura 5 — compartir hacia la app | 1080 × 1920 |

> ⚠️ Estos mockups son **representaciones** de la interfaz para diseñar la ficha.
> Para la publicación real se recomienda tomar **capturas reales en el
> dispositivo** y superponer los textos de marketing (ver la guía principal,
> sección 3.3).

Ejemplo de exportación por línea de comandos:
```bash
# con librsvg
rsvg-convert -w 1080 -h 1920 screenshot_01_home.svg -o screenshot_01_home.png
# o con inkscape
inkscape screenshot_01_home.svg -w 1080 -h 1920 -o screenshot_01_home.png
```

El ícono 512×512 se genera a partir de `assets/images/app_logo.png` /
`logoBase.png` del proyecto.

# Waridake

[English](../README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · **Español** · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Un organizador de ventanas para macOS que solo divide la pantalla.

*Waridake* (割り竹) significa «bambú partido»: un corte limpio y nada más.

**Qué hace:**

1. Defines zonas para cada pantalla
2. Mantén **Mayúsculas mientras arrastras una ventana** y aparecen las zonas
3. Suelta sobre una zona y la ventana encaja

Sin rejillas de atajos, sin historial de ventanas, sin suscripciones. Vive en la
barra de menús.

> La versión inglesa [README.md](../README.md) es la de referencia. Si esta traducción
> se queda atrás, manda aquella.

## Instalación

Requiere las herramientas de línea de comandos de Xcode (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

En el primer arranque macOS pide permiso de accesibilidad. Activa Waridake en
**Ajustes del Sistema → Privacidad y seguridad → Accesibilidad**. Basta con
concederlo con la app en marcha: se entera en un segundo, no hace falta reiniciarla.

Para que se abra al iniciar sesión: Ajustes del Sistema → General → Ítems de inicio.

### Sobre volver a compilar

Por omisión la firma es ad hoc, así que **cambia en cada compilación y macOS retira
el permiso sin avisar**: la casilla sigue marcada, pero nada funciona. Quita
Waridake de la lista de Accesibilidad y vuelve a añadirlo, o resuélvelo de raíz
creando un certificado de firma de código autofirmado (Acceso a Llaveros →
Asistente para certificados → Crear un certificado, tipo: firma de código) y
compilando con él:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Uso

Todo está bajo el icono de la barra de menús.

| Ítem del menú | Qué hace |
| --- | --- |
| **Ordenar ventanas abiertas** | Mete cada ventana abierta en la zona más cercana. Para recolocarlas cuando se han desplazado |
| **Editar disposición…** | El editor visual, descrito más abajo |
| **Disposiciones…** | Las disposiciones por pantalla con su último uso, y el historial |
| **Editar como JSON…** | El archivo de configuración, en una ventana de edición sencilla |
| **Recargar disposición** | Vuelve a leer el archivo tras editarlo por otro medio |

Las disposiciones se guardan **por pantalla**, porque las pantallas difieren en
forma y tamaño y un mismo reparto nunca les sirve a todas. Las pantallas se
identifican por su UUID, así que los ajustes sobreviven a desconexiones y reinicios.

### El editor visual

**Editar disposición…** abre un editor en todas las pantallas conectadas a la vez.
Da forma a cada una por separado; pulsar Guardar en cualquiera las guarda todas.
Los tamaños se muestran en porcentaje, así que nunca hay que leer fracciones.

| Acción | Qué hace |
| --- | --- |
| **Clic derecho en una zona** | Dividir en 2 o 3, distribuir, centrar en la pantalla |
| **Botón «Unir» en un borde** | Junta esas dos zonas. Aparece donde ambas formen un rectángulo |
| Arrastrar un borde | Lo mueve. Las zonas de ambos lados se estiran, así que no se abren huecos |
| **⌥ + arrastrar** un borde | Mueve también el borde simétrico respecto al centro de la pantalla, para ensanchar una zona central por igual |
| Doble clic en una zona | La corta en ese punto por su lado más largo (⌥ invierte la dirección) |
| `V` `H` `⌫` `⌘Z` `R` | Dividir, dividir al revés, unir con una vecina, deshacer, reiniciar |
| `return` / `esc` | Guardar y cerrar / descartar |

«Distribuir esta columna» iguala las zonas apiladas en la misma columna (por
ejemplo cuatro a lo largo del borde izquierdo); en una fila iguala las anchuras.
Las zonas del mismo tamaño en otro sitio de la pantalla se quedan como están.

«Centrar en la pantalla» mueve una zona para que quede simétrica respecto al eje
central sin cambiar su tamaño. Una zona pegada al borde de la pantalla no puede
moverse así, y el ítem del menú queda desactivado.

Los bordes se imantan a los de otras zonas y a 1/4, 1/3, 1/2, 2/3 y 3/4. El control
**Separación** de abajo fija el espacio entre zonas; elige «Ninguna» para que las
ventanas queden pegadas.

### Disposiciones e historial

**Disposiciones…** lista cada pantalla con si está conectada, qué contiene y cuándo
se usó por última vez, de modo que los ajustes de un monitor que ya no tienes saltan
a la vista y se pueden borrar.

Cada vez que guardas, el estado anterior queda en `~/.config/waridake/history/`, las
últimas 10 versiones. Cualquiera puede restaurarse desde la lista, y el estado previo
a la restauración también se archiva, así que nada se pierde.

## Configuración

El archivo es `~/.config/waridake/layout.json` y se crea en el primer arranque. Es un
archivo normal: el editor integrado es una comodidad, no un requisito.

Cada zona se escribe como una **fracción entre 0 y 1** del área útil de la pantalla
(lo que dejan libre la barra de menús y el Dock). `x`/`y` empiezan arriba a la
izquierda, `w`/`h` son ancho y alto, y `gap` es la separación entre zonas en puntos.

Por omisión, dos columnas iguales:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Las zonas pueden solaparse; gana la primera que contenga el puntero.

### Disposiciones por pantalla

Las pantallas van bajo `displays`, con su UUID como clave. El editor visual lo
escribe por ti. Las pantallas sin entrada usan los `gap` / `zones` de arriba.
`name` y `usedAt` son anotaciones: solo las escribe la app.

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ],
  "displays": {
    "37D8832A-2D66-02CA-B9F7-8F30A301B230": {
      "name": "Studio Display",
      "usedAt": "2026-08-13T12:25:00Z",
      "gap": 0,
      "zones": [
        { "x": 0,    "y": 0, "w": 0.25, "h": 1 },
        { "x": 0.25, "y": 0, "w": 0.5,  "h": 1 },
        { "x": 0.75, "y": 0, "w": 0.25, "h": 1 }
      ]
    }
  }
}
```

Los archivos sin `displays` siguen cargándose y valen para todas las pantallas.

## Idiomas

26 idiomas, elegidos automáticamente según los ajustes de idioma de macOS: no hay
nada que configurar.

La mayoría no los han escrito hablantes nativos, así que las correcciones son el
tipo de pull request más agradecido. Añadir un idioma consiste en copiar
`Resources/en.lproj/Localizable.strings` a `Resources/<idioma>.lproj/`, traducir la
parte derecha de cada línea y volver a compilar. Lo que quede sin traducir recae en
el inglés.

## Cómo funciona

- Un monitor global de eventos vigila los arrastres con el botón izquierdo (eso es lo
  que exige el permiso de accesibilidad)
- Al pulsar, la ventana bajo el puntero se localiza mediante la API de accesibilidad
- Las zonas solo aparecen cuando **la propia ventana se ha movido**, así que
  seleccionar texto o arrastrar un archivo dentro de una ventana no dispara nada
- Al soltar Mayúsculas las zonas desaparecen y el arrastre sigue con normalidad

## Resolución de problemas

- **No aparece ninguna zona**: comprueba el permiso de accesibilidad; mientras falte,
  el menú muestra un ítem con ⚠️
- **Dejó de funcionar tras recompilar**: mira «Sobre volver a compilar»
- **Una app no encaja**: está rechazando el cambio de tamaño. Las apps con tamaño
  mínimo de ventana, algunas de Electron entre ellas, acaban más grandes que la zona

## Apoyo

Waridake es gratis y lo seguirá siendo. Si te ahorra tiempo, se agradece el apoyo a
través de [GitHub Sponsors](https://github.com/sponsors/omikuji): es la única
financiación del proyecto.

## Licencia

Licencia MIT.

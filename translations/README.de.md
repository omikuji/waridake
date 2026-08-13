# Waridake

[English](../README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · **Deutsch** · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Ein Fenster-Snapper für macOS, der nichts anderes tut, als den Bildschirm zu teilen.

*Waridake* (割り竹) heißt „gespaltener Bambus“ — ein sauberer Schnitt, mehr nicht.

**Was es macht:**

1. Du legst für jedes Display Zonen fest
2. Halte beim Ziehen eines Fensters **die Shift-Taste**, und die Zonen erscheinen
3. Lass über einer Zone los, und das Fenster rastet ein

Keine Tastenkürzel-Raster, keine Fensterhistorie, keine Abos. Es lebt in der Menüleiste.

> Maßgeblich ist die englische [README.md](../README.md). Sollte diese Übersetzung
> hinterherhinken, gilt dort das Neuere.

## Installation

Benötigt die Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Beim ersten Start fragt macOS nach der Berechtigung für die Bedienungshilfen.
Schalte Waridake unter **Systemeinstellungen → Datenschutz & Sicherheit →
Bedienungshilfen** ein. Das genügt auch bei laufender App — sie merkt es
innerhalb einer Sekunde, ein Neustart ist nicht nötig.

Für den Start bei der Anmeldung: Systemeinstellungen → Allgemein → Anmeldeobjekte.

### Hinweis zum Neubauen

Standardmäßig wird ad-hoc signiert, also **ändert sich die Signatur bei jedem
Build und macOS entzieht still die Berechtigung** — das Häkchen bleibt gesetzt,
funktionieren tut trotzdem nichts. Entweder Waridake aus der Liste der
Bedienungshilfen entfernen und neu hinzufügen, oder das Problem dauerhaft lösen:
in der Schlüsselbundverwaltung ein selbstsigniertes Zertifikat zur Codesignierung
anlegen (Zertifikatsassistent → Zertifikat erstellen, Typ: Codesignatur) und damit bauen:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Benutzung

Alles steckt hinter dem Menüleistensymbol.

| Menüpunkt | Was er tut |
| --- | --- |
| **Offene Fenster anordnen** | Legt jedes offene Fenster in die nächstgelegene Zone. Zum Aufräumen, wenn Fenster verrutscht sind |
| **Layout bearbeiten…** | Der grafische Editor, siehe unten |
| **Layouts…** | Layouts pro Display samt letzter Benutzung, dazu der Verlauf |
| **Als JSON bearbeiten…** | Die Konfigurationsdatei in einem schlichten Editorfenster |
| **Layout neu laden** | Liest die Datei neu, wenn du sie woanders geändert hast |

Layouts werden **pro Display** gespeichert, denn Bildschirme unterscheiden sich in
Form und Größe, und eine Aufteilung passt nie auf alle. Displays werden über ihre
UUID erkannt, die Einstellungen überstehen also Ab- und Anstecken sowie Neustarts.

### Der grafische Editor

**Layout bearbeiten…** öffnet auf allen angeschlossenen Displays gleichzeitig einen
Editor. Gestalte jeden Bildschirm einzeln; ein Klick auf Sichern speichert alle.
Größen erscheinen in Prozent, Brüche muss also niemand lesen.

| Aktion | Was sie tut |
| --- | --- |
| **Rechtsklick auf eine Zone** | In 2 oder 3 teilen, gleichmäßig verteilen, zentrieren |
| **Knopf „Verbinden“ an einer Grenze** | Fügt die beiden Zonen zusammen. Erscheint überall dort, wo sie ein Rechteck ergeben |
| Eine Grenze ziehen | Verschiebt sie. Die Zonen zu beiden Seiten wachsen mit, es entstehen keine Lücken |
| Eine Grenze mit **⌥ ziehen** | Bewegt auch die gespiegelte Grenze, symmetrisch zur Bildschirmmitte — um eine mittlere Zone gleichmäßig zu verbreitern |
| Doppelklick auf eine Zone | Teilt sie an dieser Stelle entlang der längeren Seite (⌥ dreht die Richtung um) |
| `V` `H` `⌫` `⌘Z` `R` | Teilen, andersherum teilen, mit Nachbar verbinden, widerrufen, zurücksetzen |
| `return` / `esc` | Sichern und schließen / verwerfen |

„Diese Spalte gleichmäßig verteilen“ gleicht die untereinander liegenden Zonen
derselben Spalte an (etwa eine Vierteilung am linken Rand); bei einer Reihe sind es
die Breiten. Gleich große Zonen anderswo auf dem Bildschirm bleiben unangetastet.

„Zentrieren“ schiebt eine Zone symmetrisch um die Mittellinie, ohne ihre Größe zu
ändern. Eine Zone, die den Bildschirmrand berührt, kann das nicht, der Menüpunkt
bleibt dann deaktiviert.

Grenzen rasten an den Kanten anderer Zonen ein sowie bei 1/4, 1/3, 1/2, 2/3 und 3/4.
Der **Abstand** unten regelt den Zwischenraum; mit „Kein“ liegen die Fenster bündig.

### Layouts und Verlauf

**Layouts…** listet jedes Display mitsamt Verbindungsstatus, Inhalt und letzter
Benutzung — Einstellungen für einen Monitor, den du nicht mehr hast, fallen so
sofort auf und lassen sich löschen.

Jedes Sichern legt den vorherigen Stand in `~/.config/waridake/history/` ab, die
letzten 10 Versionen. Jede davon lässt sich aus der Liste wiederherstellen, und der
Stand von davor wird ebenfalls archiviert, ist also nicht verloren.

## Konfiguration

Die Datei liegt unter `~/.config/waridake/layout.json` und entsteht beim ersten
Start. Sie ist eine ganz normale Datei — der eingebaute Editor ist Bequemlichkeit,
keine Bedingung.

Jede Zone steht als **Bruchteil zwischen 0 und 1** der nutzbaren Bildschirmfläche
(was Menüleiste und Dock übrig lassen). `x`/`y` beginnen oben links, `w`/`h` sind
Breite und Höhe, `gap` ist der Abstand zwischen Zonen in Punkten.

Voreingestellt sind zwei gleiche Spalten:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Zonen dürfen sich überlappen; es gewinnt die erste, die den Zeiger enthält.

### Layouts pro Display

Displays stehen unter `displays`, als Schlüssel dient die Display-UUID. Der Editor
schreibt das für dich. Displays ohne Eintrag benutzen `gap` / `zones` von oben.
`name` und `usedAt` sind Buchführung — die schreibt nur die App.

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

Dateien ohne `displays` laden weiterhin und gelten dann überall.

## Sprachen

26 Sprachen, automatisch nach deinen macOS-Spracheinstellungen gewählt — es gibt
nichts einzustellen.

Die meisten stammen nicht von Muttersprachlern, Korrekturen sind daher die
willkommenste Art von Pull Request. Eine Sprache hinzufügen heißt:
`Resources/en.lproj/Localizable.strings` nach `Resources/<Sprache>.lproj/` kopieren,
die rechte Seite jeder Zeile übersetzen, neu bauen. Nicht Übersetztes fällt auf
Englisch zurück.

## Wie es funktioniert

- Ein globaler Event-Monitor beobachtet Züge mit der linken Maustaste (dafür wird
  die Berechtigung für die Bedienungshilfen gebraucht)
- Beim Drücken wird das Fenster unter dem Zeiger über die Accessibility-API ermittelt
- Die Zonen erscheinen erst, wenn **das Fenster selbst sich bewegt hat** — Text
  markieren oder eine Datei im Fenster ziehen löst also nichts aus
- Beim Loslassen von Shift verschwinden die Zonen, der Zug läuft normal weiter

## Fehlersuche

- **Es erscheinen keine Zonen** — Berechtigung prüfen; solange sie fehlt, zeigt das
  Menü einen ⚠️-Eintrag
- **Nach einem Neubau geht nichts mehr** — siehe „Hinweis zum Neubauen“
- **Eine App passt sich nicht ein** — sie lehnt die Größenänderung ab. Apps mit
  Mindestfenstergröße, auch manche Electron-Apps, bleiben größer als die Zone

## Unterstützung

Waridake ist kostenlos und bleibt es. Wenn es dir Zeit spart, freut sich das
Projekt über eine Unterstützung via
[GitHub Sponsors](https://github.com/sponsors/omikuji) — die einzige Finanzierung.

Fragen, Probleme und Ideen sind willkommen:

- [X (@omikuji_man)](https://x.com/omikuji_man)
- [Kontaktformular](https://omikuji.dev/contact/)
- [Auf GitHub melden](https://github.com/omikuji/waridake/issues)

## Lizenz

MIT-Lizenz.

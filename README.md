# Waridake

**English** · [العربية](translations/README.ar.md) · [Čeština](translations/README.cs.md) · [Dansk](translations/README.da.md) · [Deutsch](translations/README.de.md) · [Español](translations/README.es.md) · [Suomi](translations/README.fi.md) · [Français](translations/README.fr.md) · [עברית](translations/README.he.md) · [हिन्दी](translations/README.hi.md) · [Bahasa Indonesia](translations/README.id.md) · [Italiano](translations/README.it.md) · [日本語](translations/README.ja.md) · [한국어](translations/README.ko.md) · [Norsk](translations/README.nb.md) · [Nederlands](translations/README.nl.md) · [Polski](translations/README.pl.md) · [Português](translations/README.pt-BR.md) · [Русский](translations/README.ru.md) · [Svenska](translations/README.sv.md) · [ไทย](translations/README.th.md) · [Türkçe](translations/README.tr.md) · [Українська](translations/README.uk.md) · [Tiếng Việt](translations/README.vi.md) · [简体中文](translations/README.zh-Hans.md) · [繁體中文](translations/README.zh-Hant.md)

A macOS window snapper that only splits the screen.

*Waridake* (割り竹) means "split bamboo" — one clean cut, nothing else.

**What it does:**

1. You define zones for each display
2. Hold **Shift while dragging a window** and the zones appear
3. Release over a zone and the window snaps into it

No hotkey grids, no window history, no subscriptions. It lives in the menu bar.

## Install

Requires the Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

On first launch macOS asks for Accessibility permission. Turn Waridake on in
**System Settings → Privacy & Security → Accessibility**. Granting it while the
app is running is enough — it picks the permission up within a second, no
restart needed.

To launch at login, add Waridake.app under System Settings → General → Login Items.

### A note on rebuilding

The build is ad-hoc signed by default, so **the code signature changes on every
rebuild and macOS quietly drops the accessibility permission** — the checkbox
still looks enabled, but nothing works. Remove Waridake from the Accessibility
list and add it again, or stop the problem for good by creating a self-signed
code signing certificate (Keychain Access → Certificate Assistant → Create a
Certificate, type: Code Signing) and building with it:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Using it

Everything is under the menu bar icon.

| Menu item | What it does |
| --- | --- |
| **Arrange Open Windows** | Puts every open window into the zone nearest to it. For cleaning up after windows have drifted |
| **Edit Layout…** | The visual editor, described below |
| **Layouts…** | Per-display layouts with their last-used date, and the edit history |
| **Edit as JSON…** | The config file, in a plain editor window |
| **Reload Layout** | Re-reads the config file after editing it elsewhere |

Layouts are kept **per display**, because screens differ in shape and size and
one split never suits all of them. Displays are identified by their UUID, so
settings survive unplugging and reboots.

### The visual editor

Choosing **Edit Layout…** opens an editor on every connected display at once.
Shape each screen separately; pressing Save on any of them saves them all.
Sizes are shown as percentages, so the fractions never have to be read.

| Action | What it does |
| --- | --- |
| **Right-click a zone** | Split in 2 or 3, distribute evenly, center on screen |
| **The "Merge" button on a boundary** | Joins those two zones. Shown wherever a pair would form a rectangle |
| Drag a boundary | Moves it. Zones on both sides stretch along, so no gaps open up |
| **⌥ drag** a boundary | Moves the mirrored boundary too, symmetrically about the screen center — for widening a center zone evenly |
| Double-click a zone | Splits it at that point, along its longer side (⌥ flips the direction) |
| `V` `H` `⌫` `⌘Z` `R` | Split, split the other way, merge with a neighbour, undo, reset |
| `return` / `esc` | Save and close / discard |

"Distribute this column evenly" evens out the zones stacked in the same column
(a four-way split down the left edge, say); for a row it evens their widths.
Zones of the same size somewhere else on screen are left alone.

"Center on screen" moves a zone so it sits symmetrically about the center line
without changing its size. A zone touching the screen border cannot move that
way, so the menu item stays disabled for it.

Boundaries snap to the other zones' edges and to 1/4, 1/3, 1/2, 2/3 and 3/4.
The **Gap** control at the bottom sets the space between zones; pick "None" to
have windows sit flush against each other.

### Layouts and history

**Layouts…** lists every display's layout with whether it is connected, what it
contains, and when it was last used, so settings for a monitor you no longer own
are easy to spot and delete.

The first row is the **default**: what a display starts from before it has a
layout of its own. **Make Default** on any row promotes that display's layout to
it, which is the way to change the default without touching the JSON.

Every save keeps the previous state in `~/.config/waridake/history/`, the last
10 versions. Restoring one from the list is possible at any time, and the state
from before the restore is archived too, so it can be undone.

## Configuration

The config file is `~/.config/waridake/layout.json`, created on first launch.
It is a plain file — the built-in editor is a convenience, not a requirement.

Each zone is written as a **fraction between 0 and 1** of the screen's working
area (what is left over by the menu bar and the Dock). `x`/`y` start at the top
left, `w`/`h` are width and height, and `gap` is the space between zones in points.

The default is two equal columns:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Zones may overlap; the first one containing the pointer wins.

### Per-display layouts

Displays go under `displays`, keyed by display UUID. The visual editor writes
this for you. Displays with no entry use the top-level `gap` / `zones`.
`name` and `usedAt` are bookkeeping — only the app writes them.

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

Config files without `displays` still load, and apply everywhere.

## Languages

26 languages, picked automatically from your macOS language settings — there is
nothing to configure:

Arabic, Chinese (Simplified and Traditional), Czech, Danish, Dutch, English,
Finnish, French, German, Hebrew, Hindi, Indonesian, Italian, Japanese, Korean,
Norwegian, Polish, Portuguese (Brazil), Russian, Spanish, Swedish, Thai,
Turkish, Ukrainian, Vietnamese.

Most of these were not written by native speakers, so corrections are the most
welcome kind of pull request. Adding a language means copying
`Resources/en.lproj/Localizable.strings` to `Resources/<language>.lproj/`,
translating the right-hand side of each line, and rebuilding. Anything left
untranslated falls back to English.

This README is translated too — the other languages live in `translations/`,
listed at the top of this file. English is the canonical version; run
`python3 Tools/sync-readme-nav.py` after adding one to refresh those links.

## How it works

- A global event monitor watches left-button drags (this is what needs the
  Accessibility permission)
- On mouse down, the window under the cursor is found through the Accessibility API
- The zones only appear once **the window itself has moved**, so selecting text
  or dragging a file inside a window does not trigger anything
- Releasing Shift hides the zones and leaves the drag alone

## Troubleshooting

- **No icon in the menu bar** — a full menu bar drops whatever no longer fits,
  which happens easily on a notched Mac. Open Waridake again (Spotlight, Finder,
  the Dock) and the same menu appears at the pointer. To get the icon back,
  make room by quitting another menu bar app, or ⌘-drag the icons to reorder them
- **No zones appear** — check the Accessibility permission; the menu shows a ⚠️
  item while it is missing
- **It stopped working after a rebuild** — see "A note on rebuilding" above
- **One app refuses to fit** — it is declining the resize. Apps with a minimum
  window size, including some Electron ones, can end up larger than the zone

## Support

Waridake is free and always will be. If it saves you time, sponsoring the work
through [GitHub Sponsors](https://github.com/sponsors/omikuji) is appreciated
and is the only way the project is funded.

Questions, problems and ideas are all welcome:

- [X (@omikuji_man)](https://x.com/omikuji_man)
- [Contact form](https://omikuji.dev/contact/)
- [Report an issue on GitHub](https://github.com/omikuji/waridake/issues)

## License

MIT License.

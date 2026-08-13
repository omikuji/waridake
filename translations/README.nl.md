# Waridake

[English](../README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · **Nederlands** · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Een venstermanager voor macOS die niets anders doet dan het scherm verdelen.

*Waridake* (割り竹) betekent ‘gespleten bamboe’ — één schone snede, meer niet.

**Wat het doet:**

1. Je legt zones vast voor elk scherm
2. Houd **Shift ingedrukt terwijl je een venster sleept** en de zones verschijnen
3. Laat los boven een zone en het venster klikt erin

Geen roosters van sneltoetsen, geen venstergeschiedenis, geen abonnementen. Het
woont in de menubalk.

> De Engelse [README.md](../README.md) is leidend. Loopt deze vertaling achter, dan
> geldt die.

## Installatie

Vereist de Xcode-opdrachtregelprogramma’s (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Bij de eerste start vraagt macOS om toegang tot Toegankelijkheid. Zet Waridake aan bij
**Systeeminstellingen → Privacy en beveiliging → Toegankelijkheid**. Toestaan terwijl
het programma draait is genoeg: het merkt het binnen een seconde, opnieuw starten
hoeft niet.

Automatisch openen bij inloggen: Systeeminstellingen → Algemeen → Inlogonderdelen.

### Let op bij opnieuw bouwen

De ondertekening is standaard ad hoc, dus **bij elke build verandert de handtekening
en trekt macOS de toestemming stilletjes in** — het vinkje staat nog aan, maar niets
werkt. Verwijder Waridake uit de lijst en voeg het opnieuw toe, of los het definitief
op met een zelfondertekend certificaat voor codeondertekening (Sleutelhangertoegang →
Assistent certificaten → Maak een certificaat, type: codeondertekening) en bouw daarmee:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Gebruik

Alles zit onder het menubalksymbool.

| Menuonderdeel | Wat het doet |
| --- | --- |
| **Open vensters ordenen** | Zet elk open venster in de dichtstbijzijnde zone. Om op te ruimen als vensters zijn verschoven |
| **Lay-out bewerken…** | De grafische editor, hieronder beschreven |
| **Lay-outs…** | Lay-outs per scherm met wanneer ze het laatst gebruikt zijn, plus de geschiedenis |
| **Als JSON bewerken…** | Het configuratiebestand in een eenvoudig venster |
| **Lay-out opnieuw laden** | Leest het bestand opnieuw na een wijziging elders |

Lay-outs worden **per scherm** bewaard, want schermen verschillen in vorm en formaat en
één verdeling past nooit op alle. Schermen worden herkend aan hun UUID, dus de
instellingen overleven loskoppelen en opnieuw opstarten.

### De grafische editor

**Lay-out bewerken…** opent op alle aangesloten schermen tegelijk een editor. Geef elk
scherm apart vorm; op Bewaar drukken op één ervan bewaart ze allemaal. Formaten staan
in procenten, breuken hoeft niemand te lezen.

| Handeling | Wat het doet |
| --- | --- |
| **Rechtsklik op een zone** | In 2 of 3 delen, gelijk verdelen, op het scherm centreren |
| **Knop ‘Samenvoegen’ op een grens** | Voegt die twee zones samen. Verschijnt overal waar ze samen een rechthoek vormen |
| Een grens slepen | Verplaatst hem. De zones aan beide kanten rekken mee, er ontstaan geen gaten |
| Een grens **met ⌥ slepen** | Verplaatst ook de gespiegelde grens, symmetrisch om het midden van het scherm — om een middenzone gelijkmatig te verbreden |
| Dubbelklik op een zone | Snijdt hem daar door, langs de langste zijde (⌥ draait de richting om) |
| `V` `H` `⌫` `⌘Z` `R` | Splitsen, andersom splitsen, samenvoegen met een buur, herstellen, opnieuw beginnen |
| `return` / `esc` | Bewaren en sluiten / negeren |

‘Deze kolom gelijk verdelen’ trekt de zones in dezelfde kolom gelijk (bijvoorbeeld vier
langs de linkerrand); bij een rij zijn dat de breedtes. Zones van hetzelfde formaat
elders op het scherm blijven ongemoeid.

‘Op het scherm centreren’ verschuift een zone zodat hij symmetrisch om de middenlijn
staat, zonder het formaat te veranderen. Een zone die de schermrand raakt kan dat niet,
en het menuonderdeel blijft dan uitgeschakeld.

Grenzen klikken vast op de randen van andere zones en op 1/4, 1/3, 1/2, 2/3 en 3/4. De
regelaar **Tussenruimte** onderin bepaalt de ruimte tussen zones; kies ‘Geen’ en de
vensters sluiten op elkaar aan.

### Lay-outs en geschiedenis

**Lay-outs…** toont per scherm of het aangesloten is, wat erin staat en wanneer het voor
het laatst gebruikt is — instellingen van een monitor die je niet meer hebt vallen zo op
en kun je verwijderen.

Elke keer dat je bewaart blijft de vorige stand in `~/.config/waridake/history/` staan,
de laatste 10 versies. Elke versie kun je vanuit de lijst terugzetten, en de stand van
vóór het terugzetten wordt ook bewaard, dus er gaat niets verloren.

## Configuratie

Het bestand is `~/.config/waridake/layout.json` en ontstaat bij de eerste start. Het is
een gewoon bestand — de ingebouwde editor is gemak, geen voorwaarde.

Elke zone staat als **breuk tussen 0 en 1** van het bruikbare deel van het scherm (wat
de menubalk en het Dock overlaten). `x`/`y` beginnen linksboven, `w`/`h` zijn breedte en
hoogte, en `gap` is de ruimte tussen zones in punten.

Standaard zijn dat twee gelijke kolommen:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Zones mogen overlappen; de eerste die de aanwijzer bevat wint.

### Lay-outs per scherm

Schermen staan onder `displays`, met de UUID als sleutel. De grafische editor schrijft
dat voor je. Schermen zonder eigen regel gebruiken de `gap` / `zones` bovenaan. `name`
en `usedAt` zijn administratie — die schrijft alleen het programma.

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

Bestanden zonder `displays` laden gewoon en gelden dan overal.

## Talen

26 talen, automatisch gekozen op basis van je macOS-taalinstellingen — er valt niets in
te stellen.

De meeste zijn niet door moedertaalsprekers geschreven, dus correcties zijn het meest
welkome soort pull request. Een taal toevoegen betekent
`Resources/en.lproj/Localizable.strings` kopiëren naar `Resources/<taal>.lproj/`, de
rechterkant van elke regel vertalen en opnieuw bouwen. Wat onvertaald blijft valt terug
op het Engels.

## Hoe het werkt

- Een globale event-monitor let op slepen met de linkerknop (daarvoor is de toestemming
  voor Toegankelijkheid nodig)
- Bij het indrukken wordt het venster onder de aanwijzer via de Accessibility-API gezocht
- De zones verschijnen pas als **het venster zelf bewogen heeft**, dus tekst selecteren
  of een bestand slepen binnen een venster doet niets
- Laat je Shift los, dan verdwijnen de zones en gaat het slepen gewoon door

## Problemen oplossen

- **Er verschijnen geen zones** — controleer de toestemming; zolang die ontbreekt toont
  het menu een onderdeel met ⚠️
- **Werkt niet meer na opnieuw bouwen** — zie ‘Let op bij opnieuw bouwen’
- **Eén programma past zich niet aan** — dat weigert de formaatwijziging. Programma’s met
  een minimale venstergrootte, waaronder sommige Electron-apps, blijven groter dan de zone

## Steun

Waridake is gratis en blijft dat. Bespaart het je tijd, dan is steun via
[GitHub Sponsors](https://github.com/sponsors/omikuji) welkom — het is de enige
financiering van het project.

## Licentie

MIT-licentie.

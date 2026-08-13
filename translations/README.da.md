# Waridake

[English](../README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · **Dansk** · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

En vinduesplacering til macOS, der ikke gør andet end at dele skærmen.

*Waridake* (割り竹) betyder “kløvet bambus” — ét rent snit, ikke mere.

**Hvad den gør:**

1. Du fastlægger zoner for hver skærm
2. Hold **skift nede, mens du trækker et vindue**, så dukker zonerne op
3. Slip over en zone, og vinduet falder på plads

Ingen gitre af tastaturgenveje, ingen vindueshistorik, ingen abonnementer. Den bor i
menulinjen.

> Den engelske [README.md](../README.md) er den gældende. Halter denne oversættelse bagefter,
> er det den engelske, der tæller.

## Installation

Kræver Xcodes kommandolinjeværktøjer (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Ved første start beder macOS om tilladelse til tilgængelighed. Slå Waridake til under
**Systemindstillinger → Anonymitet og sikkerhed → Tilgængelighed**. Det er nok at gøre det,
mens appen kører: den opdager det inden for et sekund, og genstart er ikke nødvendig.

Skal den åbne ved log ind: Systemindstillinger → Generelt → Log ind-emner.

### Bemærk ved genopbygning

Signeringen er som udgangspunkt ad hoc, så **den ændrer sig ved hver oversættelse, og macOS
trækker stille tilladelsen tilbage** — afkrydsningen står stadig, men intet virker. Fjern
Waridake fra listen og tilføj den igen, eller løs det én gang for alle med et selvsigneret
certifikat til kodesignering (Nøglering → Certifikatassistent → Opret et certifikat, type:
kodesignering) og byg med det:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Brug

Alt ligger under symbolet i menulinjen.

| Menupunkt | Hvad det gør |
| --- | --- |
| **Ordn åbne vinduer** | Lægger hvert åbent vindue i den nærmeste zone. Til at rydde op, når vinduerne er gledet |
| **Rediger layout…** | Den grafiske editor, beskrevet nedenfor |
| **Layouts…** | Layouts pr. skærm med sidste brug samt historikken |
| **Rediger som JSON…** | Indstillingsfilen i et enkelt redigeringsvindue |
| **Indlæs layoutet igen** | Læser filen igen, når du har ændret den andetsteds |

Layouts gemmes **pr. skærm**, for skærme er forskellige i form og størrelse, og én opdeling
passer aldrig til dem alle. Skærme kendes på deres UUID, så indstillingerne overlever både
frakobling og genstart.

### Den grafiske editor

**Rediger layout…** åbner en editor på alle tilsluttede skærme på én gang. Form hver skærm for
sig; trykker du Arkiver ét sted, arkiveres de alle. Størrelser vises i procent, så ingen
behøver læse brøker.

| Handling | Hvad det gør |
| --- | --- |
| **Højreklik på en zone** | Del i 2 eller 3, fordel jævnt, centrer på skærmen |
| **Knappen “Flet” ved en grænse** | Slår de to zoner sammen. Vises, hvor de tilsammen danner et rektangel |
| Træk i en grænse | Flytter den. Zonerne på begge sider følger med, så der opstår ingen huller |
| Træk i en grænse **med ⌥** | Flytter også den spejlede grænse, symmetrisk om skærmens midte — til at gøre en midterzone jævnt bredere |
| Dobbeltklik på en zone | Deler den dér, langs den længste side (⌥ vender retningen) |
| `V` `H` `⌫` `⌘Z` `R` | Del, del den anden vej, flet med en nabo, fortryd, start forfra |
| `return` / `esc` | Arkiver og luk / kassér |

“Fordel denne kolonne jævnt” udjævner zonerne, der ligger over hinanden i samme kolonne (for
eksempel fire langs venstre kant); i en række er det bredderne. Zoner af samme størrelse andre
steder på skærmen bliver urørt.

“Centrer på skærmen” flytter en zone, så den ligger symmetrisk om midterlinjen uden at ændre
størrelse. En zone, der rører skærmkanten, kan ikke flyttes sådan, og menupunktet forbliver
slået fra.

Grænser hægter sig på andre zoners kanter og på 1/4, 1/3, 1/2, 2/3 og 3/4. Betjeningen
**Mellemrum** nederst bestemmer afstanden mellem zoner; vælg “Ingen”, så ligger vinduerne helt
op ad hinanden.

### Layouts og historik

**Layouts…** viser hver skærm med, om den er tilsluttet, hvad den indeholder, og hvornår den
sidst blev brugt — indstillinger til en skærm, du ikke længere har, springer i øjnene og kan
slettes.

Hver arkivering efterlader den forrige tilstand i `~/.config/waridake/history/`, de seneste 10
versioner. Enhver af dem kan gendannes fra listen, og tilstanden før gendannelsen arkiveres
også, så intet går tabt.

## Indstillinger

Filen er `~/.config/waridake/layout.json` og oprettes ved første start. Det er en ganske
almindelig fil — den indbyggede editor er en bekvemmelighed, ikke et krav.

Hver zone skrives som en **brøkdel mellem 0 og 1** af skærmens arbejdsområde (det, menulinjen
og Dock levner). `x`/`y` regnes fra øverste venstre hjørne, `w`/`h` er bredde og højde, og
`gap` er mellemrummet mellem zoner i punkter.

Som standard to lige brede kolonner:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Zoner må gerne overlappe; den første, der indeholder markøren, vinder.

### Layouts pr. skærm

Skærme står under `displays` med deres UUID som nøgle. Den grafiske editor skriver det for dig.
Skærme uden et punkt bruger `gap` / `zones` øverst. `name` og `usedAt` er bogholderi — kun
appen skriver dem.

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

Filer uden `displays` indlæses stadig og gælder alle steder.

## Sprog

26 sprog, valgt automatisk ud fra dine sprogindstillinger i macOS — der er intet at indstille.

De fleste er ikke skrevet af modersmålstalere, så rettelser er den mest velkomne slags pull
request. At tilføje et sprog vil sige at kopiere `Resources/en.lproj/Localizable.strings` til
`Resources/<sprog>.lproj/`, oversætte højresiden af hver linje og bygge igen. Det, der ikke er
oversat, falder tilbage til engelsk.

## Sådan virker det

- En global hændelsesovervåger holder øje med træk med venstre knap (det er dét, der kræver
  tilladelsen til tilgængelighed)
- Ved tryk findes vinduet under markøren via Accessibility-API’et
- Zonerne dukker først op, når **selve vinduet har flyttet sig**, så at markere tekst eller
  trække en fil inde i et vindue udløser ingenting
- Slipper du skift, forsvinder zonerne, og trækket fortsætter som normalt

## Fejlfinding

- **Der kommer ingen zoner** — tjek tilladelsen; så længe den mangler, viser menuen et punkt
  med ⚠️
- **Holdt op med at virke efter en genopbygning** — se “Bemærk ved genopbygning”
- **En app vil ikke passe ind** — den afviser at ændre størrelse. Apps med en mindste
  vinduesstørrelse, heriblandt visse Electron-apps, ender større end zonen

## Støtte

Waridake er gratis og bliver ved med at være det. Sparer den dig tid, er støtte via
[GitHub Sponsors](https://github.com/sponsors/omikuji) værdsat — det er projektets eneste
finansiering.

## Licens

MIT-licens.

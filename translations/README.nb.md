# Waridake

[English](../README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · **Norsk** · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

En vindusplasserer for macOS som ikke gjør annet enn å dele skjermen.

*Waridake* (割り竹) betyr «kløyvd bambus» — ett rent snitt, ikke mer.

**Hva den gjør:**

1. Du bestemmer soner for hver skjerm
2. Hold **skift mens du drar et vindu**, så dukker sonene opp
3. Slipp over en sone, og vinduet faller på plass

Ingen rutenett av hurtigtaster, ingen vindushistorikk, ingen abonnementer. Den bor i
menylinjen.

> Den engelske [README.md](../README.md) er den gjeldende. Henger denne oversettelsen etter,
> er det den engelske som gjelder.

## Installering

Krever kommandolinjeverktøyene til Xcode (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Ved første start ber macOS om tilgjengelighetstillatelse. Slå på Waridake under
**Systeminnstillinger → Personvern og sikkerhet → Tilgjengelighet**. Det holder å gjøre det
mens appen kjører: den merker det i løpet av et sekund, og omstart trengs ikke.

For å starte ved innlogging: Systeminnstillinger → Generelt → Innloggingsobjekter.

### Merk ved ny bygging

Signeringen er ad hoc som standard, så **signaturen endres ved hver bygging, og macOS trekker
stille tilbake tillatelsen** — avkrysningen står fortsatt, men ingenting virker. Fjern Waridake
fra tilgjengelighetslisten og legg den til igjen, eller løs det én gang for alle med et
selvsignert sertifikat for kodesignering (Nøkkelringtilgang → Sertifikatassistent → Opprett et
sertifikat, type: kodesignering) og bygg med det:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Bruk

Alt ligger under symbolet i menylinjen.

| Menyvalg | Hva det gjør |
| --- | --- |
| **Ordne åpne vinduer** | Legger hvert åpne vindu i den nærmeste sonen. For å rydde når vinduene har glidd ut |
| **Rediger oppsett…** | Den grafiske editoren, beskrevet nedenfor |
| **Oppsett…** | Oppsett per skjerm med sist brukt, og historikken |
| **Rediger som JSON…** | Innstillingsfilen i et enkelt redigeringsvindu |
| **Last inn oppsettet på nytt** | Leser filen på nytt etter at du har endret den et annet sted |

Oppsett lagres **per skjerm**, for skjermer er ulike i form og størrelse, og én inndeling passer
aldri alle. Skjermer kjennes igjen på UUID-en sin, så innstillingene overlever både frakobling
og omstart.

### Den grafiske editoren

**Rediger oppsett…** åpner en editor på alle tilkoblede skjermer samtidig. Form hver skjerm for
seg; trykker du Arkiver på én av dem, arkiveres alle. Størrelser vises i prosent, så ingen
trenger å lese brøker.

| Handling | Hva det gjør |
| --- | --- |
| **Høyreklikk på en sone** | Del i 2 eller 3, fordel jevnt, midtstill på skjermen |
| **Knappen «Slå sammen» ved en grense** | Slår de to sonene sammen. Vises der de til sammen danner et rektangel |
| Dra i en grense | Flytter den. Sonene på begge sider strekker seg med, så det oppstår ingen hull |
| Dra i en grense **med ⌥** | Flytter også den speilvendte grensen, symmetrisk om midten av skjermen — for å utvide en midtsone jevnt |
| Dobbeltklikk på en sone | Deler den der, langs den lengste siden (⌥ snur retningen) |
| `V` `H` `⌫` `⌘Z` `R` | Del, del andre veien, slå sammen med en nabo, angre, begynn på nytt |
| `return` / `esc` | Arkiver og lukk / forkast |

«Fordel denne kolonnen jevnt» jevner ut sonene som ligger over hverandre i samme kolonne (for
eksempel fire langs venstre kant); i en rad er det breddene. Soner av samme størrelse andre
steder på skjermen blir urørt.

«Midtstill på skjermen» flytter en sone slik at den ligger symmetrisk om midtlinjen uten å endre
størrelse. En sone som berører skjermkanten kan ikke flyttes slik, og menyvalget forblir slått av.

Grenser fester seg til kantene på andre soner og til 1/4, 1/3, 1/2, 2/3 og 3/4. Kontrollen
**Mellomrom** nederst bestemmer avstanden mellom soner; velg «Ingen», så ligger vinduene helt
inntil hverandre.

### Oppsett og historikk

**Oppsett…** viser hver skjerm med om den er tilkoblet, hva den inneholder og når den sist ble
brukt — innstillinger for en skjerm du ikke har lenger, er lette å se og slette.

Hver arkivering legger igjen forrige tilstand i `~/.config/waridake/history/`, de siste 10
versjonene. Hvilken som helst kan gjenopprettes fra listen, og tilstanden før gjenopprettingen
arkiveres også, så ingenting går tapt.

## Innstillinger

Filen er `~/.config/waridake/layout.json` og lages ved første start. Det er en helt vanlig fil —
den innebygde editoren er en bekvemmelighet, ikke et krav.

Hver sone skrives som en **andel mellom 0 og 1** av skjermens arbeidsområde (det menylinjen og
Dock lar være igjen). `x`/`y` regnes fra øverste venstre hjørne, `w`/`h` er bredde og høyde, og
`gap` er mellomrommet mellom soner i punkter.

Som standard to like brede kolonner:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Soner kan overlappe; den første som inneholder pekeren, vinner.

### Oppsett per skjerm

Skjermer står under `displays` med UUID-en som nøkkel. Den grafiske editoren skriver det for deg.
Skjermer uten en oppføring bruker `gap` / `zones` øverst. `name` og `usedAt` er bokføring — bare
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

Filer uten `displays` lastes fortsatt inn og gjelder overalt.

## Språk

26 språk, valgt automatisk ut fra språkinnstillingene i macOS — det er ingenting å stille inn.

De fleste er ikke skrevet av folk med språket som morsmål, så rettelser er den mest velkomne
typen pull request. Å legge til et språk vil si å kopiere
`Resources/en.lproj/Localizable.strings` til `Resources/<språk>.lproj/`, oversette høyresiden av
hver linje og bygge på nytt. Det som ikke er oversatt, faller tilbake på engelsk.

## Slik virker det

- En global hendelsesovervåker følger med på dra med venstre knapp (det er dette som krever
  tilgjengelighetstillatelsen)
- Ved trykk finnes vinduet under pekeren via Accessibility-API-et
- Sonene dukker først opp når **selve vinduet har flyttet seg**, så å markere tekst eller dra en
  fil inne i et vindu utløser ingenting
- Slipper du skift, forsvinner sonene, og dragingen fortsetter som vanlig

## Feilsøking

- **Ingen soner dukker opp** — sjekk tillatelsen; så lenge den mangler, viser menyen et valg med ⚠️
- **Sluttet å virke etter en ny bygging** — se «Merk ved ny bygging»
- **Én app vil ikke passe inn** — den avslår størrelsesendringen. Apper med en minste
  vindusstørrelse, deriblant enkelte Electron-apper, blir større enn sonen

## Støtte

Waridake er gratis og kommer til å forbli det. Sparer den deg tid, settes støtte via
[GitHub Sponsors](https://github.com/sponsors/omikuji) pris på — det er prosjektets eneste
finansiering.

## Lisens

MIT-lisens.

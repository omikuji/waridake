# Waridake

[English](../README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · **Svenska** · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

En fönsterplacerare för macOS som inte gör annat än delar skärmen.

*Waridake* (割り竹) betyder ”kluven bambu” — ett rent snitt, inget mer.

**Vad den gör:**

1. Du bestämmer zoner för varje skärm
2. Håll **skift medan du drar ett fönster** så visas zonerna
3. Släpp över en zon och fönstret hamnar där

Inga rutnät av tangentkommandon, ingen fönsterhistorik, inga prenumerationer. Den bor
i menyraden.

> Den engelska [README.md](../README.md) gäller. Om den här översättningen släpar efter är
> det den engelska som stämmer.

## Installation

Kräver Xcodes kommandoradsverktyg (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Vid första starten ber macOS om tillstånd för hjälpmedel. Slå på Waridake under
**Systeminställningar → Integritet och säkerhet → Hjälpmedel**. Det räcker att göra det
medan appen kör: den märker det inom en sekund, ingen omstart behövs.

För start vid inloggning: Systeminställningar → Allmänt → Inloggningsobjekt.

### Att tänka på vid ombyggnad

Signeringen är ad hoc som standard, så **signaturen ändras vid varje bygge och macOS drar
tyst tillbaka tillståndet** — kryssrutan ser påslagen ut, men inget fungerar. Ta bort
Waridake ur hjälpmedelslistan och lägg till den igen, eller lös det en gång för alla med
ett självsignerat certifikat för kodsignering (Nyckelhanterare → Certifikatassistent →
Skapa ett certifikat, typ: kodsignering) och bygg med det:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Användning

Allt finns under symbolen i menyraden.

| Menyval | Vad det gör |
| --- | --- |
| **Ordna öppna fönster** | Lägger varje öppet fönster i närmaste zon. För att städa när fönstren glidit isär |
| **Redigera layout…** | Den grafiska redigeraren, beskriven nedan |
| **Layouter…** | Layouter per skärm med senaste användning, samt historiken |
| **Redigera som JSON…** | Inställningsfilen i ett enkelt redigeringsfönster |
| **Läs in layouten igen** | Läser om filen efter att du ändrat den på annat håll |

Layouter sparas **per skärm**, eftersom skärmar skiljer sig i form och storlek och en och
samma indelning aldrig passar alla. Skärmar känns igen på sitt UUID, så inställningarna
överlever både urkoppling och omstart.

### Den grafiska redigeraren

**Redigera layout…** öppnar en redigerare på alla anslutna skärmar samtidigt. Forma varje
skärm för sig; att trycka Spara på någon av dem sparar allihop. Storlekar visas i procent,
så ingen behöver läsa bråktal.

| Handling | Vad det gör |
| --- | --- |
| **Högerklick på en zon** | Dela i 2 eller 3, fördela jämnt, centrera på skärmen |
| **Knappen ”Slå ihop” vid en gräns** | Fogar samman de två zonerna. Syns där de tillsammans bildar en rektangel |
| Dra en gräns | Flyttar den. Zonerna på båda sidor följer med, så inga glapp uppstår |
| Dra en gräns **med ⌥** | Flyttar även den spegelvända gränsen, symmetriskt kring skärmens mitt — för att bredda en mittzon jämnt |
| Dubbelklick på en zon | Delar den där, längs den längre sidan (⌥ vänder riktningen) |
| `V` `H` `⌫` `⌘Z` `R` | Dela, dela åt andra hållet, slå ihop med granne, ångra, börja om |
| `return` / `esc` | Spara och stäng / kasta |

”Fördela kolumnen jämnt” jämnar ut zonerna som ligger ovanpå varandra i samma kolumn (till
exempel fyra längs vänsterkanten); för en rad är det bredderna. Zoner av samma storlek på
annat håll på skärmen lämnas i fred.

”Centrera på skärmen” flyttar en zon så att den ligger symmetriskt kring mittlinjen utan att
storleken ändras. En zon som rör vid skärmkanten kan inte flyttas så, och menyvalet förblir
då avstängt.

Gränser fäster vid andra zoners kanter och vid 1/4, 1/3, 1/2, 2/3 och 3/4. Reglaget
**Mellanrum** längst ned bestämmer avståndet mellan zoner; välj ”Ingen” så ligger fönstren
kant i kant.

### Layouter och historik

**Layouter…** listar varje skärm med om den är ansluten, vad den innehåller och när den
användes sist — inställningar för en skärm du inte längre har syns direkt och kan raderas.

Varje sparning lämnar kvar det föregående läget i `~/.config/waridake/history/`, de tio
senaste versionerna. Vilken som helst kan återställas från listan, och läget före
återställningen arkiveras också, så inget går förlorat.

## Inställningar

Filen är `~/.config/waridake/layout.json` och skapas vid första starten. Det är en helt
vanlig fil — den inbyggda redigeraren är en bekvämlighet, inget krav.

Varje zon skrivs som en **andel mellan 0 och 1** av skärmens arbetsyta (det som menyraden och
Dock lämnar över). `x`/`y` räknas från övre vänstra hörnet, `w`/`h` är bredd och höjd, och
`gap` är mellanrummet mellan zoner i punkter.

Som standard två lika breda kolumner:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Zoner får överlappa; den första som innehåller pekaren vinner.

### Layouter per skärm

Skärmar står under `displays` med sitt UUID som nyckel. Den grafiska redigeraren skriver det
åt dig. Skärmar utan post använder `gap` / `zones` högst upp. `name` och `usedAt` är
bokföring — bara appen skriver dem.

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

Filer utan `displays` läses fortfarande in och gäller överallt.

## Språk

26 språk, valda automatiskt efter dina språkinställningar i macOS — det finns inget att
ställa in.

De flesta är inte skrivna av modersmålstalare, så rättelser är den mest välkomna sortens
pull request. Att lägga till ett språk innebär att kopiera
`Resources/en.lproj/Localizable.strings` till `Resources/<språk>.lproj/`, översätta högersidan
på varje rad och bygga om. Det som lämnas oöversatt faller tillbaka på engelska.

## Så fungerar det

- En global händelsebevakare håller koll på drag med vänsterknappen (det är detta som kräver
  hjälpmedelstillståndet)
- Vid nedtryckning hittas fönstret under pekaren via Accessibility-API:t
- Zonerna visas först när **själva fönstret har rört sig**, så att markera text eller dra en
  fil inuti ett fönster utlöser ingenting
- Släpper du skift försvinner zonerna och draget fortsätter som vanligt

## Felsökning

- **Inga zoner visas** — kontrollera hjälpmedelstillståndet; så länge det saknas visar menyn
  ett val med ⚠️
- **Slutade fungera efter en ombyggnad** — se ”Att tänka på vid ombyggnad”
- **En app vill inte passa in** — den avböjer storleksändringen. Appar med minsta fönsterstorlek,
  däribland vissa Electron-appar, blir större än zonen

## Stöd

Waridake är gratis och kommer att förbli det. Om den sparar dig tid uppskattas stöd via
[GitHub Sponsors](https://github.com/sponsors/omikuji) — det är projektets enda finansiering.

## Licens

MIT-licens.

# Waridake

[English](../README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · **Suomi** · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

macOS-ohjelma, joka asettelee ikkunoita eikä tee muuta kuin jakaa näytön.

*Waridake* (割り竹) tarkoittaa halkaistua bambua: yksi puhdas viilto, ei muuta.

**Mitä se tekee:**

1. Määrität alueet jokaiselle näytölle
2. Pidä **vaihtonäppäintä pohjassa ikkunaa vetäessäsi**, niin alueet ilmestyvät
3. Päästä irti alueen päällä, ja ikkuna asettuu siihen

Ei näppäinoikoteiden ruudukoita, ei ikkunahistoriaa, ei tilauksia. Se asuu valikkorivillä.

> Englanninkielinen [README.md](../README.md) on määräävä. Jos tämä käännös laahaa jäljessä,
> englanninkielinen pätee.

## Asennus

Vaatii Xcoden komentorivityökalut (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Ensimmäisellä käynnistyksellä macOS pyytää käyttöapuoikeutta. Kytke Waridake päälle kohdassa
**Järjestelmäasetukset → Tietosuoja ja turvallisuus → Käyttöapu**. Riittää, että teet sen
ohjelman ollessa käynnissä: se huomaa muutoksen sekunnissa, uudelleenkäynnistystä ei tarvita.

Jos haluat sen käynnistyvän kirjautuessa: Järjestelmäasetukset → Yleiset → Kirjautumiskohteet.

### Huomio uudelleenkäännöksestä

Allekirjoitus on oletuksena tilapäinen, joten **se muuttuu jokaisella käännöksellä ja macOS
peruu oikeuden hiljaisesti** — valintaruutu näyttää päällä olevalta, mutta mikään ei toimi.
Poista Waridake käyttöapuluettelosta ja lisää se uudelleen, tai ratkaise asia lopullisesti
luomalla itse allekirjoitettu koodinallekirjoitusvarmenne (Avainnippu → Varmenneapuri → Luo
varmenne, tyyppi: koodin allekirjoitus) ja käännä sillä:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Käyttö

Kaikki löytyy valikkorivin kuvakkeen alta.

| Valikkokohta | Mitä se tekee |
| --- | --- |
| **Järjestä avoimet ikkunat** | Siirtää jokaisen avoimen ikkunan lähimmälle alueelle. Siivoamiseen, kun ikkunat ovat karanneet |
| **Muokkaa asettelua…** | Graafinen muokkain, kuvattu alla |
| **Asettelut…** | Näyttökohtaiset asettelut viimeisine käyttöpäivineen ja muokkaushistoria |
| **Muokkaa JSON-muodossa…** | Asetustiedosto pelkistetyssä muokkausikkunassa |
| **Lataa asettelu uudelleen** | Lukee tiedoston uudestaan, kun olet muokannut sitä muualla |

Asettelut säilytetään **näyttökohtaisesti**, sillä näytöt eroavat muodoltaan ja kooltaan eikä
yksi jako sovi koskaan kaikille. Näytöt tunnistetaan UUID:n perusteella, joten asetukset
kestävät irrottamisen ja uudelleenkäynnistyksen.

### Graafinen muokkain

**Muokkaa asettelua…** avaa muokkaimen kaikille liitetyille näytöille yhtä aikaa. Muotoile
kukin näyttö erikseen; Tallenna-painike millä tahansa niistä tallentaa kaikki. Koot näkyvät
prosentteina, joten murtolukuja ei tarvitse lukea.

| Toiminto | Mitä se tekee |
| --- | --- |
| **Alueen osoitus hiiren oikealla** | Jaa 2 tai 3 osaan, jaa tasan, keskitä näytölle |
| **Rajan ”Yhdistä”-painike** | Yhdistää nämä kaksi aluetta. Näkyy siellä, missä ne muodostavat suorakulmion |
| Rajan vetäminen | Siirtää rajaa. Molemmin puolin olevat alueet venyvät mukana, joten aukkoja ei synny |
| Rajan vetäminen **⌥ pohjassa** | Siirtää myös peilikuvarajaa symmetrisesti näytön keskikohdan suhteen — keskialueen tasaiseen levittämiseen |
| Alueen kaksoisosoitus | Jakaa sen siitä kohdasta pidemmän sivun suuntaisesti (⌥ kääntää suunnan) |
| `V` `H` `⌫` `⌘Z` `R` | Jaa, jaa toisin päin, yhdistä naapuriin, kumoa, palauta alkutila |
| `return` / `esc` | Tallenna ja sulje / hylkää |

”Jaa tämä sarake tasan” tasoittaa samassa sarakkeessa päällekkäin olevat alueet (esimerkiksi
neljä vasenta reunaa pitkin); rivillä tasoitetaan leveydet. Muualla näytöllä olevat samankokoiset
alueet jäävät rauhaan.

”Keskitä näytölle” siirtää alueen keskiviivan suhteen symmetriseen kohtaan kokoa muuttamatta.
Näytön reunaan koskeva alue ei voi liikkua näin, ja valikkokohta pysyy silloin harmaana.

Rajat tarttuvat muiden alueiden reunoihin sekä kohtiin 1/4, 1/3, 1/2, 2/3 ja 3/4. Alareunan
**Väli** määrää alueiden välisen tilan; valitse ”Ei mitään”, niin ikkunat ovat kiinni toisissaan.

### Asettelut ja historia

**Asettelut…** listaa jokaisen näytön: onko se liitettynä, mitä siinä on ja milloin sitä on
viimeksi käytetty. Näin asetukset näytölle, jota sinulla ei enää ole, erottuvat heti ja ne voi
poistaa.

Jokainen tallennus jättää edellisen tilan kansioon `~/.config/waridake/history/`, viimeiset 10
versiota. Minkä tahansa voi palauttaa luettelosta, ja palautusta edeltävä tila arkistoidaan
myös, joten mitään ei katoa.

## Asetukset

Tiedosto on `~/.config/waridake/layout.json`, ja se syntyy ensimmäisellä käynnistyksellä. Se on
aivan tavallinen tiedosto — sisäänrakennettu muokkain on mukavuus, ei vaatimus.

Jokainen alue kirjoitetaan **osuutena välillä 0–1** näytön työtilasta (siitä, minkä valikkorivi
ja Dock jättävät). `x`/`y` lasketaan vasemmasta yläkulmasta, `w`/`h` ovat leveys ja korkeus, ja
`gap` on alueiden väli pisteinä.

Oletuksena kaksi yhtä leveää saraketta:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Alueet saavat mennä päällekkäin; ensimmäinen, jonka sisällä osoitin on, voittaa.

### Näyttökohtaiset asettelut

Näytöt ovat kohdassa `displays`, avaimena näytön UUID. Graafinen muokkain kirjoittaa sen
puolestasi. Näytöt, joilla ei ole omaa kohtaa, käyttävät ylimmän tason `gap`- ja `zones`-arvoja.
`name` ja `usedAt` ovat kirjanpitoa — vain ohjelma kirjoittaa ne.

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

Tiedostot ilman `displays`-kohtaa latautuvat yhä ja pätevät kaikkialla.

## Kielet

26 kieltä, valitaan automaattisesti macOS:n kieliasetusten mukaan — mitään ei tarvitse säätää.

Useimpia ei ole kirjoittanut äidinkielinen puhuja, joten korjaukset ovat tervetullein
vetopyynnön laji. Kielen lisääminen tarkoittaa, että kopioit tiedoston
`Resources/en.lproj/Localizable.strings` kansioon `Resources/<kieli>.lproj/`, käännät kunkin
rivin oikean puolen ja käännät ohjelman uudelleen. Kääntämättä jäänyt palautuu englanniksi.

## Miten se toimii

- Yleinen tapahtumavalvoja seuraa vetoja hiiren vasemmalla painikkeella (juuri tämä vaatii
  käyttöapuoikeuden)
- Painalluksen hetkellä osoittimen alla oleva ikkuna löydetään käyttöapurajapinnan kautta
- Alueet ilmestyvät vasta, kun **ikkuna itse on liikkunut**, joten tekstin valitseminen tai
  tiedoston vetäminen ikkunan sisällä ei laukaise mitään
- Kun päästät vaihtonäppäimen, alueet katoavat ja veto jatkuu tavalliseen tapaan

## Vianetsintä

- **Alueita ei ilmesty** — tarkista käyttöapuoikeus; niin kauan kuin se puuttuu, valikossa on
  ⚠️-merkitty kohta
- **Lakkasi toimimasta uudelleenkäännöksen jälkeen** — katso ”Huomio uudelleenkäännöksestä”
- **Yksi ohjelma ei asetu** — se kieltäytyy koon muutoksesta. Ohjelmat, joilla on vähimmäiskoko
  ikkunalle, muun muassa jotkin Electron-ohjelmat, jäävät aluetta suuremmiksi

## Tuki

Waridake on ilmainen ja pysyy sellaisena. Jos se säästää aikaasi, tuki
[GitHub Sponsorsin](https://github.com/sponsors/omikuji) kautta on arvossaan — se on hankkeen
ainoa rahoitus.

## Lisenssi

MIT-lisenssi.

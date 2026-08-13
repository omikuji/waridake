# Waridake

[English](../README.md) · [العربية](README.ar.md) · **Čeština** · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Rozmisťovač oken pro macOS, který nedělá nic jiného, než že dělí obrazovku.

*Waridake* (割り竹) znamená „rozštípnutý bambus“ — jeden čistý řez a nic víc.

**Co umí:**

1. Pro každý displej si určíte zóny
2. Při tažení okna podržte **Shift** a zóny se objeví
3. Pusťte nad zónou a okno do ní zapadne

Žádné mřížky klávesových zkratek, žádná historie oken, žádné předplatné. Bydlí v řádku
nabídek.

> Rozhodující je anglický [README.md](../README.md). Pokud tento překlad zaostává, platí
> anglická verze.

## Instalace

Vyžaduje nástroje příkazové řádky Xcode (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Při prvním spuštění si macOS vyžádá souhlas se zpřístupněním. Zapněte Waridake v
**Nastavení systému → Soukromí a zabezpečení → Zpřístupnění**. Stačí to udělat za běhu
aplikace: všimne si toho do vteřiny, restart není potřeba.

Aby se spouštěl po přihlášení: Nastavení systému → Obecné → Položky přihlášení.

### Poznámka k opětovnému sestavení

Podpis je ve výchozím stavu ad hoc, takže **se při každém sestavení mění a macOS souhlas
tiše odebere** — zaškrtnutí zůstává, ale nic nefunguje. Odeberte Waridake ze seznamu a
přidejte jej znovu, nebo to vyřešte natrvalo: v Klíčence vytvořte vlastní certifikát pro
podepisování kódu (Průvodce certifikací → Vytvořit certifikát, typ: podepisování kódu) a
sestavujte s ním:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Používání

Všechno je pod ikonou v řádku nabídek.

| Položka nabídky | Co dělá |
| --- | --- |
| **Uspořádat otevřená okna** | Vloží každé otevřené okno do nejbližší zóny. K úklidu, když se okna rozjela |
| **Upravit rozvržení…** | Grafický editor, popsaný níže |
| **Rozvržení…** | Rozvržení podle displeje s datem posledního použití a historie úprav |
| **Upravit jako JSON…** | Konfigurační soubor v prostém okně |
| **Znovu načíst rozvržení** | Přečte soubor znovu poté, co jste jej upravili jinde |

Rozvržení se drží **zvlášť pro každý displej**, protože obrazovky se liší tvarem i velikostí
a jedno rozdělení nikdy nesedne všem. Displeje se poznávají podle UUID, takže nastavení
přežije odpojení i restart.

### Grafický editor

**Upravit rozvržení…** otevře editor naráz na všech připojených displejích. Každou obrazovku
tvarujete zvlášť; stisk Uložit na kterékoli z nich uloží všechny. Velikosti se ukazují v
procentech, takže zlomky nikdo číst nemusí.

| Úkon | Co dělá |
| --- | --- |
| **Pravý klik na zónu** | Rozdělit na 2 nebo 3, rovnoměrně rozložit, vystředit |
| **Tlačítko „Sloučit“ na hranici** | Spojí ty dvě zóny. Objeví se všude, kde spolu tvoří obdélník |
| Tažení hranice | Posune ji. Zóny po obou stranách se natáhnou s ní, takže nevzniknou díry |
| Tažení hranice **s ⌥** | Posune i zrcadlovou hranici symetricky podle středu obrazovky — pro rovnoměrné rozšíření prostřední zóny |
| Dvojklik na zónu | Rozdělí ji v tom místě podél delší strany (⌥ obrátí směr) |
| `V` `H` `⌫` `⌘Z` `R` | Rozdělit, rozdělit opačně, sloučit se sousedem, zpět, výchozí stav |
| `return` / `esc` | Uložit a zavřít / zahodit |

„Rovnoměrně rozdělit tento sloupec“ srovná zóny naskládané v témže sloupci (třeba čtyři podél
levého okraje); u řádku srovná šířky. Stejně velké zóny jinde na obrazovce zůstanou nedotčené.

„Vystředit na obrazovce“ posune zónu tak, aby ležela souměrně kolem střední osy, aniž by se
změnila její velikost. Zóna dotýkající se okraje obrazovky se takto posunout nemůže a položka
nabídky zůstane nedostupná.

Hranice se přichytávají k okrajům ostatních zón a k 1/4, 1/3, 1/2, 2/3 a 3/4. Ovládací prvek
**Mezera** dole určuje odstup mezi zónami; volbou „Žádná“ budou okna těsně u sebe.

### Rozvržení a historie

**Rozvržení…** vypíše každý displej s tím, zda je připojen, co obsahuje a kdy byl naposledy
použit — nastavení monitoru, který už nemáte, tak bije do očí a dá se smazat.

Každé uložení nechá předchozí stav v `~/.config/waridake/history/`, posledních 10 verzí.
Kteroukoli lze ze seznamu obnovit a stav před obnovením se rovněž archivuje, takže se nic
neztratí.

## Konfigurace

Soubor je `~/.config/waridake/layout.json` a vzniká při prvním spuštění. Je to obyčejný
soubor — vestavěný editor je pohodlí, ne podmínka.

Každá zóna se zapisuje jako **zlomek mezi 0 a 1** pracovní plochy obrazovky (toho, co zbude po
řádku nabídek a Docku). `x`/`y` se počítají od levého horního rohu, `w`/`h` jsou šířka a výška
a `gap` je mezera mezi zónami v bodech.

Výchozí jsou dva stejné sloupce:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Zóny se smějí překrývat; vyhrává první, v níž se ocitne ukazatel.

### Rozvržení podle displeje

Displeje patří pod `displays`, klíčem je UUID displeje. Grafický editor to zapíše za vás.
Displeje bez záznamu použijí `gap` / `zones` shora. `name` a `usedAt` jsou jen evidence —
zapisuje je pouze aplikace.

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

Soubory bez `displays` se stále načtou a platí všude.

## Jazyky

26 jazyků, vybírají se automaticky podle jazykového nastavení macOS — není co nastavovat.

Většinu z nich nepsali rodilí mluvčí, takže opravy jsou nejvítanějším druhem pull requestu.
Přidat jazyk znamená zkopírovat `Resources/en.lproj/Localizable.strings` do
`Resources/<jazyk>.lproj/`, přeložit pravou stranu každého řádku a znovu sestavit. Co zůstane
nepřeložené, spadne zpět na angličtinu.

## Jak to funguje

- Globální sledovač událostí hlídá tažení levým tlačítkem (právě proto je potřeba souhlas se
  zpřístupněním)
- Při stisku se okno pod ukazatelem najde přes Accessibility API
- Zóny se objeví, teprve když **se pohne samo okno**, takže výběr textu ani tažení souboru
  uvnitř okna nic nespustí
- Puštěním Shiftu zóny zmizí a tažení pokračuje jako obvykle

## Když něco nefunguje

- **Neobjevují se žádné zóny** — zkontrolujte souhlas; dokud chybí, nabídka ukazuje položku s ⚠️
- **Po novém sestavení to přestalo fungovat** — viz „Poznámka k opětovnému sestavení“
- **Jedna aplikace se nevejde** — odmítá změnu velikosti. Aplikace s minimální velikostí okna,
  včetně některých postavených na Electronu, zůstanou větší než zóna

## Podpora

Waridake je zdarma a zůstane. Pokud vám šetří čas, podpora přes
[GitHub Sponsors](https://github.com/sponsors/omikuji) potěší — je to jediné financování
projektu.

Dotazy, problémy i nápady vítám:

- [X (@omikuji_man)](https://x.com/omikuji_man)
- [Kontaktní formulář](https://omikuji.dev/contact/)
- [Nahlásit na GitHubu](https://github.com/omikuji/waridake/issues)

## Licence

Licence MIT.

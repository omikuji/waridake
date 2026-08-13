# Waridake

[English](README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · **Polski** · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Program dla macOS, który układa okna i nie robi nic poza dzieleniem ekranu.

*Waridake* (割り竹) znaczy „rozłupany bambus” — jedno czyste cięcie i nic więcej.

**Co potrafi:**

1. Ustalasz strefy dla każdego ekranu
2. Przytrzymaj **Shift podczas przeciągania okna** — pojawią się strefy
3. Puść nad strefą, a okno w nią wskoczy

Żadnych siatek skrótów, żadnej historii okien, żadnych abonamentów. Mieszka na pasku
menu.

> Wersją źródłową jest angielski [README.md](README.md). Jeśli to tłumaczenie zostaje
> w tyle, obowiązuje tamten.

## Instalacja

Wymaga narzędzi wiersza poleceń Xcode (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Przy pierwszym uruchomieniu macOS poprosi o zgodę na dostępność. Włącz Waridake w
**Ustawieniach systemowych → Prywatność i ochrona → Dostępność**. Wystarczy zrobić to
przy działającym programie: zauważy w ciągu sekundy, restart nie jest potrzebny.

Aby uruchamiał się przy logowaniu: Ustawienia systemowe → Ogólne → Elementy logowania.

### Uwaga o ponownym budowaniu

Domyślnie podpis jest doraźny, więc **przy każdej kompilacji się zmienia, a macOS po
cichu odbiera zgodę** — pole zostaje zaznaczone, ale nic nie działa. Usuń Waridake z
listy Dostępności i dodaj ponownie albo rozwiąż to raz na zawsze: utwórz własny
certyfikat do podpisywania kodu (Dostęp do pęku kluczy → Asystent certyfikatów →
Utwórz certyfikat, typ: podpisywanie kodu) i buduj z nim:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Obsługa

Wszystko kryje się pod ikoną na pasku menu.

| Pozycja menu | Co robi |
| --- | --- |
| **Uporządkuj otwarte okna** | Wstawia każde otwarte okno do najbliższej strefy. Do posprzątania, gdy okna się rozjechały |
| **Edytuj układ…** | Edytor graficzny, opisany niżej |
| **Układy…** | Układy dla poszczególnych ekranów z datą ostatniego użycia oraz historia zmian |
| **Edytuj jako JSON…** | Plik konfiguracyjny w prostym oknie edycji |
| **Wczytaj układ ponownie** | Czyta plik na nowo po edycji gdzie indziej |

Układy trzymane są **osobno dla każdego ekranu**, bo ekrany różnią się kształtem i
rozmiarem, a jeden podział nigdy nie pasuje do wszystkich. Ekrany rozpoznawane są po
UUID, więc ustawienia przetrwają odłączenie i ponowne uruchomienie.

### Edytor graficzny

**Edytuj układ…** otwiera edytor naraz na wszystkich podłączonych ekranach. Każdy
ekran układasz osobno; naciśnięcie Zapisz na dowolnym z nich zapisuje wszystkie.
Rozmiary podane są w procentach, więc nikt nie musi czytać ułamków.

| Czynność | Co robi |
| --- | --- |
| **Prawy klik na strefie** | Podział na 2 lub 3, równe rozłożenie, wyśrodkowanie |
| **Przycisk „Scal” na granicy** | Łączy te dwie strefy. Pojawia się tam, gdzie razem tworzą prostokąt |
| Przeciągnięcie granicy | Przesuwa ją. Strefy po obu stronach rozciągają się razem, więc nie powstają dziury |
| Przeciągnięcie granicy **z ⌥** | Przesuwa też granicę lustrzaną względem środka ekranu — by równo poszerzyć strefę środkową |
| Dwuklik na strefie | Tnie ją w tym miejscu wzdłuż dłuższego boku (⌥ odwraca kierunek) |
| `V` `H` `⌫` `⌘Z` `R` | Podziel, podziel na odwrót, scal z sąsiadem, cofnij, przywróć początek |
| `return` / `esc` | Zapisz i zamknij / odrzuć |

„Rozłóż tę kolumnę równo” wyrównuje strefy ułożone jedna nad drugą w tej samej kolumnie
(na przykład cztery przy lewej krawędzi); w wierszu wyrównuje szerokości. Strefy tej
samej wielkości w innym miejscu ekranu pozostają nietknięte.

„Wyśrodkuj na ekranie” przesuwa strefę tak, by leżała symetrycznie względem osi środkowej,
nie zmieniając jej rozmiaru. Strefa dotykająca krawędzi ekranu nie może się tak przesunąć
i pozycja menu pozostaje wyszarzona.

Granice przyciągają się do krawędzi innych stref oraz do 1/4, 1/3, 1/2, 2/3 i 3/4.
Ustawienie **Odstęp** na dole określa przerwę między strefami; wybierz „Brak”, a okna będą
przylegać do siebie.

### Układy i historia

**Układy…** wypisuje każdy ekran wraz z tym, czy jest podłączony, co zawiera i kiedy był
ostatnio używany — ustawienia monitora, którego już nie masz, od razu rzucają się w oczy i
można je usunąć.

Każdy zapis zostawia poprzedni stan w `~/.config/waridake/history/`, ostatnie 10 wersji.
Każdą można przywrócić z listy, a stan sprzed przywrócenia też trafia do archiwum, więc nic
nie ginie.

## Konfiguracja

Plik to `~/.config/waridake/layout.json`, tworzony przy pierwszym uruchomieniu. To zwykły
plik — wbudowany edytor jest wygodą, nie wymogiem.

Każdą strefę zapisuje się jako **ułamek od 0 do 1** obszaru roboczego ekranu (tego, co
zostawiają pasek menu i Dock). `x`/`y` liczą się od lewego górnego rogu, `w`/`h` to
szerokość i wysokość, a `gap` to odstęp między strefami w punktach.

Domyślnie są to dwie równe kolumny:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Strefy mogą na siebie zachodzić; wygrywa pierwsza, w której znajdzie się wskaźnik.

### Układy dla ekranów

Ekrany trafiają do `displays`, kluczem jest UUID ekranu. Edytor graficzny zapisze to za
ciebie. Ekrany bez wpisu używają `gap` / `zones` z góry. `name` i `usedAt` to zapiski
programu — pisze je tylko on.

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

Pliki bez `displays` nadal się wczytują i obowiązują wszędzie.

## Języki

26 języków, wybieranych automatycznie na podstawie ustawień języka w macOS — nie ma czego
konfigurować.

Większość nie została napisana przez rodzimych użytkowników, więc poprawki to najbardziej
mile widziany rodzaj pull requesta. Dodanie języka to skopiowanie
`Resources/en.lproj/Localizable.strings` do `Resources/<język>.lproj/`, przetłumaczenie
prawej strony każdego wiersza i ponowna kompilacja. Nieprzetłumaczone wpisy wracają do
angielskiego.

## Jak to działa

- Globalny monitor zdarzeń obserwuje przeciąganie lewym przyciskiem (to właśnie wymaga
  zgody na dostępność)
- Po naciśnięciu okno pod wskaźnikiem znajdowane jest przez Accessibility API
- Strefy pojawiają się dopiero wtedy, gdy **samo okno się poruszy**, więc zaznaczanie
  tekstu ani przeciąganie pliku w oknie niczego nie wywoła
- Puszczenie Shiftu chowa strefy, a przeciąganie toczy się dalej normalnie

## Rozwiązywanie problemów

- **Strefy się nie pojawiają** — sprawdź zgodę na dostępność; dopóki jej brak, w menu widać
  pozycję z ⚠️
- **Przestało działać po przebudowaniu** — patrz „Uwaga o ponownym budowaniu”
- **Jeden program nie wchodzi w strefę** — odmawia zmiany rozmiaru. Programy z minimalnym
  rozmiarem okna, w tym część opartych na Electronie, zostaną większe niż strefa

## Wsparcie

Waridake jest darmowy i taki pozostanie. Jeśli oszczędza ci czas, wsparcie przez
[GitHub Sponsors](https://github.com/sponsors/omikuji) będzie mile widziane — to jedyne
finansowanie projektu.

## Licencja

Licencja MIT.

# Waridake

[English](../README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · **Italiano** · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Uno strumento macOS che dispone le finestre e non fa altro che dividere lo schermo.

*Waridake* (割り竹) significa «bambù spaccato»: un taglio netto, nient’altro.

**Cosa fa:**

1. Definisci le zone per ogni schermo
2. Tieni premuto **Maiuscole mentre trascini una finestra** e compaiono le zone
3. Rilascia su una zona e la finestra ci si incastra

Niente griglie di scorciatoie, niente cronologia delle finestre, niente abbonamenti.
Vive nella barra dei menu.

> Fa fede la versione inglese [README.md](../README.md). Se questa traduzione resta
> indietro, vale quella.

## Installazione

Servono gli strumenti da riga di comando di Xcode (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Al primo avvio macOS chiede il permesso di accessibilità. Attiva Waridake in
**Impostazioni di Sistema → Privacy e sicurezza → Accessibilità**. Concederlo con
l’app già avviata basta: se ne accorge in un secondo, non serve riavviarla.

Per aprirlo al login: Impostazioni di Sistema → Generali → Elementi login.

### Nota sulle ricompilazioni

La firma predefinita è ad hoc, quindi **cambia a ogni compilazione e macOS toglie il
permesso in silenzio**: la casella resta spuntata ma non funziona più niente.
Togli Waridake dall’elenco Accessibilità e rimettilo, oppure risolvi alla radice
creando un certificato di firma del codice autofirmato (Accesso Portachiavi →
Assistente Certificazione → Crea un certificato, tipo: firma del codice) e
compilando con quello:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Uso

Tutto sta sotto l’icona nella barra dei menu.

| Voce di menu | Cosa fa |
| --- | --- |
| **Disponi le finestre aperte** | Mette ogni finestra aperta nella zona più vicina. Per rimettere ordine quando sono scivolate |
| **Modifica layout…** | L’editor visuale, descritto qui sotto |
| **Layout…** | I layout per schermo con la data d’uso, e la cronologia |
| **Modifica come JSON…** | Il file di configurazione, in una semplice finestra di modifica |
| **Ricarica il layout** | Rilegge il file dopo averlo modificato altrove |

I layout sono tenuti **per schermo**, perché gli schermi differiscono per forma e
dimensione e una sola divisione non va bene per tutti. Gli schermi sono riconosciuti
dal loro UUID, quindi le impostazioni sopravvivono a scollegamenti e riavvii.

### L’editor visuale

**Modifica layout…** apre un editor su tutti gli schermi collegati insieme. Dai forma
a ciascuno separatamente; premere Salva su uno qualsiasi li salva tutti. Le dimensioni
sono in percentuale, così non serve leggere frazioni.

| Azione | Cosa fa |
| --- | --- |
| **Clic destro su una zona** | Dividere in 2 o 3, distribuire, centrare sullo schermo |
| **Pulsante «Unisci» su un bordo** | Riunisce le due zone. Compare dove insieme formano un rettangolo |
| Trascinare un bordo | Lo sposta. Le zone ai due lati si allungano, quindi non si aprono buchi |
| **⌥ + trascinamento** di un bordo | Sposta anche il bordo simmetrico rispetto al centro dello schermo, per allargare una zona centrale in modo uniforme |
| Doppio clic su una zona | La taglia in quel punto lungo il lato più lungo (⌥ inverte il verso) |
| `V` `H` `⌫` `⌘Z` `R` | Dividere, dividere nell’altro senso, unire a una vicina, annullare, azzerare |
| `return` / `esc` | Salvare e chiudere / scartare |

«Distribuisci questa colonna» pareggia le zone impilate nella stessa colonna (per
esempio quattro lungo il bordo sinistro); per una riga pareggia le larghezze. Le zone
della stessa misura altrove sullo schermo restano intatte.

«Centra sullo schermo» sposta una zona perché stia simmetrica rispetto all’asse
centrale, senza cambiarne la dimensione. Una zona che tocca il bordo dello schermo non
può muoversi così, e la voce di menu resta disattivata.

I bordi si agganciano a quelli delle altre zone e a 1/4, 1/3, 1/2, 2/3 e 3/4. Il
controllo **Spazio** in basso regola la distanza tra le zone; scegli «Nessuno» perché
le finestre si tocchino.

### Layout e cronologia

**Layout…** elenca ogni schermo con lo stato del collegamento, il contenuto e l’ultimo
uso: le impostazioni di un monitor che non hai più saltano all’occhio e si cancellano.

Ogni salvataggio conserva lo stato precedente in `~/.config/waridake/history/`, le
ultime 10 versioni. Ognuna si può ripristinare dall’elenco, e anche lo stato prima del
ripristino viene archiviato, quindi non si perde nulla.

## Configurazione

Il file è `~/.config/waridake/layout.json`, creato al primo avvio. È un file normale:
l’editor integrato è una comodità, non un obbligo.

Ogni zona si scrive come **frazione tra 0 e 1** dell’area utile dello schermo (quel che
lasciano barra dei menu e Dock). `x`/`y` partono in alto a sinistra, `w`/`h` sono
larghezza e altezza, `gap` è lo spazio tra le zone in punti.

Di default, due colonne uguali:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Le zone possono sovrapporsi; vince la prima che contiene il puntatore.

### Layout per schermo

Gli schermi stanno sotto `displays`, con l’UUID come chiave. L’editor visuale lo scrive
per te. Gli schermi senza voce usano i `gap` / `zones` in cima. `name` e `usedAt` sono
annotazioni: le scrive solo l’app.

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

I file senza `displays` continuano a caricarsi e valgono ovunque.

## Lingue

26 lingue, scelte automaticamente in base alle impostazioni di lingua di macOS: non c’è
nulla da configurare.

La maggior parte non è stata scritta da madrelingua, quindi le correzioni sono il tipo
di pull request più gradito. Aggiungere una lingua vuol dire copiare
`Resources/en.lproj/Localizable.strings` in `Resources/<lingua>.lproj/`, tradurre la
parte destra di ogni riga e ricompilare. Ciò che resta non tradotto ricade sull’inglese.

## Come funziona

- Un monitor globale degli eventi osserva i trascinamenti col tasto sinistro (è questo
  a richiedere il permesso di accessibilità)
- Alla pressione, la finestra sotto il puntatore si trova con l’API di accessibilità
- Le zone compaiono solo quando **la finestra stessa si è mossa**: selezionare testo o
  trascinare un file dentro una finestra non fa scattare nulla
- Rilasciando Maiuscole le zone spariscono e il trascinamento prosegue normale

## Se qualcosa non va

- **Non compare nessuna zona**: controlla il permesso di accessibilità; finché manca, il
  menu mostra una voce con ⚠️
- **Ha smesso di funzionare dopo una ricompilazione**: vedi «Nota sulle ricompilazioni»
- **Un’app non si adatta**: sta rifiutando il ridimensionamento. Le app con una
  dimensione minima, comprese alcune Electron, restano più grandi della zona

## Sostegno

Waridake è gratuito e lo resterà. Se ti fa risparmiare tempo, un sostegno tramite
[GitHub Sponsors](https://github.com/sponsors/omikuji) è gradito: è l’unico
finanziamento del progetto.

## Licenza

Licenza MIT.

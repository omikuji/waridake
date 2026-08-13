# Waridake

[English](README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · **Français** · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Un outil de placement de fenêtres pour macOS qui ne fait que découper l’écran.

*Waridake* (割り竹) signifie « bambou fendu » — une coupe nette, rien de plus.

**Ce qu’il fait :**

1. Vous définissez des zones pour chaque écran
2. Maintenez **Maj pendant que vous déplacez une fenêtre** : les zones apparaissent
3. Relâchez sur une zone et la fenêtre s’y place

Pas de grille de raccourcis, pas d’historique des fenêtres, pas d’abonnement.
Il vit dans la barre des menus.

> La version anglaise [README.md](README.md) fait foi. Si cette traduction est en
> retard, c’est elle qui prime.

## Installation

Nécessite les outils en ligne de commande Xcode (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Au premier lancement, macOS demande l’autorisation d’accessibilité. Activez
Waridake dans **Réglages Système → Confidentialité et sécurité → Accessibilité**.
L’accorder pendant que l’app tourne suffit : elle s’en aperçoit en une seconde,
inutile de relancer.

Pour un lancement à l’ouverture de session : Réglages Système → Général →
Ouverture.

### À propos des reconstructions

La signature est ad hoc par défaut, donc **elle change à chaque compilation et
macOS retire discrètement l’autorisation** — la case reste cochée, mais plus rien
ne fonctionne. Retirez Waridake de la liste Accessibilité puis rajoutez-le, ou
réglez le problème définitivement en créant un certificat de signature de code
auto-signé (Trousseaux d’accès → Assistant de certification → Créer un certificat,
type : signature de code) et en compilant avec :

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Utilisation

Tout se trouve sous l’icône de la barre des menus.

| Élément de menu | Ce qu’il fait |
| --- | --- |
| **Ranger les fenêtres ouvertes** | Place chaque fenêtre ouverte dans la zone la plus proche. Pour remettre de l’ordre quand elles ont dérivé |
| **Modifier la disposition…** | L’éditeur visuel, décrit plus bas |
| **Dispositions…** | Les dispositions par écran avec leur dernière utilisation, et l’historique |
| **Modifier le JSON…** | Le fichier de configuration, dans une fenêtre d’édition simple |
| **Recharger la disposition** | Relit le fichier après une modification ailleurs |

Les dispositions sont conservées **par écran**, car les écrans diffèrent en forme
et en taille et un même découpage ne convient jamais à tous. Les écrans sont
identifiés par leur UUID : les réglages survivent aux débranchements et redémarrages.

### L’éditeur visuel

**Modifier la disposition…** ouvre un éditeur sur tous les écrans connectés à la
fois. Façonnez chaque écran séparément ; Enregistrer sur l’un d’eux les enregistre
tous. Les tailles s’affichent en pourcentage, personne n’a donc à lire de fractions.

| Action | Ce qu’elle fait |
| --- | --- |
| **Clic droit sur une zone** | Diviser en 2 ou 3, répartir, centrer sur l’écran |
| **Bouton « Fusionner » sur une limite** | Réunit les deux zones. Présent partout où elles forment un rectangle |
| Faire glisser une limite | La déplace. Les zones des deux côtés suivent, aucun trou n’apparaît |
| **⌥ + glisser** une limite | Déplace aussi la limite symétrique par rapport au centre de l’écran — pour élargir une zone centrale de façon égale |
| Double-clic sur une zone | La coupe à cet endroit, le long du côté le plus long (⌥ inverse le sens) |
| `V` `H` `⌫` `⌘Z` `R` | Diviser, diviser dans l’autre sens, fusionner avec une voisine, annuler, réinitialiser |
| `return` / `esc` | Enregistrer et fermer / abandonner |

« Répartir cette colonne » égalise les zones empilées dans une même colonne (par
exemple quatre zones le long du bord gauche) ; pour une rangée, ce sont les largeurs.
Les zones de même taille ailleurs sur l’écran ne sont pas touchées.

« Centrer sur l’écran » déplace une zone pour qu’elle soit symétrique par rapport à
l’axe central, sans changer sa taille. Une zone qui touche le bord de l’écran ne
peut pas bouger ainsi : l’élément de menu reste alors désactivé.

Les limites s’aimantent aux bords des autres zones et à 1/4, 1/3, 1/2, 2/3 et 3/4.
Le réglage **Écart** en bas fixe l’espace entre les zones ; choisissez « Aucun »
pour que les fenêtres se touchent.

### Dispositions et historique

**Dispositions…** liste chaque écran avec son état de connexion, son contenu et sa
dernière utilisation : les réglages d’un moniteur que vous n’avez plus se repèrent
et se suppriment facilement.

Chaque enregistrement conserve l’état précédent dans `~/.config/waridake/history/`,
les 10 dernières versions. Chacune peut être restaurée depuis la liste, et l’état
d’avant la restauration est archivé lui aussi : rien n’est perdu.

## Configuration

Le fichier est `~/.config/waridake/layout.json`, créé au premier lancement. C’est un
fichier ordinaire — l’éditeur intégré est un confort, pas une obligation.

Chaque zone s’écrit comme une **fraction entre 0 et 1** de la zone utile de l’écran
(ce que laissent la barre des menus et le Dock). `x`/`y` partent du coin supérieur
gauche, `w`/`h` sont la largeur et la hauteur, `gap` est l’écart entre zones en points.

Par défaut, deux colonnes égales :

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Les zones peuvent se chevaucher ; la première contenant le pointeur l’emporte.

### Dispositions par écran

Les écrans se rangent sous `displays`, avec leur UUID pour clé. L’éditeur visuel
l’écrit pour vous. Les écrans sans entrée utilisent les `gap` / `zones` du haut.
`name` et `usedAt` ne servent qu’au suivi — seule l’app les écrit.

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

Les fichiers sans `displays` se chargent toujours et s’appliquent partout.

## Langues

26 langues, choisies automatiquement d’après vos réglages de langue macOS — il n’y
a rien à configurer.

La plupart n’ont pas été écrites par des locuteurs natifs : les corrections sont le
type de pull request le plus bienvenu. Ajouter une langue consiste à copier
`Resources/en.lproj/Localizable.strings` vers `Resources/<langue>.lproj/`, à traduire
la partie droite de chaque ligne, puis à recompiler. Ce qui n’est pas traduit
retombe sur l’anglais.

## Fonctionnement

- Un moniteur d’événements global observe les glissements au bouton gauche (c’est ce
  qui exige l’autorisation d’accessibilité)
- Au clic, la fenêtre sous le pointeur est trouvée via l’API d’accessibilité
- Les zones n’apparaissent qu’une fois que **la fenêtre elle-même a bougé** :
  sélectionner du texte ou faire glisser un fichier ne déclenche donc rien
- Relâcher Maj masque les zones et laisse le glissement se poursuivre normalement

## Dépannage

- **Aucune zone n’apparaît** — vérifiez l’autorisation d’accessibilité ; tant qu’elle
  manque, le menu affiche un élément ⚠️
- **Plus rien ne marche après une recompilation** — voir « À propos des reconstructions »
- **Une app refuse de se placer** — elle décline le redimensionnement. Les apps ayant
  une taille minimale, dont certaines apps Electron, dépassent la zone

## Soutien

Waridake est gratuit et le restera. S’il vous fait gagner du temps, le soutenir via
[GitHub Sponsors](https://github.com/sponsors/omikuji) est apprécié : c’est le seul
financement du projet.

## Licence

Licence MIT.

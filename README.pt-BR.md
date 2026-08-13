# Waridake

[English](README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · **Português** · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Um organizador de janelas para macOS que só divide a tela.

*Waridake* (割り竹) quer dizer “bambu partido” — um corte limpo, nada mais.

**O que ele faz:**

1. Você define zonas para cada tela
2. Segure **Shift enquanto arrasta uma janela** e as zonas aparecem
3. Solte sobre uma zona e a janela se encaixa

Sem grades de atalhos, sem histórico de janelas, sem assinatura. Ele mora na barra
de menus.

> A versão em inglês [README.md](README.md) é a de referência. Se esta tradução
> ficar para trás, vale aquela.

## Instalação

Requer as ferramentas de linha de comando do Xcode (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

No primeiro uso o macOS pede permissão de acessibilidade. Ative o Waridake em
**Ajustes do Sistema → Privacidade e Segurança → Acessibilidade**. Conceder com o app
já aberto basta: ele percebe em um segundo, não precisa reiniciar.

Para abrir ao iniciar a sessão: Ajustes do Sistema → Geral → Itens de Início.

### Sobre recompilar

Por padrão a assinatura é ad hoc, então **ela muda a cada compilação e o macOS tira a
permissão sem avisar** — a caixa continua marcada, mas nada funciona. Remova o
Waridake da lista de Acessibilidade e adicione de novo, ou resolva de vez criando um
certificado de assinatura de código autoassinado (Acesso às Chaves → Assistente de
Certificados → Criar um certificado, tipo: assinatura de código) e compilando com ele:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Como usar

Tudo fica sob o ícone da barra de menus.

| Item de menu | O que faz |
| --- | --- |
| **Organizar janelas abertas** | Coloca cada janela aberta na zona mais próxima. Para arrumar quando elas saíram do lugar |
| **Editar layout…** | O editor visual, descrito abaixo |
| **Layouts…** | Os layouts por tela com a data do último uso, e o histórico |
| **Editar como JSON…** | O arquivo de configuração, numa janela de edição simples |
| **Recarregar layout** | Lê o arquivo de novo depois de editá-lo por fora |

Os layouts são guardados **por tela**, porque telas diferem em formato e tamanho e uma
mesma divisão nunca serve para todas. As telas são identificadas pelo UUID, então os
ajustes sobrevivem a desconexões e reinicializações.

### O editor visual

**Editar layout…** abre um editor em todas as telas conectadas ao mesmo tempo. Molde
cada uma separadamente; apertar Salvar em qualquer uma salva todas. Os tamanhos
aparecem em porcentagem, então ninguém precisa ler frações.

| Ação | O que faz |
| --- | --- |
| **Clique direito numa zona** | Dividir em 2 ou 3, distribuir, centralizar na tela |
| **Botão “Juntar” numa divisa** | Une as duas zonas. Aparece onde as duas formam um retângulo |
| Arrastar uma divisa | Move a divisa. As zonas dos dois lados acompanham, então não abrem buracos |
| **⌥ + arrastar** uma divisa | Move também a divisa espelhada em relação ao centro da tela — para alargar uma zona central por igual |
| Clique duplo numa zona | Corta ali, no lado mais comprido (⌥ inverte a direção) |
| `V` `H` `⌫` `⌘Z` `R` | Dividir, dividir ao contrário, juntar com a vizinha, desfazer, recomeçar |
| `return` / `esc` | Salvar e fechar / descartar |

“Distribuir esta coluna” iguala as zonas empilhadas na mesma coluna (quatro ao longo da
borda esquerda, por exemplo); numa linha, iguala as larguras. Zonas do mesmo tamanho em
outro canto da tela ficam como estão.

“Centralizar na tela” move a zona para que fique simétrica em relação ao eixo central,
sem mudar de tamanho. Uma zona encostada na borda da tela não consegue se mover assim, e
o item do menu fica desativado.

As divisas grudam nas bordas das outras zonas e em 1/4, 1/3, 1/2, 2/3 e 3/4. O controle
**Espaço** embaixo define a distância entre zonas; escolha “Nenhum” para as janelas
ficarem coladas.

### Layouts e histórico

**Layouts…** lista cada tela com o estado da conexão, o conteúdo e o último uso — assim
os ajustes de um monitor que você não tem mais saltam aos olhos e podem ser apagados.

Cada vez que você salva, o estado anterior fica em `~/.config/waridake/history/`, as 10
últimas versões. Qualquer uma pode ser restaurada pela lista, e o estado de antes da
restauração também é guardado, então nada se perde.

## Configuração

O arquivo é `~/.config/waridake/layout.json`, criado no primeiro uso. É um arquivo
comum — o editor embutido é conveniência, não exigência.

Cada zona é escrita como **fração entre 0 e 1** da área útil da tela (o que a barra de
menus e o Dock deixam livre). `x`/`y` começam no canto superior esquerdo, `w`/`h` são
largura e altura, e `gap` é o espaço entre zonas em pontos.

O padrão são duas colunas iguais:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

As zonas podem se sobrepor; vence a primeira que contiver o ponteiro.

### Layouts por tela

As telas ficam em `displays`, com o UUID como chave. O editor visual escreve isso para
você. Telas sem entrada usam o `gap` / `zones` de cima. `name` e `usedAt` são anotações
— só o app escreve.

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

Arquivos sem `displays` continuam carregando e valem para todas as telas.

## Idiomas

26 idiomas, escolhidos automaticamente pelos ajustes de idioma do macOS — não há nada
para configurar.

A maioria não foi escrita por falantes nativos, então correções são o tipo de pull
request mais bem-vindo. Adicionar um idioma é copiar
`Resources/en.lproj/Localizable.strings` para `Resources/<idioma>.lproj/`, traduzir o
lado direito de cada linha e recompilar. O que ficar sem tradução cai no inglês.

## Como funciona

- Um monitor global de eventos observa os arrastes com o botão esquerdo (é isso que
  exige a permissão de acessibilidade)
- Ao pressionar, a janela sob o ponteiro é encontrada pela API de acessibilidade
- As zonas só aparecem depois que **a própria janela se moveu**, então selecionar texto
  ou arrastar um arquivo dentro de uma janela não dispara nada
- Ao soltar Shift as zonas somem e o arraste segue normalmente

## Problemas comuns

- **Nenhuma zona aparece** — confira a permissão de acessibilidade; enquanto faltar, o
  menu mostra um item com ⚠️
- **Parou de funcionar depois de recompilar** — veja “Sobre recompilar”
- **Um app não se encaixa** — ele está recusando o redimensionamento. Apps com tamanho
  mínimo de janela, incluindo alguns em Electron, acabam maiores que a zona

## Apoio

O Waridake é gratuito e vai continuar assim. Se ele te poupa tempo, apoiar pelo
[GitHub Sponsors](https://github.com/sponsors/omikuji) é bem-vindo — é o único
financiamento do projeto.

## Licença

Licença MIT.

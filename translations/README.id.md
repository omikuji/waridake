# Waridake

[English](../README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · **Bahasa Indonesia** · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Penata jendela untuk macOS yang tak melakukan apa pun selain membagi layar.

*Waridake* (割り竹) berarti “bambu belah” — satu tebasan bersih, tak lebih.

**Apa yang dilakukannya:**

1. Anda menentukan zona untuk tiap layar
2. Tahan **Shift sambil menyeret jendela**, zona pun muncul
3. Lepaskan di atas sebuah zona dan jendela masuk ke situ

Tanpa kisi pintasan papan ketik, tanpa riwayat jendela, tanpa langganan. Ia tinggal di bilah
menu.

> Yang mengikat adalah [README.md](../README.md) berbahasa Inggris. Bila terjemahan ini
> tertinggal, versi Inggris yang berlaku.

## Pemasangan

Perlu Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Saat pertama dijalankan, macOS meminta izin Aksesibilitas. Nyalakan Waridake di
**Pengaturan Sistem → Privasi & Keamanan → Aksesibilitas**. Memberi izin saat aplikasi sedang
berjalan sudah cukup: ia menyadarinya dalam sedetik, tak perlu dijalankan ulang.

Agar terbuka saat masuk: Pengaturan Sistem → Umum → Item Masuk.

### Catatan saat membangun ulang

Penandatanganan bawaannya ad hoc, jadi **tanda tangannya berubah tiap kali dibangun dan macOS
menarik izinnya diam-diam** — kotaknya tetap tercentang, tapi tak ada yang jalan. Hapus
Waridake dari daftar Aksesibilitas lalu tambahkan lagi, atau selesaikan sekalian dengan membuat
sertifikat penandatanganan kode yang ditandatangani sendiri (Akses Gantungan Kunci → Asisten
Sertifikat → Buat Sertifikat, jenis: penandatanganan kode) lalu bangun dengan itu:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Cara memakai

Semuanya ada di bawah ikon bilah menu.

| Butir menu | Kegunaannya |
| --- | --- |
| **Rapikan jendela yang terbuka** | Menaruh tiap jendela terbuka ke zona terdekat. Untuk membereskan saat jendela sudah bergeser |
| **Edit tata letak…** | Penyunting visual, dijelaskan di bawah |
| **Tata letak…** | Tata letak tiap layar berikut kapan terakhir dipakai, serta riwayatnya |
| **Edit sebagai JSON…** | Berkas pengaturan dalam jendela penyuntingan sederhana |
| **Muat ulang tata letak** | Membaca ulang berkas setelah Anda mengubahnya di tempat lain |

Tata letak disimpan **per layar**, sebab layar berbeda bentuk dan ukuran, dan satu pembagian tak
pernah cocok untuk semua. Layar dikenali lewat UUID-nya, jadi pengaturan bertahan meski dicabut
atau komputer dinyalakan ulang.

### Penyunting visual

**Edit tata letak…** membuka penyunting di semua layar tersambung sekaligus. Bentuk tiap layar
sendiri-sendiri; menekan Simpan di salah satunya menyimpan semuanya. Ukuran ditampilkan dalam
persen, jadi tak ada pecahan yang perlu dibaca.

| Tindakan | Kegunaannya |
| --- | --- |
| **Klik kanan sebuah zona** | Bagi jadi 2 atau 3, ratakan, tengahkan pada layar |
| **Tombol “Gabungkan” di sebuah batas** | Menyatukan kedua zona itu. Muncul di mana keduanya membentuk persegi panjang |
| Seret sebuah batas | Memindahkannya. Zona di kedua sisi ikut memanjang, jadi tak muncul celah |
| Seret batas **dengan ⌥** | Memindahkan pula batas cerminnya, simetris terhadap tengah layar — untuk melebarkan zona tengah secara merata |
| Klik dua kali sebuah zona | Memotongnya di situ, menyusuri sisi terpanjang (⌥ membalik arah) |
| `V` `H` `⌫` `⌘Z` `R` | Bagi, bagi arah sebaliknya, gabungkan dengan tetangga, urungkan, kembali ke awal |
| `return` / `esc` | Simpan dan tutup / buang |

“Ratakan kolom ini” menyamakan zona yang bertumpuk dalam satu kolom (misalnya empat di sepanjang
tepi kiri); untuk baris yang disamakan adalah lebarnya. Zona seukuran di tempat lain pada layar
tidak diusik.

“Tengahkan pada layar” memindahkan zona agar simetris terhadap garis tengah tanpa mengubah
ukurannya. Zona yang menempel di tepi layar tak bisa dipindah begitu, dan butir menunya tetap
mati.

Batas menempel ke tepi zona lain serta ke 1/4, 1/3, 1/2, 2/3, dan 3/4. Kendali **Jarak** di bawah
mengatur ruang antarzona; pilih “Tidak ada” agar jendela rapat satu sama lain.

### Tata letak dan riwayat

**Tata letak…** mendaftar tiap layar beserta status sambungan, isinya, dan kapan terakhir dipakai
— sehingga pengaturan monitor yang tak lagi Anda punya langsung kelihatan dan bisa dihapus.

Tiap penyimpanan meninggalkan keadaan sebelumnya di `~/.config/waridake/history/`, 10 versi
terakhir. Mana pun bisa dipulihkan dari daftar, dan keadaan sebelum pemulihan juga diarsipkan,
jadi tak ada yang hilang.

## Pengaturan

Berkasnya `~/.config/waridake/layout.json`, dibuat saat pertama dijalankan. Ia berkas biasa —
penyunting bawaan itu kemudahan, bukan keharusan.

Tiap zona ditulis sebagai **pecahan antara 0 dan 1** dari area kerja layar (sisa setelah bilah
menu dan Dock). `x`/`y` dihitung dari kiri atas, `w`/`h` adalah lebar dan tinggi, dan `gap`
adalah jarak antarzona dalam titik.

Bawaannya dua kolom sama lebar:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Zona boleh bertumpang tindih; yang pertama memuat penunjuk itulah yang menang.

### Tata letak per layar

Layar ditaruh di bawah `displays`, dengan UUID layar sebagai kunci. Penyunting visual yang
menuliskannya untuk Anda. Layar tanpa entri memakai `gap` / `zones` di bagian atas. `name` dan
`usedAt` sekadar catatan — hanya aplikasi yang menulisnya.

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

Berkas tanpa `displays` tetap termuat dan berlaku di mana saja.

## Bahasa

26 bahasa, dipilih otomatis dari pengaturan bahasa macOS Anda — tak ada yang perlu diatur.

Sebagian besar bukan ditulis penutur asli, jadi koreksi adalah jenis pull request yang paling
disambut. Menambah bahasa berarti menyalin `Resources/en.lproj/Localizable.strings` ke
`Resources/<bahasa>.lproj/`, menerjemahkan bagian kanan tiap baris, lalu membangun ulang. Yang
belum diterjemahkan kembali ke bahasa Inggris.

## Cara kerjanya

- Pemantau peristiwa global mengawasi seretan tombol kiri (inilah yang menuntut izin Aksesibilitas)
- Saat ditekan, jendela di bawah penunjuk dicari lewat Accessibility API
- Zona baru muncul setelah **jendelanya sendiri bergerak**, jadi memilih teks atau menyeret berkas
  di dalam jendela tidak memicu apa pun
- Melepas Shift menyembunyikan zona dan seretan berlanjut seperti biasa

## Pemecahan masalah

- **Tak ada zona muncul** — periksa izin Aksesibilitas; selama belum ada, menu menampilkan butir ⚠️
- **Berhenti jalan setelah dibangun ulang** — lihat “Catatan saat membangun ulang”
- **Satu aplikasi tak mau pas** — ia menolak diubah ukurannya. Aplikasi dengan ukuran jendela
  minimum, termasuk sebagian yang berbasis Electron, akan lebih besar dari zonanya

## Dukungan

Waridake gratis dan akan tetap begitu. Kalau ia menghemat waktu Anda, dukungan lewat
[GitHub Sponsors](https://github.com/sponsors/omikuji) sangat berarti — itulah satu-satunya
pendanaan proyek ini.

## Lisensi

Lisensi MIT.

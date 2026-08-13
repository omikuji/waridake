# Waridake

[English](README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · **Türkçe** · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Ekranı bölmekten başka bir şey yapmayan bir macOS pencere yerleştirici.

*Waridake* (割り竹) “yarılmış bambu” demek — tek temiz bir kesik, o kadar.

**Ne yapar:**

1. Her ekran için bölgeleri siz belirlersiniz
2. **Bir pencereyi sürüklerken Shift’i basılı tutun**, bölgeler belirir
3. Bir bölgenin üzerinde bırakın, pencere oraya oturur

Kısayol ızgarası yok, pencere geçmişi yok, abonelik yok. Menü çubuğunda yaşar.

> Esas olan İngilizce [README.md](README.md) dosyasıdır. Bu çeviri geride kalırsa o
> geçerlidir.

## Kurulum

Xcode komut satırı araçları gerekir (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

İlk açılışta macOS erişilebilirlik izni ister. **Sistem Ayarları → Gizlilik ve Güvenlik →
Erişilebilirlik** bölümünden Waridake’yi açın. Uygulama çalışırken vermeniz yeter: bir
saniye içinde fark eder, yeniden başlatmaya gerek yok.

Oturum açıldığında başlaması için: Sistem Ayarları → Genel → Giriş Öğeleri.

### Yeniden derleme uyarısı

İmza öntanımlı olarak ad-hoc’tur, yani **her derlemede değişir ve macOS izni sessizce geri
alır** — kutucuk işaretli kalır ama hiçbir şey çalışmaz. Waridake’yi Erişilebilirlik
listesinden çıkarıp yeniden ekleyin ya da sorunu kökten çözün: Anahtar Zinciri Erişimi’nde
kendinden imzalı bir kod imzalama sertifikası oluşturun (Sertifika Yardımcısı → Sertifika
Oluştur, tür: kod imzalama) ve onunla derleyin:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Kullanım

Her şey menü çubuğu simgesinin altında.

| Menü öğesi | Ne yapar |
| --- | --- |
| **Açık pencereleri yerleştir** | Her açık pencereyi en yakın bölgeye koyar. Pencereler kaydığında toparlamak için |
| **Yerleşimi düzenle…** | Aşağıda anlatılan görsel düzenleyici |
| **Yerleşimler…** | Ekran başına yerleşimler, son kullanım tarihleriyle ve düzenleme geçmişiyle |
| **JSON olarak düzenle…** | Yapılandırma dosyası, sade bir düzenleme penceresinde |
| **Yerleşimi yeniden yükle** | Dosyayı başka yerde düzenledikten sonra yeniden okur |

Yerleşimler **her ekran için ayrı** tutulur; ekranların biçimi ve boyutu farklıdır, tek bir
bölünme hepsine uymaz. Ekranlar UUID’leriyle tanınır, dolayısıyla ayarlar takıp çıkarmaya ve
yeniden başlatmaya dayanır.

### Görsel düzenleyici

**Yerleşimi düzenle…** bağlı tüm ekranlarda aynı anda bir düzenleyici açar. Her ekranı ayrı
biçimlendirin; herhangi birinde Kaydet demek hepsini kaydeder. Boyutlar yüzde olarak
gösterilir, kimsenin kesir okuması gerekmez.

| İşlem | Ne yapar |
| --- | --- |
| **Bölgeye sağ tıklama** | 2 ya da 3’e bölme, eşit dağıtma, ekranda ortalama |
| **Sınırdaki “Birleştir” düğmesi** | O iki bölgeyi birleştirir. İkisi dikdörtgen oluşturduğu her yerde görünür |
| Sınırı sürükleme | Sınırı taşır. İki yandaki bölgeler birlikte uzar, boşluk açılmaz |
| Sınırı **⌥ ile sürükleme** | Ekran ortasına göre simetrik olan sınırı da taşır — ortadaki bölgeyi eşit genişletmek için |
| Bölgeye çift tıklama | Orada, uzun kenarı boyunca keser (⌥ yönü ters çevirir) |
| `V` `H` `⌫` `⌘Z` `R` | Böl, ters yönde böl, komşuyla birleştir, geri al, başa dön |
| `return` / `esc` | Kaydedip kapat / vazgeç |

“Bu sütunu eşit dağıt”, aynı sütunda üst üste duran bölgeleri eşitler (örneğin sol kenarda
dörde bölünmüş hâli); satırda ise genişlikleri eşitler. Ekranın başka yerindeki aynı boyutlu
bölgelere dokunulmaz.

“Ekranda ortala”, bölgenin boyutunu değiştirmeden onu orta çizgiye göre simetrik konuma
taşır. Ekranın kenarına değen bir bölge böyle taşınamaz, o durumda menü öğesi etkisiz kalır.

Sınırlar diğer bölgelerin kenarlarına ve 1/4, 1/3, 1/2, 2/3, 3/4 değerlerine yapışır.
Alttaki **Boşluk** denetimi bölgeler arasındaki aralığı belirler; “Yok” seçilirse pencereler
birbirine bitişik durur.

### Yerleşimler ve geçmiş

**Yerleşimler…** her ekranı bağlı olup olmadığı, içeriği ve son kullanım tarihiyle listeler;
artık sahip olmadığınız bir monitörün ayarları böylece hemen göze çarpar ve silinebilir.

Her kayıt, bir önceki durumu `~/.config/waridake/history/` içine bırakır; son 10 sürüm
saklanır. Herhangi biri listeden geri yüklenebilir ve geri yüklemeden önceki durum da
arşivlenir, yani hiçbir şey kaybolmaz.

## Yapılandırma

Dosya `~/.config/waridake/layout.json`, ilk açılışta oluşturulur. Sıradan bir dosyadır —
gömülü düzenleyici kolaylıktır, zorunluluk değil.

Her bölge, ekranın çalışma alanının (menü çubuğu ile Dock’tan artan kısmın) **0 ile 1
arasında bir kesri** olarak yazılır. `x`/`y` sol üstten başlar, `w`/`h` genişlik ve
yüksekliktir, `gap` ise bölgeler arasındaki boşluktur (punto).

Öntanımlı olarak iki eşit sütun:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Bölgeler üst üste binebilir; imleci içine alan ilk bölge kazanır.

### Ekran başına yerleşimler

Ekranlar `displays` altında, anahtar olarak ekran UUID’siyle durur. Görsel düzenleyici bunu
sizin için yazar. Kaydı olmayan ekranlar üstteki `gap` / `zones` değerlerini kullanır.
`name` ve `usedAt` yalnızca kayıt tutmak içindir; onları sadece uygulama yazar.

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

`displays` içermeyen dosyalar da yüklenir ve her yerde geçerli olur.

## Diller

26 dil, macOS dil ayarlarınıza göre kendiliğinden seçilir — ayarlanacak bir şey yok.

Çoğu ana dili konuşanlarca yazılmadı, bu yüzden düzeltmeler en makbul pull request türüdür.
Dil eklemek, `Resources/en.lproj/Localizable.strings` dosyasını
`Resources/<dil>.lproj/` içine kopyalayıp her satırın sağ tarafını çevirmek ve yeniden
derlemektir. Çevrilmeyenler İngilizceye döner.

## Nasıl çalışır

- Genel bir olay izleyici sol tuşla sürüklemeleri gözler (erişilebilirlik izni tam da bunun
  içindir)
- Basıldığı anda imlecin altındaki pencere Accessibility API ile bulunur
- Bölgeler ancak **pencerenin kendisi hareket ettikten sonra** görünür; pencere içinde metin
  seçmek ya da dosya sürüklemek hiçbir şeyi tetiklemez
- Shift bırakılınca bölgeler kaybolur, sürükleme normal biçimde sürer

## Sorun giderme

- **Hiç bölge görünmüyor** — erişilebilirlik iznini denetleyin; izin yokken menüde ⚠️ işaretli
  bir öğe durur
- **Yeniden derledikten sonra çalışmıyor** — yukarıdaki “Yeniden derleme uyarısı”na bakın
- **Bir uygulama bölgeye oturmuyor** — boyut değişimini reddediyordur. En küçük pencere boyutu
  olan uygulamalar, bazı Electron uygulamaları dâhil, bölgeden büyük kalabilir

## Destek

Waridake ücretsizdir ve öyle kalacak. Size zaman kazandırıyorsa
[GitHub Sponsors](https://github.com/sponsors/omikuji) üzerinden destek olmanız sevindirir —
projenin tek gelir kaynağı budur.

## Lisans

MIT Lisansı.

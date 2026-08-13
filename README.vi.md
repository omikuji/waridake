# Waridake

[English](README.md) · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Dansk](README.da.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Suomi](README.fi.md) · [Français](README.fr.md) · [עברית](README.he.md) · [हिन्दी](README.hi.md) · [Bahasa Indonesia](README.id.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Norsk](README.nb.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt-BR.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · **Tiếng Việt** · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md)

Một công cụ sắp xếp cửa sổ cho macOS, chỉ làm mỗi việc chia màn hình.

*Waridake* (割り竹) nghĩa là “tre chẻ” — một nhát cắt gọn, chỉ vậy thôi.

**Nó làm gì:**

1. Bạn định ra các vùng cho từng màn hình
2. Giữ **Shift trong lúc kéo một cửa sổ**, các vùng sẽ hiện ra
3. Thả trên một vùng và cửa sổ khớp vào đó

Không lưới phím tắt, không lịch sử cửa sổ, không thuê bao. Nó nằm trên thanh trình đơn.

> Bản tiếng Anh [README.md](README.md) là bản chuẩn. Nếu bản dịch này chậm hơn, hãy theo
> bản tiếng Anh.

## Cài đặt

Cần công cụ dòng lệnh của Xcode (`xcode-select --install`).

```bash
git clone https://github.com/omikuji/waridake.git
cd waridake
make install   # → /Applications/Waridake.app
```

Lần chạy đầu, macOS sẽ hỏi quyền Trợ năng. Hãy bật Waridake trong **Cài đặt Hệ thống →
Quyền riêng tư & Bảo mật → Trợ năng**. Cấp quyền khi ứng dụng đang chạy là đủ: nó nhận ra
trong vòng một giây, không cần khởi động lại.

Muốn mở khi đăng nhập: Cài đặt Hệ thống → Cài đặt chung → Mục đăng nhập.

### Lưu ý khi biên dịch lại

Mặc định ký theo kiểu ad hoc, nên **chữ ký đổi sau mỗi lần biên dịch và macOS lặng lẽ rút
quyền** — ô đánh dấu vẫn bật nhưng chẳng gì hoạt động. Hãy gỡ Waridake khỏi danh sách Trợ
năng rồi thêm lại, hoặc dứt điểm bằng cách tạo chứng chỉ ký mã tự ký (Keychain Access → Trợ
lý Chứng chỉ → Tạo chứng chỉ, loại: ký mã) rồi biên dịch với nó:

```bash
make install SIGN_IDENTITY="Waridake Dev"
```

## Cách dùng

Mọi thứ nằm dưới biểu tượng trên thanh trình đơn.

| Mục trình đơn | Công dụng |
| --- | --- |
| **Sắp xếp các cửa sổ đang mở** | Đưa mỗi cửa sổ đang mở vào vùng gần nó nhất. Để dọn khi cửa sổ đã xô lệch |
| **Sửa bố cục…** | Trình sửa trực quan, mô tả bên dưới |
| **Danh sách bố cục…** | Bố cục theo từng màn hình kèm lần dùng gần nhất, và lịch sử sửa |
| **Sửa dạng JSON…** | Tệp cấu hình trong một cửa sổ soạn thảo đơn giản |
| **Tải lại bố cục** | Đọc lại tệp sau khi bạn sửa ở nơi khác |

Bố cục được giữ **riêng cho từng màn hình**, vì màn hình khác nhau về hình dạng lẫn kích
thước, một cách chia không bao giờ hợp với tất cả. Màn hình được nhận diện bằng UUID, nên
cài đặt vẫn còn sau khi rút cắm hay khởi động lại.

### Trình sửa trực quan

**Sửa bố cục…** mở trình sửa trên mọi màn hình đang nối cùng lúc. Bạn tạo hình từng màn
riêng; bấm Lưu ở màn nào cũng lưu tất cả. Kích thước hiện theo phần trăm, khỏi phải đọc
phân số.

| Thao tác | Công dụng |
| --- | --- |
| **Bấm chuột phải vào một vùng** | Chia 2 hoặc 3, chia đều, căn giữa màn hình |
| **Nút “Gộp” trên đường ranh** | Nhập hai vùng làm một. Hiện ở nơi hai vùng ghép thành hình chữ nhật |
| Kéo một đường ranh | Dời nó. Vùng hai bên co giãn theo nên không hở khe |
| Kéo đường ranh **với ⌥** | Dời cả đường ranh đối xứng qua tâm màn hình — để nới vùng giữa cho đều |
| Bấm đúp một vùng | Cắt ngay chỗ đó, theo cạnh dài hơn (⌥ đảo hướng) |
| `V` `H` `⌫` `⌘Z` `R` | Chia, chia ngược lại, gộp với vùng kề, hoàn tác, về ban đầu |
| `return` / `esc` | Lưu rồi đóng / bỏ |

“Chia đều cột này” làm bằng nhau các vùng xếp chồng trong cùng một cột (chẳng hạn bốn vùng
dọc mép trái); với hàng thì là chiều rộng. Các vùng cùng cỡ ở chỗ khác trên màn hình không
bị đụng tới.

“Căn giữa màn hình” dời vùng sao cho đối xứng qua đường giữa mà không đổi kích thước. Vùng
chạm mép màn hình thì không dời kiểu đó được, và mục trình đơn sẽ mờ đi.

Đường ranh hít vào cạnh của các vùng khác và vào 1/4, 1/3, 1/2, 2/3, 3/4. Ô **Khoảng cách**
ở dưới định khoảng hở giữa các vùng; chọn “Không” để các cửa sổ sát nhau.

### Danh sách và lịch sử

**Danh sách bố cục…** liệt kê từng màn hình kèm trạng thái kết nối, nội dung và lần dùng gần
nhất — cài đặt của cái màn hình bạn không còn dùng sẽ lộ ra ngay và có thể xoá.

Mỗi lần lưu, trạng thái trước đó nằm lại trong `~/.config/waridake/history/`, giữ 10 bản gần
nhất. Bản nào cũng khôi phục được từ danh sách, và trạng thái trước khi khôi phục cũng được
lưu, nên không mất gì.

## Cấu hình

Tệp là `~/.config/waridake/layout.json`, tạo ra ở lần chạy đầu. Nó chỉ là một tệp thường —
trình soạn thảo tích hợp là tiện lợi, không bắt buộc.

Mỗi vùng ghi theo **tỉ lệ từ 0 đến 1** của vùng làm việc trên màn hình (phần còn lại sau
thanh trình đơn và Dock). `x`/`y` tính từ góc trên bên trái, `w`/`h` là rộng và cao, còn
`gap` là khoảng cách giữa các vùng, tính bằng điểm.

Mặc định là hai cột bằng nhau:

```json
{
  "gap": 8,
  "zones": [
    { "x": 0,   "y": 0, "w": 0.5, "h": 1 },
    { "x": 0.5, "y": 0, "w": 0.5, "h": 1 }
  ]
}
```

Các vùng có thể chồng lên nhau; vùng đầu tiên chứa con trỏ sẽ thắng.

### Bố cục theo màn hình

Màn hình nằm dưới `displays`, khoá là UUID của màn hình. Trình sửa trực quan tự ghi phần này.
Màn hình không có mục riêng sẽ dùng `gap` / `zones` ở trên cùng. `name` và `usedAt` chỉ để ghi
chú — chỉ ứng dụng viết chúng.

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

Tệp không có `displays` vẫn đọc được và áp dụng cho mọi màn hình.

## Ngôn ngữ

26 ngôn ngữ, chọn tự động theo cài đặt ngôn ngữ của macOS — không phải chỉnh gì cả.

Phần lớn không do người bản ngữ viết, nên sửa lỗi dịch là loại pull request được hoan nghênh
nhất. Thêm một ngôn ngữ nghĩa là chép `Resources/en.lproj/Localizable.strings` sang
`Resources/<ngôn ngữ>.lproj/`, dịch vế phải của từng dòng rồi biên dịch lại. Phần chưa dịch sẽ
quay về tiếng Anh.

## Nguyên lý

- Một bộ theo dõi sự kiện toàn cục quan sát thao tác kéo bằng nút trái (đây chính là lý do cần
  quyền Trợ năng)
- Khi nhấn xuống, cửa sổ dưới con trỏ được tìm qua Accessibility API
- Các vùng chỉ hiện sau khi **chính cửa sổ đã dịch chuyển**, nên chọn chữ hay kéo tệp bên trong
  cửa sổ đều không kích hoạt gì
- Thả Shift thì các vùng biến mất và thao tác kéo tiếp tục như thường

## Xử lý sự cố

- **Không thấy vùng nào** — kiểm tra quyền Trợ năng; khi còn thiếu, trình đơn hiện một mục ⚠️
- **Biên dịch lại xong thì hỏng** — xem “Lưu ý khi biên dịch lại”
- **Một ứng dụng không chịu vừa** — nó từ chối đổi kích thước. Ứng dụng có kích thước cửa sổ tối
  thiểu, kể cả vài ứng dụng Electron, sẽ lớn hơn vùng

## Ủng hộ

Waridake miễn phí và sẽ luôn như vậy. Nếu nó giúp bạn tiết kiệm thời gian, việc ủng hộ qua
[GitHub Sponsors](https://github.com/sponsors/omikuji) rất đáng quý — đó là nguồn tài trợ duy
nhất của dự án.

## Giấy phép

Giấy phép MIT.

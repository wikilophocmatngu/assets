# Wiki Lớp Học Mật Ngữ

Kho lưu trữ này chứa các khối mã CSS, JavaScript và các Module Scribunto (nếu có) được thiết kế và tùy chỉnh riêng cho **[Wiki Lớp Học Mật Ngữ](https://lophocmatngu.wiki)** (lophocmatngu.wiki) hoạt động trên nền tảng MediaWiki.

## 📁 Cấu trúc thư mục định tuyến

Cấu trúc thư mục mang tính ánh xạ 1-1 với các tựa trang trên MediaWiki. Ví dụ:
- `MediaWiki/Citizen.css` tương ứng với trang `MediaWiki:Citizen.css`.
- `MediaWiki/Common.js` tương ứng với trang `MediaWiki:Common.js`.
- Bất kỳ Module Lua nào đều được đặt trong thư mục `Module/` (ví dụ: `Module/Example.lua` ánh xạ tới `Module:Example`).

## 🔄 Quy trình đồng bộ

Việc đồng bộ hóa hai chiều giữa kho lưu trữ GitHub này và hệ thống máy chủ trực tiếp của Wiki được quản lý bởi **Pywikibot**. Mọi đoạn mã viết tại đây đều có thể đưa trực tiếp lên MediaWiki mà không cần qua khâu biên dịch trung gian nào khác (ngoại trừ các bộ chọn nâng cao đã được MediaWiki hỗ trợ qua trình biên dịch sẵn nếu có, như `:root.skin-theme-clientpref-night`).

## 🎨 Thông tin giao diện

Wiki hiện tại sử dụng giao diện **Citizen** (một giao diện MediaWiki hiện đại, hỗ trợ mobile-first, có chế độ Sáng/Tối linh hoạt). Do đó, bộ CSS/JS tại hệ thống kho lưu trữ này đặc biệt chú trọng tới:
- Cách tận dụng [Biến CSS của Citizen](https://starcitizentools.github.io/mediawiki-skins-Citizen/).
- Đảm bảo mã JavaScript hoạt động hoàn hảo thông qua `mw.loader` và cơ chế móc sự kiện (hook) `mw.hook` của MediaWiki.
- Bố cục đáp ứng, tùy biến cực mạnh phù hợp theo tùy chọn chế độ Sáng/Tối/Đen hoàn toàn của người dùng.

## 📝 Quy chuẩn dòng mã

- Nội dung chú thích mã hoàn toàn bằng tiếng Việt.
- Sử dụng đầy đủ CSSDoc / JSDoc để khai báo thông tin đầu tệp.
- Hướng đến tối ưu trải nghiệm đọc, bảo trì và dễ dàng mở rộng mạng lưới tri thức "rất rất rất rất rất yêu bạn" này.

/**
 * MediaWiki:Common.js
 *
 * @desc     Mã định dạng và xử lý chức năng chung cho toàn bộ Wiki Lớp Học Mật Ngữ
 * @author   [[Thành viên:Pisces]] (https://songngu.xyz)
 * @site     https://lophocmatngu.wiki/MediaWiki:Common.js
 * @license  CC BY-SA 4.0
 */

/* Mã cục bộ */
importScript("MediaWiki:Indicator.js");
importScript("MediaWiki:DefaultAvatar.js");

/* Mã ngoại vi */
/* [[dev:ShowYourV2Avatar]] */
const wikidbname = "lhmnwiki";
mw.loader.load(
  "https://dev.miraheze.org/wiki/User:Splatched/ShowYourV2Avatar.js?action=raw&ctype=text/javascript",
);

/* [[dev:Template:Spoiler]] */
$(function () {
  // Xử lý hành vi của khối spoiler
  $(".spoiler").click(function () {
    $(this).toggleClass("off");
  });
  // Xử lý hành vi của nút spoiler
  $("#spoilerbtn").text("Hiện Spoiler");
  $("#spoilerbtn").click(function () {
    $(this).toggleClass("hide");
    $(".spoiler").toggleClass("showall");

    if ($(this).is(".hide")) {
      $(this).text("Ẩn Spoiler");
    } else {
      $(this).text("Hiện Spoiler");
    }
  });
});
//

/* Sửa lỗi máy khách không nạp thông điệp hệ thống, xem [[phorge:T12267]] */
if (window.mw && mw.config.get("wgUserLanguage") !== "qqx") {
  mw.messages.set({
    "mwe-upwiz-license-lhmn":
      "Nhóm tác giả LHMN và đối tác đã cấp quyền sử dụng tác phẩm này trên các dự án của fan hâm mộ",
    "mwe-upwiz-license-lhmn-head": "Lớp Học Mật Ngữ đã xuất bản tác phẩm này",
    "mwe-upwiz-license-lhmn-subhead":
      "Dùng giấy phép chuyên biệt này cho các tác phẩm có bản quyền thuộc về tác giả Lớp Học Mật Ngữ cũng như các đối tác.",
    "mwe-upwiz-license-snxyz": "SongNgư.xyz đã xuất bản tác phẩm này",
    "mwe-upwiz-license-snxyz-explain":
      "Chỉ được phép sử dụng nếu chính [[Thành viên:Pisces|Song Ngư]] (webmaster) là tác giả kiêm người tải lên.",
  });
}

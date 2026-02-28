/**
 * MediaWiki:Citizen.js
 *
 * @desc     Mã JavaScript tùy chỉnh cho giao diện Citizen trên Wiki Lớp Học Mật Ngữ
 * @author   [[Thành viên:Pisces]] (https://songngu.xyz)
 * @site     https://lophocmatngu.wiki/MediaWiki:Citizen.js
 * @license  CC BY-SA 4.0
 */

const popoutData = [
  {
    heading: "Các dự án khác của SongNgư.xyz",
    icon: `https://static.wikitide.net/lhmnwiki/9/9e/SongNguXYZ-icon.svg`,
    items: [
      {
        name: "Cookie Run Wiki",
        desc: "Coming soon...",
        icon: "https://static.wikitide.net/lhmnwiki/9/9f/CRW.png",
        url: "https://twitter.com/CRWiki",
      },
      {
        name: "Custom Gameshows Wiki",
        icon: "https://static.wikitide.net/cgwiki/a/a0/Wiki-logo.png",
        url: "https://cg.songngu.xyz",
      },
      {
        name: "Wiki 100 Bạn Gái tiếng Việt",
        icon: "https://static.wikitide.net/100bangaiwiki/7/7c/100.png",
        url: "https://100bangai.songngu.xyz",
      },
      {
        name: "HunggSMP Wiki",
        icon: "https://static.wikitide.net/lhmnwiki/e/e4/HunggSMP.png",
        url: "https://hunggsmp.wiki.gg/",
      },
    ],
  },
];

mw.loader.load(
  "https://dev.miraheze.org/wiki/User:Splatched/MenuIcon.js?action=raw&ctype=text/javascript",
);

// Mã sau đây được phái sinh từ dự án Hellmet Wiki, chân thành cám ơn! (https://hellmet.miraheze.org)
$(document).ready(function () {
  $(".citizen-drawer").after(
    $(
      '<div class="citizen-discord citizen-header__item mw-logo-icon"><a href="https://go.lophocmatngu.wiki/discord"><img src="https://static.wikitide.net/outlasterwiki/3/3c/Discordlg.svg" width="40" height="40" alt="Nút Discord."></a></div>',
    ),
  );
});

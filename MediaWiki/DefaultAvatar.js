// Thay thế hình ảnh UPv2 mặc định thành các hình trong LHMN
// Mã được tái sử dụng từ tagging.wiki!
// document.addEventListener("DOMContentLoaded", function() {

// Mã chỉ chạy trong không gian tên 2 và 3
const allowedNamespaces = [2, 3];
if (allowedNamespaces.includes(mw.config.get('wgNamespaceNumber'))) {
    (function () {
        var blockedUserAvatar = 'https://static.wikitide.net/lhmnwiki/9/9e/BlockedAvatar.png';
        var avatars = [
            'https://static.wikitide.net/lhmnwiki/c/c0/Bạch_Dương_nam.jpg',
            'https://static.wikitide.net/lhmnwiki/c/ce/Kim_Ngưu_nam.jpg',
            'https://static.wikitide.net/lhmnwiki/7/77/Song_Tử_nam.jpg',
            'https://static.wikitide.net/lhmnwiki/5/5a/53163036430_df53072261.jpg',
            'https://static.wikitide.net/lhmnwiki/7/72/Xử_Nữ_nữ.jpg',
            'https://static.wikitide.net/lhmnwiki/a/a0/Thiên_Bình_nữ.jpg',
            'https://static.wikitide.net/lhmnwiki/1/18/Thiên_Yết_nữ.jpg',
            'https://static.wikitide.net/lhmnwiki/6/60/Nhân_Mã_nam.jpg',
            'https://static.wikitide.net/lhmnwiki/0/00/Ma_Kết_nữ.jpg',
            'https://static.wikitide.net/lhmnwiki/9/9f/Bảo_Bình_nam.jpg',
            'https://static.wikitide.net/lhmnwiki/e/ed/Song_Ngư_nam.jpg',
            'https://static.wikitide.net/lhmnwiki/6/6d/Bạch_Dương_nữ.jpg',
            'https://static.wikitide.net/lhmnwiki/a/a7/Kim_Ngưu_nữ.jpg',
            'https://static.wikitide.net/lhmnwiki/c/c4/Song_Tử_nữ.jpg',
            'https://static.wikitide.net/lhmnwiki/f/fa/Cự_Giải_nam.jpg',
            'https://static.wikitide.net/lhmnwiki/9/9f/Sư_Tử_nữ.jpg',
            'https://static.wikitide.net/lhmnwiki/7/70/Xử_Nữ_nam.jpg',
            'https://static.wikitide.net/lhmnwiki/3/3f/Thiên_Bình_nam.jpg',
            'https://static.wikitide.net/lhmnwiki/3/34/Thiên_Yết_nam.jpg',
            'https://static.wikitide.net/lhmnwiki/f/f6/Nhân_Mã_nữ.jpg',
            'https://static.wikitide.net/lhmnwiki/0/0b/Ma_Kết_nam.jpg',
            'https://static.wikitide.net/lhmnwiki/a/ae/Bảo_Bình_nữ.jpg',
            'https://static.wikitide.net/lhmnwiki/9/9c/Song_Ngư_nữ.jpg'
        ];
        var profileImages = document.querySelectorAll(".profile-avatar-image");
        // Xác định nếu user bị cấm
        var isUserBlocked = document.querySelector('.cdx-message--block') !== null;

        if (isUserBlocked) {
            // Ghi đè hình đại diện của người dùng bị cấm theo mặc định
            profileImages.forEach(function (img) {
                img.setAttribute("src", blockedUserAvatar);
            });
        } else {
            // Còn không thì tiếp tục với việc thêm hình ngẫu nhiên
            var randomIndex = Math.floor(Math.random() * avatars.length);
            profileImages.forEach(function (img) {
                if (!img.getAttribute("src") ||
                    img.getAttribute("src") === "https://static.wikitide.net/lhmnwiki/upv2avatars/default.png" ||
                    img.getAttribute("src") === "//static.wikitide.net/lhmnwiki/upv2avatars/default.png") {
                        img.setAttribute("src", avatars[randomIndex]);
                    }
                });
            }
        })();
    }
// });

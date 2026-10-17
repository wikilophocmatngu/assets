local InfoboxNeue = require( 'Module:InfoboxNeue' )

local p = {}

-- =========================================================
-- KHU VỰC DỮ LIỆU CỐ ĐỊNH (HARDCODE)
-- =========================================================
local DATA = {
	title       = 'Lớp học Mật Ngữ',
	subtitle	= 'Series thứ X do B.R.O Comics sáng tác và phát hành năm 2014',
	image       = 'Lớp_Học_Mật_Ngữ.png', -- Nhớ thay bằng tên file ảnh thực tế trên Wiki
	caption     = 'Bìa đại diện gồm tất cả các nhân vật Lớp Học Mật Ngữ trên nền Khu Rừng Kim Cương',
	
	author      = 'B.R.O Comics',
	
	publishers  = '<ul><li>Báo Sinh viên Việt Nam - Hoa Học Trò</li><li>Báo Tiền Phong</li></ul>',
	
	releases    = '<ul><li>23/1/2014 - 20/12/2017 (Báo TTN)</li><li>18/11/2015 - nay (in riêng)</li><li>24/12/2020 - 31/1/2022 (hoạt hình mùa 1)</li></ul>',
	
	-- Website chính thức
	website     = 'https://lophocmatngu.com',
	
	-- Mạng xã hội
	socials = {
		facebook = { link = 'https://www.facebook.com/lophocmatngu', label = 'Facebook' },
		youtube  = { link = 'https://www.youtube.com/@LophocMatNgu', label = 'Youtube' },
		tiktok   = { link = 'https://www.tiktok.com/@lophocmatngu_official', label = 'TikTok' }
	}
}

--- Điểm neo chính gọi từ Wikitext
function p.main( frame )
	local infobox = InfoboxNeue:new( {
		removeEmpty = true
	} )

	-- 1. Ảnh bìa
	infobox:renderImage( DATA.image )
	
	-- 2. Tiêu đề chính
	infobox:renderHeader( {
		title = DATA.title,
		subtitle = DATA.subtitle
	} )

	-- 3. Thông tin xuất bản (Tác giả, Nhà xuất bản, Ngày phát hành)
	local mainSection = {}

	table.insert( mainSection, infobox:renderItem( { 
		label = 'Tác giả', 
		data = DATA.author,
		iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-edit',
		row = true,
		colspan = 2
	} ) )

	table.insert( mainSection, infobox:renderItem( { 
		label = 'Nhà xuất bản', 
		data = DATA.publishers,
		iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-printer',
		colspan = 2
	} ) )

	table.insert( mainSection, infobox:renderItem( { 
		label = 'Ngày phát hành', 
		data = DATA.releases,
		iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-history',
		colspan = 2
	} ) )

	infobox:renderSection( {
		content = table.concat( mainSection ),
		col = 2
	} )

	-- 4. Nút Popup Footer (Website & Mạng xã hội)
	local popupContent = mw.html.create( 'div' )
	
	-- Nhóm 1: Website chính thức
	popupContent:tag( 'div' )
		:css( 'font-weight', 'bold' )
		:css( 'margin-bottom', '4px' )
		:css( 'color', 'var(--color-subtle, #a2a9b1)' )
		:wikitext( 'Trang chủ' )
		
	popupContent:tag( 'div' )
		:css( 'margin-bottom', '12px' ) -- Chừa khoảng trống giữa 2 nhóm
		:wikitext( string.format( '[%s %s]', DATA.website, 'lophocmatngu.com' ) )

	-- Nhóm 2: Mạng xã hội
	popupContent:tag( 'div' )
		:css( 'font-weight', 'bold' )
		:css( 'margin-bottom', '4px' )
		:css( 'color', 'var(--color-subtle, #a2a9b1)' )
		:wikitext( 'Mạng xã hội' )
		
	popupContent:tag( 'div' )
		:wikitext( string.format( '[%s %s] • [%s %s] • [%s %s]', 
			DATA.socials.facebook.link, DATA.socials.facebook.label,
			DATA.socials.youtube.link, DATA.socials.youtube.label,
			DATA.socials.tiktok.link, DATA.socials.tiktok.label
		) )

	infobox:renderFooter( {
		button = {
			icon = 'NguYet.svg',
			label = 'Liên kết ngoài',
			type = 'popup',
			content = infobox:renderSection( {
				content = {
					-- Nhóm 1: Trang chủ
					infobox:renderItem( {
						label = 'Trang chủ',
						data = infobox:renderLinkButton( { 
							label = 'lophocmatngu.com', 
							link = DATA.website 
						} )
					} ),
					
					-- Nhóm 2: Mạng xã hội
					infobox:renderItem( {
						label = 'Mạng xã hội',
						-- Nối các nút linkButton lại với nhau
						data = table.concat( {
							infobox:renderLinkButton( { 
								label = DATA.socials.facebook.label, 
								link = DATA.socials.facebook.link 
							} ),
							infobox:renderLinkButton( { 
								label = DATA.socials.youtube.label, 
								link = DATA.socials.youtube.link 
							} ),
							infobox:renderLinkButton( { 
								label = DATA.socials.tiktok.label, 
								link = DATA.socials.tiktok.link 
							} )
						} )
					} ),
				},
				class = 'infobox__section--linkButtons',
			}, true )
		}
	} )

	-- Trả về HTML
	return infobox:renderInfobox( nil, 'về Lớp Học Mật Ngữ' )
end

return p

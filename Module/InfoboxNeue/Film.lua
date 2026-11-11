--[=[
 * Module:InfoboxNeue/Film
 *
 * @desc Hộp thông tin phim dựng trên Module:InfoboxNeue
 * @author [[Thành viên:Pisces]] (https://songngu.xyz)
 * @site https://lophocmatngu.wiki/Module:InfoboxNeue/Film
 * @license CC BY-SA 4.0
 ]=]

local InfoboxNeue = require( 'Module:InfoboxNeue' )
local getArgs = require( 'Module:Arguments' ).getArgs

local p = {}

--- Điểm neo chính cho bản mẫu gọi qua #invoke
function p.main( frame )
	return p._main( getArgs( frame ), frame )
end

--- Dựng một mục từ danh sách { tham số, nhãn, biểu tượng }
local function section( infobox, args, title, rows )
	local items = {}
	for _, row in ipairs( rows ) do
		if args[ row[ 1 ] ] then
			table.insert( items, infobox:renderItem( {
				label = row[ 2 ],
				data = args[ row[ 1 ] ],
				iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-' .. row[ 3 ],
				colspan = 2
			} ) )
		end
	end
	if #items > 0 then
		infobox:renderSection( { title = title, content = table.concat( items ), col = 2 } )
	end
end

--- Điểm neo nội bộ
function p._main( args, frame )
	frame = frame or mw.getCurrentFrame()
	local infobox = InfoboxNeue:new( {
		removeEmpty = true,
		displayPlaceholder = true
	} )

	if args.image then
		infobox:renderImage( args.image )
	end

	infobox:renderHeader( {
		title = args.title or mw.title.getCurrentTitle().text,
		subtitle = args.tagline
	} )

	section( infobox, args, 'Thông tin phim', {
		{ 'genre', 'Thể loại', 'listBullet' },
		{ 'based_on', 'Dựa trên', 'article' },
		{ 'status', 'Tình trạng', 'star' },
		{ 'release_date', 'Công chiếu', 'history' },
		{ 'distributor', 'Phát hành', 'tray' },
		{ 'country', 'Quốc gia', 'home' },
		{ 'language', 'Ngôn ngữ', 'wikiText' },
		{ 'caption', 'Áp phích', 'upload' }
	} )

	section( infobox, args, 'Đoàn làm phim', {
		{ 'director', 'Đạo diễn', 'userAvatar' },
		{ 'producer', 'Sản xuất', 'userAvatar' },
		{ 'studio', 'Hãng sản xuất', 'userGroup' },
		{ 'co_production', 'Hợp tác sản xuất', 'userAdd' },
		{ 'writer', 'Kịch bản', 'edit' },
		{ 'voices', 'Lồng tiếng', 'userGroup' },
		{ 'music', 'Âm nhạc', 'reference' }
	} )

	-- SEO: từ khóa, ảnh và mô tả ngắn lấy từ chính tham số hộp thông tin
	local seo = require( 'Module:InfoboxSEO' )
	local seoMetadata = seo.setSEO( frame, args, {
		imageAlt = 'Áp phích phim ' .. mw.title.getCurrentTitle().text .. ' trong Lớp Học Mật Ngữ.',
		keywords = { 'phim', 'phim hoạt hình', args.genre, args.based_on, args.director },
		shortdesc = 'Một bộ phim thuộc Lớp Học Mật Ngữ.'
	} )

	return infobox:renderInfobox( nil, args.snippet or 'Phim' ) .. seoMetadata
end

return p

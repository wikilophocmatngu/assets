--[=[
 * Module:InfoboxNeue/Song
 *
 * @desc Hộp thông tin bài hát dựng trên Module:InfoboxNeue
 * @author [[Thành viên:Pisces]] (https://songngu.xyz)
 * @site https://lophocmatngu.wiki/Module:InfoboxNeue/Song
 * @license CC BY-SA 4.0
 ]=]

local InfoboxNeue = require( 'Module:InfoboxNeue' )
local getArgs = require( 'Module:Arguments' ).getArgs

local p = {}

--- Điểm neo chính cho bản mẫu gọi qua #invoke
function p.main( frame )
	return p._main( getArgs( frame ), frame )
end

--- Điểm neo nội bộ
function p._main( args, frame )
	local infobox = InfoboxNeue:new( {
		removeEmpty = true,
		displayPlaceholder = true
	} )

	if args.image then
		infobox:renderImage( args.image )
	end

	infobox:renderHeader( {
		title = args.title or mw.title.getCurrentTitle().text,
		subtitle = args.subtitle
	} )

	-- Các dòng thông tin: { tham số, nhãn, biểu tượng }
	local rows = {
		{ 'release_date', 'Ngày phát hành', 'history' },
		{ 'producer', 'Sản xuất', 'wikiText' },
		{ 'singer', 'Trình bày', 'userGroup' }
	}

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
		infobox:renderSection( {
			title = 'Thông tin bài hát',
			content = table.concat( items ),
			col = 2
		} )
	end

	return infobox:renderInfobox( nil, args.snippet or 'Bài hát' )
end

return p

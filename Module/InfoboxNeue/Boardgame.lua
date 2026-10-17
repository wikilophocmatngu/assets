local InfoboxNeue = require( 'Module:InfoboxNeue' )
local getArgs = require( 'Module:Arguments' ).getArgs

local p = {}

--- Hàm phụ trợ xử lý ngày tháng (Thêm "Dự kiến vào" nếu ngày trong tương lai)
local function processReleaseDate( dateString )
	if type( dateString ) ~= 'string' or dateString == '' then
		return dateString
	end

	local d, m, y = string.match( dateString, "^(%d%d?)/(%d%d?)/(%d%d%d%d)$" )
	
	if d and m and y then
		local releaseTime = os.time( { 
			year = tonumber( y ), month = tonumber( m ), day = tonumber( d ),
			hour = 0, min = 0, sec = 0 
		} )
		
		if releaseTime > os.time() then
			return "Dự kiến vào " .. dateString
		end
	end

	return dateString
end

--- Điểm neo chính cho bản mẫu gọi qua #invoke
function p.main( frame )
	local args = getArgs( frame )
	return p._main( args, frame )
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
		subtitle = args.subtitle
	} )

	local mainSection = {}

	if args.adapted_from then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Chuyển thể từ', 
			data = args.adapted_from,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-reference',
			colspan = 2
		} ) )
	end

	if args.designer then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Thiết kế', 
			data = args.designer,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-wikiText',
			colspan = 2
		} ) )
	end
	
	if args.artist then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Minh họa', 
			data = args.artist,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-edit',
			colspan = 2
		} ) )
	end

	if args.publisher then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Phát hành', 
			data = args.publisher,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-home',
			colspan = 2
		} ) )
	end

	if args.release_date then
		local formattedDate = processReleaseDate( args.release_date )
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Ngày phát hành', 
			data = formattedDate,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-history'
		} ) )
	end
	
	if args['type'] then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Thể loại', 
			data = args['type']
		} ) )
	end

	if args.players then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Số lượng người chơi', 
			data = args.players
		} ) )
	end

	if args.playtime then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Thời gian chơi', 
			data = args.playtime
		} ) )
	end

	-- 4. Render Section
	if #mainSection > 0 then
		infobox:renderSection( {
			title = 'Thông tin Boardgame',
			content = table.concat( mainSection ),
			col = 2,
			contentClass = 'infobox__sectionContent--autospan'
		} )
	end

	-- 5. Trả về HTML
	return infobox:renderInfobox( nil, args.snippet or 'Thông tin boardgame' )
end

return p

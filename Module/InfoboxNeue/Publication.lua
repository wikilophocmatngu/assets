local InfoboxNeue = require( 'Module:InfoboxNeue' )
local getArgs = require( 'Module:Arguments' ).getArgs

local p = {}

--- Helper function to process the release date
--- Prepends "Dự kiến vào " if the date is in the future
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

--- Main entry point for #invoke
function p.main( frame )
	local args = getArgs( frame )
	return p._main( args, frame )
end

--- Internal entry point for module-to-module calls
function p._main( args, frame )
	
	frame = frame or mw.getCurrentFrame()
	
	local infobox = InfoboxNeue:new( {
		removeEmpty = true,
		displayPlaceholder = true
	} )

	-- 1. Render Image (Supports Tabber via commas)
	if args.image then
		infobox:renderImage( args.image )
	end
	
	-- 2. Render Header
	infobox:renderHeader( {
		title = args.title or mw.title.getCurrentTitle().text,
		subtitle = args.subtitle
	} )

	-- 3. Render Main Section (General Information)
	local mainSection = {}

	if args.series then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Series', 
			data = args.series,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-listBullet'
		} ) )
	end

	if args.character then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Nhân vật đại diện', 
			data = args.character,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-userAdd'
		} ) )
	end

	if args.release_date then
		local formattedDate = processReleaseDate( args.release_date )
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Phát hành lần đầu', 
			data = formattedDate,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-star'
		} ) )
	end

	if args.pages then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Số trang', 
			data = args.pages,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-article'
		} ) )
	end

	if args.publisher then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Nhà xuất bản', 
			data = args.publisher,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-printer',
		} ) )
	end

	if #mainSection > 0 then
		infobox:renderSection( {
			title = 'Thông tin chung',
			content = table.concat( mainSection ),
			contentClass = 'infobox__sectionContent--autospan',
			col = 2,
		} )
	end

	-- 4. Render Navigation Section (Previous & Next)
	local navSection = {}

	if args.previous then
		table.insert( navSection, infobox:renderItem( { 
			label = 'Kế trước', 
			data = args.previous,
			page = args.previous
		} ) )
	end

	if args['next'] then
		table.insert( navSection, infobox:renderItem( { 
			label = 'Tiếp theo', 
			data = args['next'],
			page = args['next']
		} ) )
	end

	if #navSection > 0 then
		infobox:renderSection( {
			title = 'Điều hướng',
			class = 'infobox-publication-nav',
			content = table.concat( navSection ),
			contentClass = 'infobox__sectionContent--autospan',
			col = 2,
		} )
	end

	--local seoModule = require( 'Module:InfoboxSEO' )
	--local currentFrame = mw.getCurrentFrame()
	--local seoMetadata = seoModule.setSEO( currentFrame, args )
	
	local customStyles = frame:extensionTag { 
		name = 'templatestyles', 
		args = { src = 'Mô_đun:InfoboxNeue/Publication/styles.css' } 
	}

	-- 5. Render Output HTML
	local outputHtml = infobox:renderInfobox( nil, args.snippet or 'Ấn phẩm' )
	
	return customStyles .. outputHtml -- .. seoMetadata
end

return p

local InfoboxNeue = require( 'Module:InfoboxNeue' )
local getArgs = require( 'Module:Arguments' ).getArgs

local p = {}

--- Điểm neo chính cho #invoke
function p.main( frame )
	local args = getArgs( frame )
	return p._main( args, frame )
end

--- Điểm neo nội bộ
function p._main( args, frame )
	frame = frame or mw.getCurrentFrame()

	local infobox = InfoboxNeue:new( {
		removeEmpty = true,
		displayPlaceholder = true,
		class = 'character__infobox'
	} )

	-- 1. Render Image (BẮT BUỘC Ở TRÊN CÙNG)
	if args.image then
		infobox:renderImage( args.image )
	end

	-- 2. Render Header (SAU HÌNH ẢNH)
	infobox:renderHeader( {
		title = args.name or args.title or mw.title.getCurrentTitle().text,
		subtitle = args.subtitle,
		badge = args.status
	} )

	-- 3. THÔNG TIN CƠ BẢN
	local basicSection = {}

	if args.gender then
		table.insert( basicSection, infobox:renderItem( { 
			label = 'Giới tính', 
			data = args.gender,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-userAvatar'
		} ) )
	end

	if args.occupation then
		table.insert( basicSection, infobox:renderItem( { 
			label = 'Nghề nghiệp', 
			data = args.occupation,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-article' 
		} ) )
	end

	if args.affiliation then
		table.insert( basicSection, infobox:renderItem( { 
			label = 'Thành viên', 
			data = args.affiliation,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-userGroup'
		} ) )
	end

	if args.first_appearance then
		table.insert( basicSection, infobox:renderItem( { 
			label = 'Xuất hiện lần đầu', 
			data = args.first_appearance,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-history'
		} ) )
	end

	if #basicSection > 0 then
		infobox:renderSection( {
			title = 'Thông tin cơ bản',
			content = table.concat( basicSection ),
			col = 2,
			contentClass = 'infobox__sectionContent--autospan'
		} )
	end

	-- 4. KỸ NĂNG BOARD GAME
	local skillSection = {}

	if args.skill_cdsc then
		table.insert( skillSection, infobox:renderItem( { 
			label = '[[Cuộc Đua Sao Chổi (boardgame)|Cuộc Đua Sao Chổi]]', 
			data = args.skill_cdsc
		} ) )
	end

	if args.skill_stnh then
		table.insert( skillSection, infobox:renderItem( { 
			label = '[[Siêu Thú Ngân Hà (boardgame)|Siêu Thú Ngân Hà]]', 
			data = args.skill_stnh
		} ) )
	end

	if #skillSection > 0 then
		infobox:renderSection( {
			title = 'Kỹ năng Board game',
			collapsed = true,
			content = table.concat( skillSection )
		} )
	end
	
	--local seoModule = require( 'Module:InfoboxSEO' )
	--local currentFrame = mw.getCurrentFrame()
	--local seoMetadata = seoModule.setSEO( currentFrame, args )
	
	local customStyles = frame:extensionTag { 
		name = 'templatestyles', 
		args = { src = 'Mô_đun:InfoboxNeue/Character/styles.css' } 
	}

	-- 5. Render Output HTML
	local outputHtml = infobox:renderInfobox( nil, args.snippet or 'Nhân vật' )
	
	return customStyles .. outputHtml -- .. seoMetadata
	
end

return p

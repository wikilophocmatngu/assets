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

local function getStatusColor( status )
	if not status then return nil end
	local s = mw.ustring.lower( mw.text.trim( status ) )
	
	-- Red (Đỏ): Các series bị hủy, dang dở, ngừng xuất bản
	if s == 'ngừng phát hành' or s == 'ngừng xuất bản' or s == 'đã hủy' then
		return 'red'
		
	-- Green (Xanh lá): Đã trọn bộ, hoàn thành
	elseif s == 'hoàn thành' or s == 'đã kết thúc' or s == 'đã hoàn thành' then
		return 'green'
		
	-- Yellow (Vàng): Tạm ngưng, sắp ra mắt, hoặc đang tiến hành
	elseif s == 'tạm ngưng' or s == 'sắp ra mắt' or s == 'đang phát hành' or s == 'đang tiến hành' then
		return 'yellow'
	end
	
	-- Trả về nil nếu không khớp từ khóa nào (hiển thị indicator mặc định không màu)
	return nil 
end


--- Điểm neo chính
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

	-- 1. Ảnh bìa chương
	if args.image then
		infobox:renderImage( args.image )
	end
	
	if args.status then
		infobox:renderIndicator( {
			data = args.status,
			color = getStatusColor( args.status )
		} )
	end
	
	-- 2. Tiêu đề
	infobox:renderHeader( {
		title = args.title or mw.title.getCurrentTitle().text,
		subtitle = args.subtitle
	} )

	-- 3. THÔNG TIN CHUNG
	local mainSection = {}

	if args.release_date then
		local formattedDate = processReleaseDate( args.release_date )
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Phát hành lần đầu', 
			data = formattedDate,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-history'
		} ) )
	end

	if args.parts then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Số phần', 
			data = args.parts,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-listBullet'
		} ) )
	end

	if args.pages then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Số trang', 
			data = args.pages,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-article'
		} ) )
	end

	if args.main then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Nhân vật chính', 
			data = args.main,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-userAdd'
		} ) )
	end
	
	if args.publications then
		table.insert( mainSection, infobox:renderItem( { 
			label = 'Ấn phẩm phát hành', 
			data = args.publications,
			iconClass = 'citizen-ui-icon mw-ui-icon-wikimedia-tray',
			colspan = 2
		} ) )
	end

	if #mainSection > 0 then
		infobox:renderSection( {
			title = 'Thông tin chương',
			content = table.concat( mainSection ),
			col = 2,
			contentClass = 'infobox-auto-span' -- Kéo giãn mục lẻ tự động!
		} )
	end

	-- 4. ĐIỀU HƯỚNG
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
			class = 'infobox-chapter-nav',
			content = table.concat( navSection ),
			contentClass = 'infobox__sectionContent--autospan',
			col = 2,
		} )
	end
	
	local customStyles = frame:extensionTag { 
		name = 'templatestyles', 
		args = { src = 'Mô_đun:InfoboxNeue/Chapter/styles.css' } 
	}

	-- 5. Trả về kết quả
	local outputHtml = infobox:renderInfobox( nil, args.snippet or 'Chương truyện' )
	
	return customStyles .. outputHtml -- .. seoMetadata
end

return p
